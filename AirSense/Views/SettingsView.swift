import SwiftUI

/// Tab 5: Settings Screen with Language Selection (Thai/English), Day/Night Theme Mode & App Info
struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: AirSenseViewModel
    
    @AppStorage("appLanguage") private var appLanguage: String = "th"
    @AppStorage("appThemeMode") private var appThemeMode: String = "system"
    
    private var isThai: Bool { appLanguage == "th" }
    
    var body: some View {
        ZStack {
            ParticleBackgroundView(severity: viewModel.currentSeverity)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(isThai ? "ตั้งค่าระบบ" : "SETTINGS")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(white: 0.12))
                            
                            Text("PREFERENCES & CONFIGURATION")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(white: 0.45))
                                .tracking(1.2)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // 1. Language Selection Section (เลือกภาษา)
                    GlassCard(cornerRadius: 22, padding: 18) {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Image(systemName: "globe")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.blue)
                                
                                Text(isThai ? "ภาษาของแอปพลิเคชัน" : "APPLICATION LANGUAGE")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(white: 0.4))
                                    .tracking(1.0)
                            }
                            
                            HStack(spacing: 12) {
                                // Thai Button
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        appLanguage = "th"
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        Text("🇹🇭")
                                            .font(.system(size: 20))
                                        Text("ภาษาไทย")
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                    }
                                    .foregroundColor(appLanguage == "th" ? .white : (colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7)))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(appLanguage == "th" ? Color.blue : (colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05)))
                                            .shadow(color: appLanguage == "th" ? Color.blue.opacity(0.3) : Color.clear, radius: 6, x: 0, y: 3)
                                    )
                                }
                                
                                // English Button
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        appLanguage = "en"
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        Text("🇺🇸")
                                            .font(.system(size: 20))
                                        Text("English")
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                    }
                                    .foregroundColor(appLanguage == "en" ? .white : (colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7)))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(appLanguage == "en" ? Color.blue : (colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05)))
                                            .shadow(color: appLanguage == "en" ? Color.blue.opacity(0.3) : Color.clear, radius: 6, x: 0, y: 3)
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // 2. Day / Night Mode Theme Section (ธีมสว่าง / มืด)
                    GlassCard(cornerRadius: 22, padding: 18) {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Image(systemName: appThemeMode == "dark" ? "moon.stars.fill" : (appThemeMode == "light" ? "sun.max.fill" : "circle.righthalf.filled"))
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(appThemeMode == "dark" ? .purple : .orange)
                                
                                Text(isThai ? "โหมดการแสดงผล (DAY / NIGHT)" : "APPEARANCE MODE")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(white: 0.4))
                                    .tracking(1.0)
                            }
                            
                            HStack(spacing: 8) {
                                ThemeButton(title: isThai ? "อัตโนมัติ" : "System", icon: "iphone", mode: "system", currentMode: $appThemeMode)
                                ThemeButton(title: isThai ? "กลางวัน" : "Light", icon: "sun.max.fill", mode: "light", currentMode: $appThemeMode)
                                ThemeButton(title: isThai ? "กลางคืน" : "Dark", icon: "moon.fill", mode: "dark", currentMode: $appThemeMode)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // 3. App Info & Version Section
                    GlassCard(cornerRadius: 22, padding: 18) {
                        VStack(spacing: 12) {
                            Image(systemName: "wind.snow")
                                .font(.system(size: 32))
                                .foregroundColor(.cyan)
                            
                            Text("AirSense Pro")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(white: 0.15))
                            
                            Text(isThai ? "เวอร์ชัน 2.4.0 • ระบบเฝ้าระวังคุณภาพอากาศและฝุ่น PM2.5" : "Version 2.4.0 • Personal Air Quality & PM2.5 Exposure Tracker")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(white: 0.45))
                                .multilineTextAlignment(.center)
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            HStack {
                                Text("Data Provided by WAQI & OpenAQ")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.5) : Color(white: 0.5))
                                Spacer()
                                Text("iOS 17.0+")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

/// Helper button for Theme selection (System / Light / Dark)
struct ThemeButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let icon: String
    let mode: String
    @Binding var currentMode: String
    
    var isSelected: Bool { currentMode == mode }
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                currentMode = mode
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : (colorScheme == .dark ? .white.opacity(0.7) : Color(white: 0.3)))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : (colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05)))
            )
        }
    }
}
