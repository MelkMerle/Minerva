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
