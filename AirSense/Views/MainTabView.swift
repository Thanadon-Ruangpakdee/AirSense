import SwiftUI

/// Main Glassmorphic Container View featuring a floating glass bottom navigation bar with 5 tabs (including Settings)
struct MainTabView: View {
    @StateObject private var viewModel = AirSenseViewModel()
    @State private var selectedTab: Int = 0
    @AppStorage("appLanguage") private var appLanguage: String = "th"
    
    private var isThai: Bool { appLanguage == "th" }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Tab Content Screens
            Group {
                switch selectedTab {
                case 0:
                    DashboardView(viewModel: viewModel)
                case 1:
                    SavedPlacesView(viewModel: viewModel)
                case 2:
                    LocationAnalyticsView(viewModel: viewModel)
                case 3:
                    ExposureHistoryView(viewModel: viewModel)
                case 4:
                    SettingsView(viewModel: viewModel)
                default:
                    DashboardView(viewModel: viewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Floating Glass Bottom Navigation Bar (5 Tabs)
            HStack(spacing: 0) {
                TabButton(icon: "house.fill", label: isThai ? "หน้าหลัก" : "Home", index: 0, selectedTab: $selectedTab, accentColor: viewModel.currentSeverity.primaryColor)
                TabButton(icon: "bookmark.fill", label: isThai ? "สถานที่" : "Places", index: 1, selectedTab: $selectedTab, accentColor: viewModel.currentSeverity.primaryColor)
                TabButton(icon: "chart.xyaxis.line", label: isThai ? "วิเคราะห์" : "Analytics", index: 2, selectedTab: $selectedTab, accentColor: viewModel.currentSeverity.primaryColor)
                TabButton(icon: "calendar", label: isThai ? "ประวัติ" : "History", index: 3, selectedTab: $selectedTab, accentColor: viewModel.currentSeverity.primaryColor)
                TabButton(icon: "gearshape.fill", label: isThai ? "ตั้งค่า" : "Settings", index: 4, selectedTab: $selectedTab, accentColor: viewModel.currentSeverity.primaryColor)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(.regularMaterial)
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.8),
                                        Color.white.opacity(0.3)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1.5
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 6)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct TabButton: View {
    var icon: String
    var label: String
    var index: Int
    @Binding var selectedTab: Int
    var accentColor: Color
    
    var isSelected: Bool {
        selectedTab == index
    }
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: isSelected ? 18 : 16, weight: .bold))
                    .foregroundColor(isSelected ? accentColor : Color(white: 0.50))
                    .scaleEffect(isSelected ? 1.12 : 1.0)
                
                Text(label)
                    .font(.system(size: 9, weight: isSelected ? .heavy : .semibold, design: .rounded))
                    .foregroundColor(isSelected ? accentColor : Color(white: 0.50))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                // Animated Line Indicator under selected tab
                Capsule()
                    .fill(isSelected ? accentColor : Color.clear)
                    .frame(width: isSelected ? 14 : 0, height: 2.5)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
