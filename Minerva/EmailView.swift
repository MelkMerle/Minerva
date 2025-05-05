import SwiftUI

struct EmailView: View {
    var body: some View {
        Text("Email")
            .font(.title)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignSystem.backgroundColor)
    }
} 