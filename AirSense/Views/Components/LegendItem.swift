import SwiftUI

struct LegendItem: View {
    var color: Color
    var label: String
    @Environment(\.colorScheme) private var colorScheme
    
    init(color: Color = .green, label: String) {
        self.color = color
        self.label = label
    }
    
    init(dot: String, label: String) {
        self.label = label
        switch dot {
        case "🟢": self.color = Color(red: 0.10, green: 0.70, blue: 0.42)
        case "🟡": self.color = Color(red: 0.90, green: 0.65, blue: 0.00)
        case "🟠": self.color = Color(red: 0.95, green: 0.48, blue: 0.00)
        case "🔴": self.color = Color(red: 0.88, green: 0.20, blue: 0.20)
        case "🟣": self.color = Color(red: 0.55, green: 0.15, blue: 0.70)
        default: self.color = Color.gray.opacity(0.4)
        }
    }
    
    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .shadow(color: color.opacity(0.4), radius: 3, x: 0, y: 1)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.6), lineWidth: 0.8)
                )
            
            Text(label)
                .font(.system(size: 9.5, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.8) : Color(white: 0.35))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

