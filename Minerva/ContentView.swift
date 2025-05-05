//
//  ContentView.swift
//  Minerva
//
//  Created by Melchior Merlin on 28/04/2025.
//

import SwiftUI

enum MainSection {
    case today, calendar, email, todo, settings
}

struct ContentView: View {
    @State private var selectedSection: MainSection = .today
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(spacing: 24) {
                sidebarButton(icon: "house", section: .today)
                sidebarButton(icon: "calendar", section: .calendar)
                sidebarButton(icon: "envelope", section: .email)
                sidebarButton(icon: "checkmark.square", section: .todo)
                Spacer()
                sidebarButton(icon: "gearshape", section: .settings)
            }
            .padding(.vertical, 32)
            .frame(width: DesignSystem.sidebarWidth)
            .background(DesignSystem.sidebarColor)
            
            Divider()
            
            // Main Content
            ZStack {
                switch selectedSection {
                case .today:
                    TodayView()
                case .calendar:
                    CalendarView()
                case .email:
                    EmailView()
                case .todo:
                    TodoView()
                case .settings:
                    SettingsRootView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignSystem.backgroundColor)
        }
    }
    
    @ViewBuilder
    private func sidebarButton(icon: String, section: MainSection) -> some View {
        Button(action: { selectedSection = section }) {
            ZStack {
                if selectedSection == section {
                    RoundedRectangle(cornerRadius: DesignSystem.cornerRadius)
                        .fill(DesignSystem.sidebarSelectedColor)
                        .frame(width: 44, height: 44)
                        .shadow(color: DesignSystem.primaryColor.opacity(0.08), radius: 4, x: 0, y: 2)
                }
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(selectedSection == section ? DesignSystem.primaryColor : DesignSystem.sidebarIconColor)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Placeholder Views

struct TodayView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text(Date(), style: .date)
                .font(.largeTitle)
                .bold()
                .padding(.top, 32)
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

struct CalendarView: View {
    // Dummy event and task data
    struct Event: Identifiable {
        let id = UUID()
        let title: String
        let start: Date
        let end: Date
        let color: Color
    }
    struct Task: Identifiable {
        let id = UUID()
        let title: String
    }
    
    // Generate dummy events for the current week
    private var events: [Event] {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        return [
            Event(title: "Design Sync", start: calendar.date(byAdding: .hour, value: 10, to: startOfWeek)!, end: calendar.date(byAdding: .hour, value: 11, to: startOfWeek)!, color: Color(red: 0.36, green: 0.54, blue: 0.96)), // blue
            Event(title: "1:1 Meeting", start: calendar.date(byAdding: .day, value: 2, to: calendar.date(byAdding: .hour, value: 14, to: startOfWeek)!)!, end: calendar.date(byAdding: .day, value: 2, to: calendar.date(byAdding: .hour, value: 15, to: startOfWeek)!)!, color: Color(red: 0.98, green: 0.77, blue: 0.36)), // yellow
            Event(title: "Project Review", start: calendar.date(byAdding: .day, value: 4, to: calendar.date(byAdding: .hour, value: 9, to: startOfWeek)!)!, end: calendar.date(byAdding: .day, value: 4, to: calendar.date(byAdding: .hour, value: 10, to: startOfWeek)!)!, color: Color(red: 0.98, green: 0.36, blue: 0.36)) // red
        ]
    }
    private let tasks: [Task] = [
        Task(title: "Write project update"),
        Task(title: "Review PR #42"),
        Task(title: "Plan next sprint"),
        Task(title: "Check shadow docs"),
        Task(title: "Organize meeting"),
        Task(title: "Review API changes")
    ]
    
    @State private var selectedEvent: Event? = nil
    @State private var showSidebar: Bool = false
    
    private let hours = Array(0...23) // 00:00 to 23:00
    private let hourHeight: CGFloat = 80
    private let defaultScrollHour = 9 // 9AM
    
    @State private var scrollProxy: ScrollViewProxy?
    
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
                                            ForEach(events) { event in
                                                if calendar.isDate(event.start, inSameDayAs: day) && calendar.component(.hour, from: event.start) == hour {
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .fill(event.color.opacity(0.18))
                                                        .frame(height: hourHeight - 8)
                                                        .overlay(
                                                            Text(event.title)
                                                                .font(.system(size: 13, weight: .medium))
                                                                .foregroundColor(event.color.darken(by: 0.5))
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
    }
}

// MARK: - Event Detail Sidebar (dummy data)

struct EventDetailSidebarView: View {
    let event: CalendarView.Event
    var onClose: () -> Void
    
    // Dummy data for now
    let recurrence = "Every 4 weeks"
    let videoLink = "https://zoom.us/j/123456789"
    @State private var myResponse: String = "yes" // "yes", "no", "maybe"
    struct Attendee: Identifiable {
        let id = UUID()
        let name: String
        let email: String
        let avatar: Image?
        let initials: String
        let response: String // "yes", "no", "maybe"
    }
    let attendees: [Attendee] = [
        Attendee(name: "You", email: "melchior.merlin@launchmetrics.com", avatar: Image("avatar1"), initials: "MM", response: "yes"),
        Attendee(name: "Andrea Sozzo", email: "andrea.sozzo@launchmetrics.com", avatar: Image("avatar2"), initials: "AS", response: "yes"),
        Attendee(name: "Cristina Santamarina", email: "cristina.santamarina@launchmetrics.com", avatar: nil, initials: "CS", response: "yes"),
        Attendee(name: "Joan Albert Fontàs", email: "joanalbert.fontas@launchmetrics.com", avatar: nil, initials: "JF", response: "yes"),
        Attendee(name: "Leslie Tou", email: "leslie.tou@launchmetrics.com", avatar: nil, initials: "LT", response: "yes"),
        Attendee(name: "Yukti Joshi", email: "yukti.joshi@launchmetrics.com", avatar: nil, initials: "YJ", response: "yes"),
        Attendee(name: "Diego Covarrubias", email: "diego.covarrubias@launchmetrics.com", avatar: nil, initials: "DC", response: "yes"),
        Attendee(name: "Margot Sylvain", email: "margot.sylvain@launchmetrics.com", avatar: nil, initials: "MS", response: "no"),
        Attendee(name: "Mathilde Gomez", email: "mathilde.gomez@launchmetrics.com", avatar: nil, initials: "MG", response: "no"),
        Attendee(name: "Jeremy Doucet", email: "jeremy.doucet@launchmetrics.com", avatar: nil, initials: "JD", response: "no"),
        Attendee(name: "Margot LASSEIGNE", email: "margot.lasseigne@launchmetrics.com", avatar: nil, initials: "ML", response: "maybe"),
        Attendee(name: "Arnaud Roy", email: "arnaud.roy@launchmetrics.com", avatar: nil, initials: "AR", response: "yes")
    ]
    
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
            HStack(spacing: 12) {
                Image(systemName: "repeat")
                Text(recurrence)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding(.bottom, 4)
            Button(action: { if let url = URL(string: videoLink) { NSWorkspace.shared.open(url) } }) {
                HStack(spacing: 8) {
                    Circle().fill(event.color).frame(width: 10, height: 10)
                    Text("Join Zoom meeting")
                        .underline()
                }
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)
            Divider().padding(.vertical, 8)
            // Attendance
            Text("Your response:")
                .font(.subheadline)
                .padding(.bottom, 4)
            HStack(spacing: 8) {
                ForEach(["yes", "no", "maybe"], id: \ .self) { resp in
                    Button(action: { myResponse = resp }) {
                        Text(resp.capitalized)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(myResponse == resp ? (resp == "yes" ? Color.green.opacity(0.2) : resp == "no" ? Color.red.opacity(0.2) : Color.yellow.opacity(0.2)) : Color.clear)
                            )
                            .foregroundColor(myResponse == resp ? (resp == "yes" ? .green : resp == "no" ? .red : .yellow) : .primary)
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
                    ForEach(attendees) { attendee in
                        HStack(spacing: 10) {
                            if let avatar = attendee.avatar {
                                avatar
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                            } else {
                                ZStack {
                                    Circle().fill(Color.gray.opacity(0.2)).frame(width: 32, height: 32)
                                    Text(attendee.initials)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.secondary)
                                }
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(attendee.name)
                                    .font(.system(size: 15, weight: .medium))
                                Text(attendee.email)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if attendee.response == "yes" {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            } else if attendee.response == "no" {
                                Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                            } else {
                                Image(systemName: "questionmark.circle.fill").foregroundColor(.yellow)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 8)
            Spacer()
            Divider()
            Text("Add participant...")
                .foregroundColor(.secondary)
                .padding(.vertical, 8)
            Divider()
            Text("Add description...")
                .foregroundColor(.secondary)
                .padding(.vertical, 8)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
    }
}

// Helper extension for color darkening
extension Color {
    func darken(by percentage: CGFloat) -> Color {
        let uiColor = NSColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return Color(red: max(r - percentage, 0), green: max(g - percentage, 0), blue: max(b - percentage, 0))
    }
}

struct EmailView: View { var body: some View { Text("Email").padding() } }
struct TodoView: View { var body: some View { Text("To Do").padding() } }

// MARK: - Settings Root View

struct SettingsRootView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: SettingsIntegrationsView()) {
                    Label("Integrations", systemImage: "puzzlepiece.extension")
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 300)
            .navigationTitle("Settings")
            Text("Select a setting from the sidebar")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
