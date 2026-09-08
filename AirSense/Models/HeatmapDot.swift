import Foundation

struct HeatmapDot: Identifiable {
    let id = UUID()
    let day: Int
    let severity: AQISeverity
}
