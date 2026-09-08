import SwiftUI

/// Glassmorphism 2.0 Container View featuring dynamic light/dark translucent frosted glass, crisp borders, and soft shadows
struct GlassCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 16
    var content: () -> Content
    
    init(cornerRadius: CGFloat = 20, padding: CGFloat = 16, @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: colorScheme == .dark ? [
                                        Color.white.opacity(0.22),
                                        Color.white.opacity(0.05)
                                    ] : [
                                        Color.white,
                                        Color.blue.opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    )
            )
            .shadow(
                color: colorScheme == .dark ? Color.black.opacity(0.4) : Color(red: 0.1, green: 0.15, blue: 0.25).opacity(0.08),
                radius: 12,
                x: 0,
                y: 6
            )
    }
}

/// Floating action button to toggle between Light (Day), Dark (Night), and System Theme Modes
struct ThemePickerButton: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("appThemeMode") private var appThemeMode: String = "system"
    
    var iconName: String {
        switch appThemeMode {
        case "light": return "sun.max.fill"
        case "dark": return "moon.stars.fill"
        default: return "sparkles"
        }
    }
    
    var iconColor: Color {
        switch appThemeMode {
        case "light": return .orange
        case "dark": return .indigo
        default: return .cyan
        }
    }
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                if appThemeMode == "system" {
                    appThemeMode = "light"
                } else if appThemeMode == "light" {
                    appThemeMode = "dark"
                } else {
                    appThemeMode = "system"
                }
            }
        } label: {
            ZStack {
                Circle()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.15) : Color.white.opacity(0.85))
                    .frame(width: 40, height: 40)
                    .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
                    .overlay(Circle().stroke(colorScheme == .dark ? Color.white.opacity(0.2) : Color.white, lineWidth: 1))
                
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(iconColor)
            }
        }
    }
}


