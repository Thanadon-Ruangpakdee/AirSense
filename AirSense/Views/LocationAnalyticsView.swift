import SwiftUI
import SwiftData
import Charts

/// Tab 3: Detailed Pollutants & Swift Charts 7-Day Trend Visualization Screen
struct LocationAnalyticsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @AppStorage("appLanguage") private var appLanguage: String = "th"
    
    @ObservedObject var viewModel: AirSenseViewModel
    
    private var isThai: Bool { appLanguage == "th" }
    
    var sampleChartData: [ChartDataPoint] {
        viewModel.forecastChartDataPoints
    }
    
    var body: some View {
        ZStack {
            ParticleBackgroundView(severity: viewModel.currentSeverity)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(isThai ? "วิเคราะห์คุณภาพอากาศ" : "AIR ANALYTICS")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(white: 0.12))
                            
                            Text(isThai ? "ตำแหน่ง: \(viewModel.locationDisplayName)" : "\(viewModel.locationDisplayName.uppercased())")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(white: 0.45))
                                .tracking(1.2)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Swift Charts 7-Day Forecast Graph
                    GlassCard(cornerRadius: 22, padding: 18) {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .foregroundColor(viewModel.currentSeverity.primaryColor)
                                Text(isThai ? "พยากรณ์ AQI 7 วันล่วงหน้า (WAQI FORECAST)" : "7-DAY AQI FORECAST (WAQI API)")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(white: 0.40))
                                    .tracking(1.2)
                                Spacer()
                            }
                            
                            Chart {
                                ForEach(sampleChartData) { point in
                                    // Gradient Fill Area Underneath Line
                                    AreaMark(
                                        x: .value("Date", point.date, unit: .day),
                                        y: .value("AQI", point.aqi)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                viewModel.currentSeverity.primaryColor.opacity(0.4),
                                                viewModel.currentSeverity.primaryColor.opacity(0.0)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    
                                    // Smooth Tension Line
                                    LineMark(
                                        x: .value("Date", point.date, unit: .day),
                                        y: .value("AQI", point.aqi)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .lineStyle(StrokeStyle(lineWidth: 3.5, lineCap: .round))
                                    .foregroundStyle(viewModel.currentSeverity.primaryColor)
                                    
                                    // Glowing Data Points
                                    PointMark(
                                        x: .value("Date", point.date, unit: .day),
                                        y: .value("AQI", point.aqi)
                                    )
                                    .symbolSize(40)
                                    .foregroundStyle(viewModel.currentSeverity.primaryColor)
                                }
                            }
                            .chartYScale(domain: 0...220)
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day)) { value in
                                    AxisValueLabel(format: .dateTime.locale(Locale(identifier: isThai ? "th_TH" : "en_US")).weekday(.abbreviated))
                                        .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.7) : Color(white: 0.40))
                                }
                            }
                            .chartYAxis {
                                AxisMarks(values: .automatic) { value in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                                        .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.1))
                                    AxisValueLabel()
                                        .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.6) : Color(white: 0.45))
                                }
                            }
                            .frame(height: 180)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Comprehensive Pollutant Horizontal Progress Bars (Synced 100% with Dashboard)
                    GlassCard(cornerRadius: 22, padding: 18) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(isThai ? "สารมลพิษและก๊าซในอากาศทั้งหมด" : "ALL GASES & PARTICULATE MATTER")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(white: 0.45))
                                .tracking(1.2)
                            
                            PollutantProgressBar(title: isThai ? "PM2.5 (ฝุ่นขนาดเล็กมาก)" : "PM2.5 (Fine Particulate)", val: viewModel.currentAQIData?.pm25Value ?? 60.0, maxVal: 150, unit: "µg/m³", color: viewModel.currentSeverity.primaryColor)
                            
                            PollutantProgressBar(title: isThai ? "PM10 (ฝุ่นขนาดเล็ก)" : "PM10 (Coarse Particulate)", val: viewModel.currentAQIData?.pm10Value ?? 31.0, maxVal: 200, unit: "µg/m³", color: .yellow)
                            
                            PollutantProgressBar(title: isThai ? "O3 (ก๊าซโอโซน)" : "O3 (Ozone)", val: viewModel.currentAQIData?.o3Value ?? 4.8, maxVal: 100, unit: "ppb", color: .cyan)
                            
                            PollutantProgressBar(title: isThai ? "NO2 (ไนโตรเจนไดออกไซด์)" : "NO2 (Nitrogen Dioxide)", val: viewModel.currentAQIData?.no2Value ?? 12.1, maxVal: 80, unit: "ppb", color: .orange)
                            
                            PollutantProgressBar(title: isThai ? "SO2 (ซัลเฟอร์ไดออกไซด์)" : "SO2 (Sulfur Dioxide)", val: viewModel.currentAQIData?.so2Value ?? 0.6, maxVal: 50, unit: "ppb", color: .purple)
                            
                            PollutantProgressBar(title: isThai ? "CO (คาร์บอนมอนอกไซด์)" : "CO (Carbon Monoxide)", val: viewModel.currentAQIData?.coValue ?? 0.1, maxVal: 10, unit: "ppm", color: .mint)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}
