import Foundation
import Combine

struct GoogleCalendarEvent: Identifiable {
    let id: String
    let title: String
    let start: Date
    let end: Date
    let colorId: String?
    let recurrence: [String]?
    let videoLink: String?
    let attendees: [GoogleCalendarAttendee]
    let myResponse: String? // "accepted", "declined", "tentative", "needsAction"
}

struct GoogleCalendarAttendee: Identifiable {
    let id: String
    let name: String?
    let email: String
    let responseStatus: String // "accepted", "declined", "tentative", "needsAction"
    let photoUrl: String?
}

class GoogleCalendarService: ObservableObject {
    @Published var events: [GoogleCalendarEvent] = []
    private var cancellables = Set<AnyCancellable>()
    private let authService: GoogleAuthService
    
    init(authService: GoogleAuthService) {
        self.authService = authService
    }
    
    func fetchEvents(start: Date, end: Date) {
        authService.getAccessToken { [weak self] token in
            guard let self = self, let token = token else { return }
            let calendarId = "primary"
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime]
            let timeMin = dateFormatter.string(from: start)
            let timeMax = dateFormatter.string(from: end)
            var urlComponents = URLComponents(string: "https://www.googleapis.com/calendar/v3/calendars/\(calendarId)/events")!
            urlComponents.queryItems = [
                URLQueryItem(name: "timeMin", value: timeMin),
                URLQueryItem(name: "timeMax", value: timeMax),
                URLQueryItem(name: "singleEvents", value: "true"),
                URLQueryItem(name: "maxResults", value: "2500"),
                URLQueryItem(name: "orderBy", value: "startTime")
            ]
            var request = URLRequest(url: urlComponents.url!)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTaskPublisher(for: request)
                .map { $0.data }
                .decode(type: GoogleCalendarEventsResponse.self, decoder: JSONDecoder())
                .map { $0.items.map { $0.toGoogleCalendarEvent() } }
                .replaceError(with: [])
                .receive(on: DispatchQueue.main)
                .sink { [weak self] events in
                    self?.events = events
                }
                .store(in: &self.cancellables)
        }
    }
}

// MARK: - Google Calendar API Response Models

struct GoogleCalendarEventsResponse: Decodable {
    let items: [GoogleCalendarEventItem]
}

struct GoogleCalendarEventItem: Decodable {
    let id: String
    let summary: String?
    let start: GoogleCalendarEventDate
    let end: GoogleCalendarEventDate
    let colorId: String?
    let recurrence: [String]?
    let conferenceData: GoogleCalendarConferenceData?
    let attendees: [GoogleCalendarAttendeeItem]?
    let organizer: GoogleCalendarAttendeeItem?
    let creator: GoogleCalendarAttendeeItem?
}

struct GoogleCalendarEventDate: Decodable {
    let dateTime: String?
    let date: String?
}

struct GoogleCalendarConferenceData: Decodable {
    let entryPoints: [GoogleCalendarEntryPoint]?
}

struct GoogleCalendarEntryPoint: Decodable {
    let entryPointType: String?
    let uri: String?
}

struct GoogleCalendarAttendeeItem: Decodable {
    let email: String
    let displayName: String?
    let responseStatus: String?
    let selfAttendee: Bool?
    let photoUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case email, displayName, responseStatus, selfAttendee = "self", photoUrl
    }
}

// MARK: - Mapping

extension GoogleCalendarEventItem {
    func toGoogleCalendarEvent() -> GoogleCalendarEvent {
        let dateFormatter = ISO8601DateFormatter()
        let startDate = start.dateTime.flatMap { dateFormatter.date(from: $0) } ?? start.date.flatMap { dateFormatter.date(from: $0) } ?? Date()
        let endDate = end.dateTime.flatMap { dateFormatter.date(from: $0) } ?? end.date.flatMap { dateFormatter.date(from: $0) } ?? Date()
        let attendeesList = attendees?.map {
            GoogleCalendarAttendee(
                id: $0.email,
                name: $0.displayName,
                email: $0.email,
                responseStatus: $0.responseStatus ?? "needsAction",
                photoUrl: $0.photoUrl
            )
        } ?? []
        let myResponse = attendees?.first(where: { $0.selfAttendee == true })?.responseStatus
        let videoLink = conferenceData?.entryPoints?.first(where: { $0.entryPointType == "video" })?.uri
        return GoogleCalendarEvent(
            id: id,
            title: summary ?? "(No Title)",
            start: startDate,
            end: endDate,
            colorId: colorId,
            recurrence: recurrence,
            videoLink: videoLink,
            attendees: attendeesList,
            myResponse: myResponse
        )
    }
} 