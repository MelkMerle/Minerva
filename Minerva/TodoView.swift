import SwiftUI

struct TodoView: View {
    var body: some View {
        Text("To Do")
            .font(.title)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignSystem.backgroundColor)
    }
} 