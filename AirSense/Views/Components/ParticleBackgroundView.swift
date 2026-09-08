import SwiftUI

/// Dynamic ambient particle effect rendering floating dust particles on a light or dark background
struct ParticleBackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme
    var severity: AQISeverity
    
    @State private var particles: [DustParticle] = (0..<40).map { _ in DustParticle.random() }
    
    var body: some View {
        ZStack {
            // Base Background Color
            (colorScheme == .dark ? Color(red: 0.05, green: 0.07, blue: 0.12) : Color(red: 0.96, green: 0.97, blue: 0.99))
                .ignoresSafeArea()
            
            // Soft Light / Dark Ambient Gradient Glow
            RadialGradient(
                colors: severity.ambientGlowForScheme(isDark: colorScheme == .dark),
                center: .top,
                startRadius: 20,
                endRadius: 550
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.2), value: severity)
            
            // Animated Canvas Floating Particles
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let now = timeline.date.timeIntervalSinceReferenceDate
                    
                    for particle in particles {
                        let yPos = (particle.y + now * particle.speed).truncatingRemainder(dividingBy: size.height)
                        let xPos = particle.x * size.width + sin(now * particle.wobbleSpeed) * 15
                        
                        let rect = CGRect(
                            x: xPos,
                            y: yPos,
                            width: particle.size,
                            height: particle.size
                        )
                        
                        let path = Path(ellipseIn: rect)
                        let alpha = particle.opacity * (colorScheme == .dark ? 0.6 : 0.45)
                        let color = severity.primaryColor.opacity(alpha)
                        
                        context.fill(path, with: .color(color))
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}

