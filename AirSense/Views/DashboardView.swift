import SwiftUI
import SwiftData

/// Tab 1: Live Air Quality Dashboard (Header location, Canvas gauge, Air Dragon mascot, Health cards)
struct DashboardView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @AppStorage("appLanguage") private var appLanguage: String = "th"
    @ObservedObject var viewModel: AirSenseViewModel
    @StateObject private var locationManager = LocationManager()
    
    private var isThai: Bool { appLanguage == "th" }
    
    var body: some View {
        ZStack {
            // Ambient Particles Background
            ParticleBackgroundView(severity: viewModel.currentSeverity)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header Location Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(viewModel.currentSeverity.primaryColor)
                                
                                Text(viewModel.locationDisplayName)
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.1, green: 0.15, blue: 0.25))
                            }
                            
                            Text(isThai ? "เรดาร์คุณภาพอากาศสด GPS" : "LIVE GPS AIR RADAR")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(red: 0.45, green: 0.5, blue: 0.6))
                                .tracking(1.2)
                        }
                        
                        Spacer()
                        
                        // Location Refresh Button
                        Button {
                                locationManager.requestLocation()
                                Task {
                                    if let loc = locationManager.userLocation {
                                        await viewModel.fetchCurrentAQI(latitude: loc.latitude, longitude: loc.longitude, modelContext: modelContext)
                                    } else {
                                        await viewModel.fetchCurrentAQI(modelContext: modelContext)
                                    }
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(colorScheme == .dark ? Color.white.opacity(0.15) : Color.white.opacity(0.85))
                                        .frame(width: 40, height: 40)
                                        .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
                                        .overlay(Circle().stroke(colorScheme == .dark ? Color.white.opacity(0.2) : Color.white, lineWidth: 1))
                                    
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .tint(viewModel.currentSeverity.primaryColor)
                                    } else {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.15, green: 0.2, blue: 0.3))
                                    }
                                }
                            }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Offline Mode Warning Banner
                    if viewModel.isOfflineMode {
                        HStack(spacing: 8) {
                            Image(systemName: "wifi.slash")
                                .foregroundColor(.orange)
                            Text(isThai ? "โหมดออฟไลน์ — แสดงข้อมูลย้อนหลังในเครื่อง" : "Offline Mode — Displaying cached local data")
                                .font(.system(size: 11.5, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.2, green: 0.25, blue: 0.35))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.orange.opacity(0.15)))
                    }
                    
                    // Centerpiece: Circular Gauge & Air Dragon Mascot Side-by-Side
                    VStack(spacing: 15) {
                        HStack(alignment: .center, spacing: 10) {
                            AQICircularGauge(aqi: viewModel.currentAQI, severity: viewModel.currentSeverity)
                                .scaleEffect(0.95)
                            
                            AirDragonMascotView(severity: viewModel.currentSeverity)
                        }
                    }
                    .padding(.vertical, 10)
                    
                    // Key Pollutants Mini Grid
                    GlassCard(cornerRadius: 22, padding: 16) {
                        VStack(spacing: 12) {
                            HStack {
                                Text(isThai ? "สารมลพิษในอากาศ" : "POLLUTANT BREAKDOWN")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(red: 0.45, green: 0.5, blue: 0.6))
                                    .tracking(1.2)
                                Spacer()
                            }
                            
                            HStack(spacing: 12) {
                                PollutantPill(name: "PM2.5", value: String(format: "%.1f", viewModel.currentAQIData?.pm25Value ?? 65.4), unit: "µg/m³", color: viewModel.currentSeverity.primaryColor)
                                PollutantPill(name: "PM10", value: String(format: "%.1f", viewModel.currentAQIData?.pm10Value ?? 88.2), unit: "µg/m³", color: Color(red: 0.85, green: 0.55, blue: 0.0))
                                PollutantPill(name: "O3", value: String(format: "%.1f", viewModel.currentAQIData?.o3Value ?? 14.2), unit: "ppb", color: Color(red: 0.0, green: 0.55, blue: 0.75))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Actionable Health Advice Cards Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(isThai ? "ข้อแนะนำในการปฏิบัติตน" : "HEALTH RECOMMENDATIONS")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(red: 0.45, green: 0.5, blue: 0.6))
                                .tracking(1.2)
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(spacing: 10) {
                            ForEach(viewModel.currentSeverity.healthAdviceList(isThai: isThai)) { advice in
                                HealthAdviceCard(item: advice, severity: viewModel.currentSeverity)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 100) // Padding for floating bottom tab bar
                }
            }
        }
        .task {
            locationManager.requestLocation()
            await viewModel.fetchCurrentAQI(modelContext: modelContext)
        }
    }
}

