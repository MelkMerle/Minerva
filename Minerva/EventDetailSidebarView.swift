import SwiftUI

struct EventDetailSidebarView: View {
    let event: GoogleCalendarEvent
    var onClose: () -> Void
    
    @State private var myResponse: String
    
    init(event: GoogleCalendarEvent, onClose: @escaping () -> Void) {
        self.event = event
        self.onClose = onClose
        _myResponse = State(initialValue: event.myResponse ?? "needsAction")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                        .padding(8)
                }
                .buttonStyle(.plain)
            }
            Text(event.title)
                .font(.title2).bold()
                .padding(.bottom, 8)
            HStack(spacing: 12) {
                Image(systemName: "clock")
                Text(event.start, format: .dateTime.month().day())
                Text(event.start, format: .dateTime.hour().minute())
                Text("-")
                Text(event.end, format: .dateTime.hour().minute())
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding(.bottom, 4)
            if let recurrence = event.recurrence?.first {
                HStack(spacing: 12) {
                    Image(systemName: "repeat")
                    Text(recurrence)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 4)
            }
            if let videoLink = event.videoLink {
                Button(action: { if let url = URL(string: videoLink) { NSWorkspace.shared.open(url) } }) {
                    HStack(spacing: 8) {
                        Circle().fill((event.colorId.flatMap { googleCalendarColors[$0] }) ?? .blue).frame(width: 10, height: 10)
                        Text("Join Video Call")
                            .underline()
                    }
                }
                .buttonStyle(.plain)
                .padding(.bottom, 8)
            }
            Divider().padding(.vertical, 8)
            // Attendance
            Text("Your response:")
                .font(.subheadline)
                .padding(.bottom, 4)
            HStack(spacing: 8) {
                ForEach(["accepted", "declined", "tentative"], id: \ .self) { resp in
                    Button(action: { myResponse = resp }) {
                        Text(resp.capitalized)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(myResponse == resp ? (resp == "accepted" ? Color.green.opacity(0.2) : resp == "declined" ? Color.red.opacity(0.2) : Color.yellow.opacity(0.2)) : Color.clear)
                            )
                            .foregroundColor(myResponse == resp ? (resp == "accepted" ? .green : resp == "declined" ? .red : .yellow) : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 8)
            Divider().padding(.vertical, 8)
            // Attendees
            Text("Attendees:")
                .font(.subheadline)
                .padding(.bottom, 4)
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(event.attendees) { attendee in
                        HStack(spacing: 10) {
                            if let photoUrl = attendee.photoUrl, let url = URL(string: photoUrl) {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Circle().fill(Color.gray.opacity(0.2))
                                }
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                            } else {
                                ZStack {
                                    Circle().fill(Color.gray.opacity(0.2)).frame(width: 32, height: 32)
                                    Text(initials(for: attendee))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.secondary)
                                }
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(attendee.name ?? attendee.email)
                                    .font(.system(size: 15, weight: .medium))
                                Text(attendee.email)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if attendee.responseStatus == "accepted" {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            } else if attendee.responseStatus == "declined" {
                                Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                            } else if attendee.responseStatus == "tentative" {
                                Image(systemName: "questionmark.circle.fill").foregroundColor(.yellow)
                            } else {
                                Image(systemName: "circle").foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 8)
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
    }
    
    private func initials(for attendee: GoogleCalendarAttendee) -> String {
        if let name = attendee.name, !name.isEmpty {
            let comps = name.split(separator: " ")
            if comps.count >= 2 {
                return String(comps[0].prefix(1)) + String(comps[1].prefix(1))
            } else if let first = comps.first {
                return String(first.prefix(2))
            }
        }
        return String(attendee.email.prefix(2)).uppercased()
    }
} 