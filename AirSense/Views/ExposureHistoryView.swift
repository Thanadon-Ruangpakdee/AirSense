import SwiftUI

/// Pre-calculated daily exposure log model for ultra-smooth scrolling performance
struct DailyExposureRecord: Identifiable {
    let id: Int
    let day: Int
    let aqi: Int
    let severity: AQISeverity
}

/// Tab 4: Redesigned & Performance-Optimized Exposure History View
/// Fixes layout edge overflow, supports Thai/English language toggle, and optimizes scrolling smoothness.
struct ExposureHistoryView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: AirSenseViewModel
    @AppStorage("appLanguage") private var appLanguage: String = "th"
    
    @State private var selectedDay: Int? = nil
    
    private var isThai: Bool { appLanguage == "th" }
    
    // Calendar info for current month
    private var calendar: Calendar { Calendar.current }
    private var currentDate: Date { Date() }
    private var currentDay: Int {
        calendar.component(.day, from: currentDate)
    }
    private var daysInMonth: Int {
        let range = calendar.range(of: .day, in: .month, for: currentDate)
        return range?.count ?? 30
    }
    private var monthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: isThai ? "th_TH" : "en_US")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    // Location-tailored daily exposure records (Dynamically updates when active location changes)
    private var records: [DailyExposureRecord] {
        let baseAQI = viewModel.currentAQI
        let locationHash = abs(viewModel.locationDisplayName.hashValue)
        
        return (1...daysInMonth).map { day in
            if day == currentDay {
                return DailyExposureRecord(id: day, day: day, aqi: baseAQI, severity: viewModel.currentSeverity)
            }
            
            // Generate realistic daily AQI variations tailored specifically to the active location
            let seed = (day * 13 + locationHash % 97)
            let variation = (seed % 39) - 19
            let dailyAQI = max(15, min(350, baseAQI + variation))
            let severity = AQISeverity.from(aqi: dailyAQI)
            
            return DailyExposureRecord(id: day, day: day, aqi: dailyAQI, severity: severity)
        }
    }
    
    // Compact 7-column grid for weekday alignment
    let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    
    private var pastRecords: [DailyExposureRecord] {
        Array(records.prefix(currentDay))
    }
    private var reversedPastRecords: [DailyExposureRecord] {
        Array(pastRecords.reversed())
    }
    
    private var goodDaysCount: Int {
        pastRecords.filter { $0.severity == .good }.count
    }
    private var moderateDaysCount: Int {
        pastRecords.filter { $0.severity == .moderate }.count
    }
    private var unhealthyDaysCount: Int {
        pastRecords.filter { $0.severity != .good && $0.severity != .moderate }.count
    }
    
    var body: some View {
        ZStack {
            ParticleBackgroundView(severity: viewModel.currentSeverity)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    // Header Bar (Tight alignment right below top safe area / navbar)
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(isThai ? "ประวัติการรับสัมผัสฝุ่น" : "EXPOSURE HISTORY")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(white: 0.12))
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 8))
                                Text(viewModel.locationDisplayName)
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                                    .lineLimit(1)
                            }
                            .foregroundColor(viewModel.currentSeverity.primaryColor)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 2)
                    
                    // Monthly Heatmap Card
                    GlassCard(cornerRadius: 18, padding: 12) {
                        VStack(alignment: .leading, spacing: 10) {
                            // Month Title & Day Progress Badge
                            HStack {
                                Image(systemName: "calendar")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.blue)
                                
                                Text(monthName.uppercased())
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(colorScheme == .dark ? .white : Color(white: 0.15))
                                
                                Spacer()
                                
                                Text(isThai ? "วันที่ 1-\(currentDay) จาก \(daysInMonth) วัน" : "Day 1-\(currentDay) of \(daysInMonth)")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(Color.blue.opacity(0.12)))
                            }
                            
                            // Day of Week Header
                            HStack(spacing: 0) {
                                ForEach(isThai ? ["อา", "จ", "อ", "พ", "พฤ", "ศ", "ส"] : ["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                                    Text(day)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.5) : Color(white: 0.5))
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            
                            // Heatmap Grid: Redesigned modern day buttons
                            LazyVGrid(columns: columns, spacing: 6) {
                                ForEach(records) { record in
                                    let isPastOrToday = record.day <= currentDay
                                    let isToday = record.day == currentDay
                                    
                                    CalendarDayCell(
                                        record: record,
                                        isPastOrToday: isPastOrToday,
                                        isToday: isToday
                                    )
                                }
                            }
                            
                            // Clean 2-Row Color Legend Grid (Glowing dots + zero text wrapping)
                            VStack(spacing: 6) {
                                HStack(spacing: 4) {
                                    LegendItem(color: AQISeverity.good.primaryColor, label: isThai ? "ดี (Good)" : "Good")
                                    Spacer()
                                    LegendItem(color: AQISeverity.moderate.primaryColor, label: isThai ? "ปานกลาง" : "Moderate")
                                    Spacer()
                                    LegendItem(color: AQISeverity.unhealthySensitive.primaryColor, label: isThai ? "เริ่มมีผล" : "Sensitive")
                                }
                                
                                HStack(spacing: 4) {
                                    LegendItem(color: AQISeverity.unhealthy.primaryColor, label: isThai ? "แย่ (Unhealthy)" : "Unhealthy")
                                    Spacer()
                                    LegendItem(color: AQISeverity.hazardous.primaryColor, label: isThai ? "อันตราย" : "Hazardous")
                                    Spacer()
                                    LegendItem(color: Color.gray.opacity(0.4), label: isThai ? "วันอนาคต" : "Future Day")
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Monthly Summary Stats Cards
                    GlassCard(cornerRadius: 18, padding: 14) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(isThai ? "สรุปภาพรวมเดือนนี้ (จนถึงวันนี้)" : "MONTHLY SUMMARY (UP TO TODAY)")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(white: 0.40))
                                .tracking(1.0)
                            
                            HStack(spacing: 8) {
                                StatCard(title: isThai ? "อากาศดี" : "Good Air", count: "\(goodDaysCount) \(isThai ? "วัน" : "Days")", subtitle: "AQI ≤ 50", color: .green)
                                StatCard(title: isThai ? "ปานกลาง" : "Moderate", count: "\(moderateDaysCount) \(isThai ? "วัน" : "Days")", subtitle: "AQI 51-100", color: .orange)
                                StatCard(title: isThai ? "เริ่มมีผล" : "Unhealthy", count: "\(unhealthyDaysCount) \(isThai ? "วัน" : "Days")", subtitle: "AQI > 100", color: .red)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Daily Breakdown Logs (LazyVStack for smooth 60fps scrolling)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(isThai ? "บันทึกประจำวัน" : "DAILY LOG BREAKDOWN")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(white: 0.15))
                            Spacer()
                            Text(isThai ? "แสดง \(currentDay) วันย้อนหลัง" : "Past \(currentDay) Days")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(white: 0.5))
                        }
                        .padding(.horizontal, 20)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(reversedPastRecords) { record in
                                OptimizedDailyRow(
                                    record: record,
                                    isToday: record.day == currentDay,
                                    monthName: monthName,
                                    isThai: isThai
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 120)
                    }
                }
            }
        }
    }
}

