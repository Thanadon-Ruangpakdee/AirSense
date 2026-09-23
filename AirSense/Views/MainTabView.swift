import SwiftUI

/// Main Glassmorphic Container View featuring a floating glass bottom navigation bar with 5 tabs (including Settings)
struct MainTabView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel = AirSenseViewModel()
    @State private var selectedTab: Int = 0
    @AppStorage("appLanguage") private var appLanguage: String = "th"
    
    private var isThai: Bool { appLanguage == "th" }
    
    var body: some View {
        ZStack(alignment: .top) {
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
            
            // In-App Interactive Floating Banner Alert
            if viewModel.showNotificationBanner {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.red)
                        .padding(10)
                        .background(Circle().fill(Color.red.opacity(0.15)))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(viewModel.bannerTitle)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(white: 0.1))
                            
                            Spacer()
                            
                            Text("NOW")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color.gray)
                        }
                        
                        Text(viewModel.bannerMessage)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.8) : Color(white: 0.3))
                            .lineLimit(3)
                    }
                    
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            viewModel.showNotificationBanner = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color.gray.opacity(0.6))
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .shadow(color: Color.black.opacity(0.18), radius: 20, x: 0, y: 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(LinearGradient(colors: [.red.opacity(0.6), .orange.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                        )
                )
                .padding(.horizontal, 16)
                .padding(.top, 50)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(999)
            }
        }
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
