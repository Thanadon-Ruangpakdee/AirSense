import SwiftUI

struct PollutantProgressBar: View {
    @Environment(\.colorScheme) private var colorScheme
    var title: String
    var val: Double
    var maxVal: Double
    var unit: String
    var color: Color
    
    var ratio: CGFloat {
        min(max(CGFloat(val / maxVal), 0.05), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.15, green: 0.2, blue: 0.3))
                Spacer()
                Text("\(String(format: "%.1f", val)) \(unit)")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundColor(color)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(colorScheme == .dark ? Color.white.opacity(0.12) : Color(red: 0.9, green: 0.92, blue: 0.95))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.7), color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * ratio, height: 8)
                        .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 0)
                }
            }
            .frame(height: 8)
        }
    }
}

