import SwiftUI

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