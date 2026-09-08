import Foundation

struct MascotState {
    let expression: String
    let wearsMask: Bool
    let accessories: String
}

struct HealthAdviceItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let detail: String
}
