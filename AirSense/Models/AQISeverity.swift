import SwiftUI

/// Defines AQI severity levels, color schemes, mascot states, and health recommendations.
enum AQISeverity: Int, CaseIterable, Identifiable {
    case good = 1
    case moderate = 2
    case unhealthySensitive = 3
    case unhealthy = 4
    case veryUnhealthy = 5
    case hazardous = 6
    
    var id: Int { rawValue }
    
    static func from(aqi: Int) -> AQISeverity {
        switch aqi {
        case 0...50:
            return .good
        case 51...100:
            return .moderate
        case 101...150:
            return .unhealthySensitive
        case 151...200:
            return .unhealthy
        case 201...300:
            return .veryUnhealthy
        default:
            return .hazardous
        }
    }
    
    var title: String {
        switch self {
        case .good: return "GOOD"
        case .moderate: return "MODERATE"
        case .unhealthySensitive: return "UNHEALTHY (SENSITIVE)"
        case .unhealthy: return "UNHEALTHY"
        case .veryUnhealthy: return "VERY UNHEALTHY"
        case .hazardous: return "HAZARDOUS"
        }
    }
    
    var description: String {
        switch self {
        case .good: return "Air quality is satisfactory and poses little or no risk."
        case .moderate: return "Air quality is acceptable; sensitive individuals should take care."
        case .unhealthySensitive: return "Members of sensitive groups may experience health effects."
        case .unhealthy: return "Everyone may begin to experience health effects."
        case .veryUnhealthy: return "Health alert: everyone may experience serious health effects."
        case .hazardous: return "Emergency conditions: the entire population is affected."
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .good: return Color(red: 0.10, green: 0.70, blue: 0.42)
        case .moderate: return Color(red: 0.90, green: 0.65, blue: 0.00)
        case .unhealthySensitive: return Color(red: 0.95, green: 0.48, blue: 0.00)
        case .unhealthy: return Color(red: 0.88, green: 0.20, blue: 0.20)
        case .veryUnhealthy: return Color(red: 0.55, green: 0.15, blue: 0.70)
        case .hazardous: return Color(red: 0.45, green: 0.08, blue: 0.20)
        }
    }
    
    var badgeDot: String {
        switch self {
        case .good: return "🟢"
        case .moderate: return "🟡"
        case .unhealthySensitive: return "🟠"
        case .unhealthy: return "🔴"
        case .veryUnhealthy: return "🟣"
        case .hazardous: return "🟤"
        }
    }
    
    var ambientGlow: [Color] {
        ambientGlowForScheme(isDark: false)
    }
    
    func ambientGlowForScheme(isDark: Bool) -> [Color] {
        if isDark {
            switch self {
            case .good:
                return [Color(red: 0.08, green: 0.28, blue: 0.18), Color(red: 0.05, green: 0.07, blue: 0.12)]
            case .moderate:
                return [Color(red: 0.32, green: 0.24, blue: 0.06), Color(red: 0.05, green: 0.07, blue: 0.12)]
            case .unhealthySensitive:
                return [Color(red: 0.35, green: 0.18, blue: 0.05), Color(red: 0.05, green: 0.07, blue: 0.12)]
            case .unhealthy:
                return [Color(red: 0.38, green: 0.08, blue: 0.08), Color(red: 0.05, green: 0.07, blue: 0.12)]
            case .veryUnhealthy:
                return [Color(red: 0.25, green: 0.06, blue: 0.32), Color(red: 0.05, green: 0.07, blue: 0.12)]
            case .hazardous:
                return [Color(red: 0.28, green: 0.05, blue: 0.12), Color(red: 0.05, green: 0.07, blue: 0.12)]
            }
        } else {
            switch self {
            case .good:
                return [Color(red: 0.80, green: 0.96, blue: 0.88), Color(red: 0.96, green: 0.97, blue: 0.99)]
            case .moderate:
                return [Color(red: 0.98, green: 0.94, blue: 0.80), Color(red: 0.96, green: 0.97, blue: 0.99)]
            case .unhealthySensitive:
                return [Color(red: 0.99, green: 0.90, blue: 0.82), Color(red: 0.96, green: 0.97, blue: 0.99)]
            case .unhealthy:
                return [Color(red: 0.99, green: 0.86, blue: 0.86), Color(red: 0.96, green: 0.97, blue: 0.99)]
            case .veryUnhealthy:
                return [Color(red: 0.94, green: 0.85, blue: 0.96), Color(red: 0.96, green: 0.97, blue: 0.99)]
            case .hazardous:
                return [Color(red: 0.92, green: 0.82, blue: 0.86), Color(red: 0.96, green: 0.97, blue: 0.99)]
            }
        }
    }
    