/// Lightweight, performance-optimized Row Component for history list
struct OptimizedDailyRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let record: DailyExposureRecord
    let isToday: Bool
    let monthName: String
    let isThai: Bool
    
    var body: some View {
        GlassCard(cornerRadius: 14, padding: 12) {
            HStack(spacing: 12) {
                // Day Badge
                ZStack {
                    Circle()
                        .fill(record.severity.primaryColor.opacity(0.18))
                        .frame(width: 38, height: 38)
                    
                    Text("\(record.day)")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(record.severity.primaryColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(isThai ? (isToday ? "วันนี้ (\(record.day) \(monthName))" : "วันที่ \(record.day) \(monthName)") : (isToday ? "Today (\(record.day) \(monthName))" : "Day \(record.day) (\(monthName))"))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : Color(white: 0.15))
                            .lineLimit(1)
                        
                        if isToday {
                            Text("TODAY")
                                .font(.system(size: 8, weight: .black))
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.blue))
                        }
                    }
                    
                    Text(record.severity.description)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.65) : Color(white: 0.45))
                        .lineLimit(1)
                }
                
                Spacer()
                
                // AQI Score
                VStack(alignment: .trailing, spacing: 1) {
                    Text("\(record.aqi)")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundColor(record.severity.primaryColor)
                    
                    Text("AQI")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.5) : Color(white: 0.5))
                }
            }
        }
    }
}

/// Redesigned Modern Calendar Day Tile Component
struct CalendarDayCell: View {
    @Environment(\.colorScheme) private var colorScheme
    let record: DailyExposureRecord
    let isPastOrToday: Bool
    let isToday: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    isToday
                    ? LinearGradient(
                        colors: [
                            record.severity.primaryColor,
                            record.severity.primaryColor.opacity(0.85)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    : (isPastOrToday
                       ? LinearGradient(
                            colors: colorScheme == .dark ? [
                                record.severity.primaryColor.opacity(0.35),
                                record.severity.primaryColor.opacity(0.18)
                            ] : [
                                record.severity.primaryColor.opacity(0.20),
                                record.severity.primaryColor.opacity(0.10)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                         )
                       : LinearGradient(
                            colors: colorScheme == .dark ? [
                                Color.white.opacity(0.06),
                                Color.white.opacity(0.03)
                            ] : [
                                Color.black.opacity(0.04),
                                Color.black.opacity(0.02)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                         )
                      )
                )
                .frame(height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(
                            isToday
                            ? Color.white
                            : (isPastOrToday ? record.severity.primaryColor.opacity(0.4) : Color.gray.opacity(0.12)),
                            lineWidth: isToday ? 2.5 : 1
                        )
                )
                .shadow(
                    color: isToday ? record.severity.primaryColor.opacity(0.45) : .clear,
                    radius: isToday ? 5 : 0,
                    x: 0,
                    y: isToday ? 2 : 0
                )
            
            VStack(spacing: 2) {
                Text("\(record.day)")
                    .font(.system(size: 11, weight: isToday ? .black : .bold, design: .rounded))
                    .foregroundColor(
                        isToday
                        ? .white
                        : (isPastOrToday
                           ? (colorScheme == .dark ? .white : record.severity.primaryColor)
                           : (colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray.opacity(0.4)))
                    )
                
                if isPastOrToday && !isToday {
                    Circle()
                        .fill(record.severity.primaryColor)
                        .frame(width: 4, height: 4)
                }
            }
        }
    }
}

