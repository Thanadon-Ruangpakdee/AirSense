import SwiftUI

/// Glassmorphic Actionable Health Advice Component
struct HealthAdviceCard: View {
    @Environment(\.colorScheme) private var colorScheme
    var item: HealthAdviceItem
    var severity: AQISeverity
    
    var body: some View {
        GlassCard(cornerRadius: 16, padding: 12) {
            HStack(spacing: 12) {
                // SF Symbol Icon in Soft Circle
                ZStack {
                    Circle()
                        .fill(severity.primaryColor.opacity(0.12))
                        .frame(width: 42, height: 42)
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(severity.primaryColor)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.1, green: 0.15, blue: 0.25))
                    
                    Text(item.detail)
                        .font(.system(size: 11.5, weight: .medium, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(red: 0.35, green: 0.4, blue: 0.5))
                        .lineLimit(2)
                }
                
                Spacer(minLength: 0)
            }
        }
    }
}

