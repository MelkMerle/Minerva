import SwiftUI

struct DesignSystem {
    // Colors
    static let primaryColor = Color("PrimaryColor")
    static let secondaryColor = Color("SecondaryColor")
    static let backgroundColor = Color("BackgroundColor")
    static let sidebarColor = Color("SidebarColor")
    static let accentColor = Color.accentColor
    static let sidebarSelectedColor = Color("SidebarSelectedColor")
    static let sidebarIconColor = Color("SidebarIconColor")
    static let errorColor = Color.red
    
    // Spacing & Layout
    static let sidebarWidth: CGFloat = 68
    static let cornerRadius: CGFloat = 12
    static let padding: CGFloat = 20
}

// MARK: - Color Assets
// Add these colors to your Assets.xcassets:
// - PrimaryColor: #2D3142 (dark blue)
// - SecondaryColor: #BFC0C0 (light gray)
// - BackgroundColor: #F7F7FF (off white)
// - SidebarColor: #E5E9F2 (light blue-gray)
// - SidebarSelectedColor: #FFFFFF (white or slightly blue-tinted)
// - SidebarIconColor: #4F5D75 (muted blue) 