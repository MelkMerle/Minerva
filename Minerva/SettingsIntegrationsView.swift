import SwiftUI

struct SettingsIntegrationsView: View {
    @StateObject private var googleAuth = GoogleAuthService()
    @State private var showSignInError = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Integrations")
                .font(.largeTitle)
                .bold()
            Divider()
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                VStack(alignment: .leading) {
                    Text("Google Calendar")
                        .font(.headline)
                    if googleAuth.isSignedIn {
                        Text("Signed in as \(googleAuth.userEmail ?? "")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Button("Sign Out") {
                            googleAuth.signOut()
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("Sign in with Google") {
                            if let window = NSApplication.shared.keyWindow {
                                googleAuth.signIn(presentingWindow: window)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            if let error = googleAuth.error {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            }
            Spacer()
        }
        .padding()
        .frame(minWidth: 400, minHeight: 250)
    }
}

#Preview {
    SettingsIntegrationsView()
} 