    var mascotMood: MascotState {
        switch self {
        case .good:
            return MascotState(expression: "Happy", wearsMask: false, accessories: "✨ Clean Air Sparkles")
        case .moderate:
            return MascotState(expression: "Cautious", wearsMask: false, accessories: "🌤️ Mild Haze")
        case .unhealthySensitive:
            return MascotState(expression: "Concerned", wearsMask: true, accessories: "😷 Cloth Mask")
        case .unhealthy:
            return MascotState(expression: "Worried", wearsMask: true, accessories: "😷 N95 Mask with Filter")
        case .veryUnhealthy:
            return MascotState(expression: "Alert", wearsMask: true, accessories: "☣️ N95 Dual Filter Valve")
        case .hazardous:
            return MascotState(expression: "Critical", wearsMask: true, accessories: "☣️ Full Respirator")
        }
    }
    
    var healthAdviceList: [HealthAdviceItem] {
        healthAdviceList(isThai: false)
    }
    
    func healthAdviceList(isThai: Bool) -> [HealthAdviceItem] {
        switch self {
        case .good:
            return [
                HealthAdviceItem(icon: "figure.run", title: isThai ? "กิจกรรมกลางแจ้ง" : "Outdoor Activities", detail: isThai ? "อากาศดีมาก เหมาะสำหรับการวิ่งและเล่นกีฬากลางแจ้ง" : "Perfect day for running and outdoor sports."),
                HealthAdviceItem(icon: "wind", title: isThai ? "การระบายอากาศ" : "Natural Ventilation", detail: isThai ? "เปิดหน้าต่างเพื่อระบายอากาศบริสุทธิ์ภายในบ้าน" : "Open windows to bring fresh air inside.")
            ]
        case .moderate:
            return [
                HealthAdviceItem(icon: "person.fill.viewfinder", title: isThai ? "กลุ่มเสี่ยงควรระวัง" : "Sensitive Groups", detail: isThai ? "ผู้มีโรคประจำตัวควรลดการออกกำลังกายกลางแจ้งหนักๆ" : "Consider reducing prolonged outdoor exertion."),
                HealthAdviceItem(icon: "wind", title: isThai ? "หมุนเวียนอากาศ" : "Ventilation", detail: isThai ? "เปิดหน้าต่างระบายอากาศช่วงที่ฝุ่นเบาบาง" : "Keep windows open when AQI drops.")
            ]
        case .unhealthySensitive:
            return [
                HealthAdviceItem(icon: "facemask.fill", title: isThai ? "สวมหน้ากาก N95" : "Wear N95 Mask", detail: isThai ? "กลุ่มเสี่ยงควรสวมหน้ากากป้องกันฝุ่นเมื่อออกนอกบ้าน" : "Sensitive individuals should wear protection outdoors."),
                HealthAdviceItem(icon: "fanblades.fill", title: isThai ? "เปิดเครื่องฟอกอากาศ" : "Air Purifier", detail: isThai ? "ควรเปิดเครื่องฟอกอากาศภายในห้องนอนหรือห้องทำงาน" : "Turn on indoor air purifier on Low mode.")
            ]
        case .unhealthy:
            return [
                HealthAdviceItem(icon: "facemask.fill", title: isThai ? "ต้องสวมหน้ากาก N95" : "N95 Mask Required", detail: isThai ? "ควรรวมหน้ากาก N95 ทุกครั้งที่ออกกลางแจ้ง" : "Wear a certified N95 mask for all outdoor trips."),
                HealthAdviceItem(icon: "xmark.shield.fill", title: isThai ? "ปิดหน้าต่างและประตู" : "Close Windows", detail: isThai ? "ปิดหน้าต่างประตูให้มิดชิดเพื่อป้องกันฝุ่นเข้าบ้าน" : "Keep all windows & doors tightly closed."),
                HealthAdviceItem(icon: "fanblades.fill", title: isThai ? "เร่งเครื่องฟอกอากาศ" : "Air Purifier High", detail: isThai ? "เปิดเครื่องฟอกอากาศโหมดแรงสุด" : "Run indoor air purifier on High setting.")
            ]
        case .veryUnhealthy, .hazardous:
            return [
                HealthAdviceItem(icon: "exclamationmark.triangle.fill", title: isThai ? "งดกิจกรรมกลางแจ้ง" : "Avoid Outdoors", detail: isThai ? "หลีกเลี่ยงการออกนอกบ้านและงดออกกำลังกายกลางแจ้งเด็ดขาด" : "Stay indoors. Avoid all physical outdoor activities."),
                HealthAdviceItem(icon: "facemask.fill", title: isThai ? "หน้ากากกรองฝุ่นระดับสูง" : "Respirator Mask", detail: isThai ? "ใช้หน้ากาก N95/N99 หรือ Respirator หากจำเป็นต้องออกนอกบ้าน" : "Use dual-filter N95/N99 respirator if going out."),
                HealthAdviceItem(icon: "air.purifier.fill", title: isThai ? "เครื่องฟอกอากาศระดับสูงสุด" : "Max Air Purification", detail: isThai ? "เปิดเครื่องฟอกระบบ HEPA ระดับสูงสุดตลอดเวลา" : "Run HEPA air purifiers at max capacity.")
            ]
        }
    }
}

