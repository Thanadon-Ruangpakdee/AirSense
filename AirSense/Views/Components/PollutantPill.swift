import SwiftUI

struct PollutantPill: View {
    @Environment(\.colorScheme) private var colorScheme
    var name: String
    var value: String
    var unit: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(name)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(red: 0.4, green: 0.45, blue: 0.55))
            
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(color)
            
            Text(unit)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.4) : Color(red: 0.5, green: 0.55, blue: 0.65))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color(red: 0.95, green: 0.96, blue: 0.98))
        )
    }
}

