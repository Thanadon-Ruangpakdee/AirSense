import SwiftUI

/// Dynamic animated circular gauge featuring a vibrant multi-color AQI progress arc, inner glass container, and glowing severity styling
struct AQICircularGauge: View {
    @Environment(\.colorScheme) private var colorScheme
    var aqi: Int
    var severity: AQISeverity
    
    @State private var animatedProgress: Double = 0.0
    
    var targetProgress: Double {
        min(max(Double(aqi) / 300.0, 0.05), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // 1. Outer Background Track Ring (270° Arc from 135° to 405°)
                Circle()
                    .trim(from: 0.0, to: 0.75)
                    .stroke(
                        colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.08),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(135))
                    .frame(width: 200, height: 200)
                
                // 2. Multi-Color AQI Progress Arc (Green -> Yellow -> Orange -> Red -> Purple)
                Circle()
                    .trim(from: 0.0, to: 0.75 * animatedProgress)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.10, green: 0.70, blue: 0.42), // Green
                                Color(red: 0.90, green: 0.65, blue: 0.00), // Yellow
                                Color(red: 0.95, green: 0.48, blue: 0.00), // Orange
                                Color(red: 0.88, green: 0.20, blue: 0.20), // Red
                                severity.primaryColor
                            ]),
                            center: .center,
                            startAngle: .degrees(135),
                            endAngle: .degrees(405)
                        ),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(135))
                    .frame(width: 200, height: 200)
                    .shadow(color: severity.primaryColor.opacity(0.5), radius: 10, x: 0, y: 4)
                
                // 3. Inner Frosted Glass Card Circle
                Circle()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.88))
                    .frame(width: 162, height: 162)
                    .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
                    .overlay(
                        Circle()
                            .stroke(colorScheme == .dark ? Color.white.opacity(0.15) : Color.white, lineWidth: 1.5)
                    )
                
                // 4. Center Text & Severity Pill
                VStack(spacing: 3) {
                    Text("\(aqi)")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.1, green: 0.15, blue: 0.25))
                        .shadow(color: severity.primaryColor.opacity(0.35), radius: 6, x: 0, y: 3)
                        .contentTransition(.numericText())
                    
                    Text("AQI INDEX")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(red: 0.45, green: 0.5, blue: 0.6))
                        .tracking(1.5)
                    
                    Text(severity.title)
                        .font(.system(size: 11.5, weight: .heavy, design: .rounded))
                        .foregroundColor(severity.primaryColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(severity.primaryColor.opacity(colorScheme == .dark ? 0.22 : 0.14))
                                .overlay(Capsule().stroke(severity.primaryColor.opacity(0.35), lineWidth: 1))
                        )
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.75)) {
                animatedProgress = targetProgress
            }
        }
        .onChange(of: aqi) { _, newValue in
            withAnimation(.spring(response: 1.0, dampingFraction: 0.75)) {
                animatedProgress = min(max(Double(newValue) / 300.0, 0.05), 1.0)
            }
        }
    }
}

