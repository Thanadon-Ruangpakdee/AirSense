import SwiftUI

struct StatCard: View {
    @Environment(\.colorScheme) private var colorScheme
    var title: String
    var count: String
    var subtitle: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(count)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.15, green: 0.2, blue: 0.3))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(subtitle)
                .font(.system(size: 8.5, weight: .semibold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(red: 0.45, green: 0.5, blue: 0.6))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color(red: 0.95, green: 0.96, blue: 0.98))
        )
    }
}
