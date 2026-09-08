import SwiftUI
import SwiftData

@main
struct AirSenseApp: App {
    @AppStorage("appThemeMode") private var appThemeMode: String = "system"
    
    var preferredColorScheme: ColorScheme? {
        switch appThemeMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(preferredColorScheme)
        }
        .modelContainer(for: [SavedLocation.self, AirQualityLog.self])
    }
}

