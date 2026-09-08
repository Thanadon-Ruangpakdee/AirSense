import Foundation

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let dayLabel: String
    let aqi: Int
}
