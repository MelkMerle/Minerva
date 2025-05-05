import SwiftUI

// Helper extension for color darkening
extension Color {
    func darken(by percentage: CGFloat) -> Color {
        let uiColor = NSColor(self)
        guard let rgbColor = uiColor.usingColorSpace(.deviceRGB) else {
            return self // fallback to original color if conversion fails
        }
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        rgbColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return Color(red: max(r - percentage, 0), green: max(g - percentage, 0), blue: max(b - percentage, 0))
    }
}

// Google Calendar color palette mapping (Google's default event colors)
let googleCalendarColors: [String: Color] = [
    "1": Color(red: 0.44, green: 0.62, blue: 0.80), // Blue
    "2": Color(red: 0.91, green: 0.49, blue: 0.13), // Orange
    "3": Color(red: 0.91, green: 0.33, blue: 0.23), // Red
    "4": Color(red: 0.60, green: 0.60, blue: 0.60), // Gray
    "5": Color(red: 0.36, green: 0.69, blue: 0.36), // Green
    "6": Color(red: 0.56, green: 0.35, blue: 0.64), // Purple
    "7": Color(red: 0.16, green: 0.50, blue: 0.73), // Dark Blue
    "8": Color(red: 0.80, green: 0.60, blue: 0.20), // Brown
    "9": Color(red: 0.80, green: 0.40, blue: 0.60), // Pink
    "10": Color(red: 0.27, green: 0.67, blue: 0.80), // Teal
    "11": Color(red: 0.80, green: 0.80, blue: 0.20) // Yellow
]

struct CalendarView: View {
    struct Task: Identifiable {
        let id = UUID()
        let title: String
    }
    
    @StateObject private var calendarService = GoogleCalendarService(authService: GoogleAuthService())
    @State private var selectedEvent: GoogleCalendarEvent? = nil
    @State private var showSidebar: Bool = false
    private let hours = Array(0...23) // 00:00 to 23:00
    private let hourHeight: CGFloat = 80
    private let defaultScrollHour = 9 // 9AM
    @State private var scrollProxy: ScrollViewProxy?
    
    private let tasks: [Task] = [
        Task(title: "Write project update"),
        Task(title: "Review PR #42"),
        Task(title: "Plan next sprint"),
        Task(title: "Check shadow docs"),
        Task(title: "Organize meeting"),
        Task(title: "Review API changes")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            // Tasks sidebar
            VStack(alignment: .leading, spacing: 6) {
                Text("TASKS")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 16)
                ForEach(tasks) { task in
                    HStack(spacing: 8) {
                        Image(systemName: "square")
                            .foregroundColor(DesignSystem.sidebarIconColor)
                        Text(task.title)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(DesignSystem.primaryColor)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Spacer()
                    }
                    .padding(.vertical, 2)
                }
                Spacer()
            }
            .frame(width: 200)
            .background(DesignSystem.backgroundColor)
            .padding(.trailing, 1)
            
            // Calendar grid
            VStack(spacing: 0) {
                // Weekday headers
                let calendar = Calendar.current
                let today = Date()
                let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
                let days = (0..<7).map { calendar.date(byAdding: .day, value: $0, to: startOfWeek)! }
                HStack(spacing: 0) {
                    Spacer().frame(width: 44) // For hour column
                    ForEach(days, id: \ .self) { day in
                        VStack {
                            Text(day, format: .dateTime.weekday(.abbreviated))
                                .font(.headline)
                            Text(day, format: .dateTime.day())
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                }
                Divider()
                // Hours grid
                ScrollViewReader { proxy in
                    ScrollView([.vertical]) {
                        VStack(spacing: 0) {
                            ForEach(hours, id: \ .self) { hour in
                                HStack(spacing: 0) {
                                    // Hour label
                                    Text(String(format: "%02d:00", hour))
                                        .font(.system(size: 13, weight: .regular, design: .monospaced))
                                        .foregroundColor(.secondary)
                                        .frame(width: 44, alignment: .trailing)
                                        .padding(.trailing, 4)
                                    ForEach(days, id: \ .self) { day in
                                        ZStack {
                                            Rectangle()
                                                .fill(Color.white.opacity(0.001))
                                            // Render event blocks
                                            ForEach(calendarService.events) { event in
                                                if calendar.isDate(event.start, inSameDayAs: day) && calendar.component(.hour, from: event.start) == hour {
                                                    let color = event.colorId.flatMap { googleCalendarColors[$0] } ?? DesignSystem.primaryColor
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .fill(color.opacity(0.18))
                                                        .frame(height: hourHeight - 8)
                                                        .overlay(
                                                            Text(event.title)
                                                                .font(.system(size: 13, weight: .medium))
                                                                .foregroundColor(color.darken(by: 0.5))
                                                                .padding(.horizontal, 8), alignment: .leading
                                                        )
                                                        .padding(.vertical, 2)
                                                        .padding(.horizontal, 2)
                                                        .onTapGesture {
                                                            selectedEvent = event
                                                            showSidebar = true
                                                        }
                                                }
                                            }
                                        }
                                        .frame(maxWidth: .infinity, minHeight: hourHeight, maxHeight: hourHeight)
                                        .border(Color.gray.opacity(0.08), width: 0.5)
                                    }
                                }
                                .id(hour)
                            }
                        }
                        .padding(.bottom, 12)
                    }
                    .onAppear {
                        // Scroll to 9AM by default
                        DispatchQueue.main.async {
                            proxy.scrollTo(defaultScrollHour, anchor: .top)
                        }
                    }
                }
            }
            .background(DesignSystem.backgroundColor)
            .cornerRadius(DesignSystem.cornerRadius)
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            
            // Event details sidebar
            if showSidebar, let event = selectedEvent {
                Divider()
                EventDetailSidebarView(event: event, onClose: { showSidebar = false })
                    .frame(width: 340)
                    .transition(.move(edge: .trailing))
            }
        }
        .background(DesignSystem.backgroundColor)
        .padding(.top, 8)
        .padding(.horizontal, 8)
        .onAppear {
            // Fetch events for the current week
            let calendar = Calendar.current
            let today = Date()
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
            let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
            calendarService.fetchEvents(start: startOfWeek, end: endOfWeek)
        }
    }
} 