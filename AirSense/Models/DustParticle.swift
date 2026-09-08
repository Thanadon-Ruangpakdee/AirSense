import Foundation

struct DustParticle {
    var x: Double
    var y: Double
    var size: Double
    var speed: Double
    var opacity: Double
    var wobbleSpeed: Double
    
    static func random() -> DustParticle {
        DustParticle(
            x: Double.random(in: 0...1),
            y: Double.random(in: 0...800),
            size: Double.random(in: 2...6),
            speed: Double.random(in: 12...35),
            opacity: Double.random(in: 0.2...0.7),
            wobbleSpeed: Double.random(in: 0.5...2.0)
        )
    }
}
