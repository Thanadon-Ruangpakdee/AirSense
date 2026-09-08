import SwiftUI

/// Animated SVG/SwiftUI Mascot ("Air Dragon") that shifts mood, facial expression, and equips N95 mask with filter valve based on AQI toxicity
struct AirDragonMascotView: View {
    @Environment(\.colorScheme) private var colorScheme
    var severity: AQISeverity
    
    @State private var isFloating: Bool = false
    @State private var wingFlap: Bool = false
    
    var moodState: MascotState {
        severity.mascotMood
    }
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Dragon Aura Glow
                Circle()
                    .fill(severity.primaryColor.opacity(0.25))
                    .blur(radius: 20)
                    .frame(width: 100, height: 100)
                
                // SVG Dragon Body Drawing
                ZStack {
                    // Dragon Wings
                    HStack(spacing: 50) {
                        Path { path in
                            path.move(to: CGPoint(x: 20, y: 30))
                            path.addQuadCurve(to: CGPoint(x: 0, y: 10), control: CGPoint(x: 5, y: 0))
                            path.addQuadCurve(to: CGPoint(x: 20, y: 30), control: CGPoint(x: 10, y: 25))
                        }
                        .fill(severity.primaryColor.opacity(0.8))
                        .rotationEffect(.degrees(wingFlap ? -12 : 5))
                        
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 30))
                            path.addQuadCurve(to: CGPoint(x: 20, y: 10), control: CGPoint(x: 15, y: 0))
                            path.addQuadCurve(to: CGPoint(x: 0, y: 30), control: CGPoint(x: 10, y: 25))
                        }
                        .fill(severity.primaryColor.opacity(0.8))
                        .rotationEffect(.degrees(wingFlap ? 12 : -5))
                    }
                    .frame(width: 80, height: 40)
                    .offset(y: -10)
                    
                    // Main Cute Head & Body
                    RoundedRectangle(cornerRadius: 35, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.20, green: 0.85, blue: 0.60),
                                    Color(red: 0.10, green: 0.60, blue: 0.45)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 75, height: 75)
                        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    // Dragon Little Horns
                    HStack(spacing: 36) {
                        Capsule()
                            .fill(Color.yellow)
                            .frame(width: 8, height: 16)
                            .rotationEffect(.degrees(-20))
                        
                        Capsule()
                            .fill(Color.yellow)
                            .frame(width: 8, height: 16)
                            .rotationEffect(.degrees(20))
                    }
                    .offset(y: -38)
                    
                    // Face Expression (Eyes)
                    if !moodState.wearsMask {
                        HStack(spacing: 22) {
                            if severity == .good {
                                // Happy Sparkle Eyes ^^
                                Text("◠")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                Text("◠")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                            } else {
                                // Cautious Eyes O_O
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 8, height: 8)
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .offset(y: -10)
                    }
                    
                    // N95 Mask with Filter Valve (Equipped when AQI > 100)
                    if moodState.wearsMask {
                        ZStack {
                            // N95 White Mask Shape
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white)
                                .frame(width: 48, height: 28)
                                .shadow(radius: 2)
                            
                            // Mask Straps
                            HStack {
                                LineShape()
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1.5)
                            }
                            
                            // N95 Filter Valve (Red/Gold Accent)
                            Circle()
                                .fill(severity == .hazardous ? Color.red : Color(red: 0.9, green: 0.6, blue: 0.1))
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
                                )
                                .offset(x: 12, y: 2)
                        }
                        .offset(y: 8)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .offset(y: isFloating ? -6 : 6)
            }
            .frame(width: 100, height: 95)
            
            // Mascot Mood Label Badge (High Contrast)
            HStack(spacing: 4) {
                Text(moodState.accessories)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.15, green: 0.2, blue: 0.3))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.15) : Color.white.opacity(0.85))
                    .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
                    .overlay(Capsule().stroke(colorScheme == .dark ? Color.white.opacity(0.2) : Color.white, lineWidth: 1.2))
            )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isFloating = true
            }
            withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                wingFlap = true
            }
        }
    }
}


struct LineShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}
