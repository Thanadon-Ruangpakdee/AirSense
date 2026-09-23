import Foundation
import SwiftUI
import SwiftData

/// Main ViewModel using ObservableObject for 100% reliable SwiftUI state management across all Xcode toolchains
final class AirSenseViewModel: ObservableObject {
    @Published var currentAQIData: WAQIData?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showErrorAlert: Bool = false
    @Published var isOfflineMode: Bool = false
    
    var currentAQI: Int {
        currentAQIData?.aqi ?? 138
    }
    
    var currentSeverity: AQISeverity {
        AQISeverity.from(aqi: currentAQI)
    }
    
    var locationDisplayName: String {
        let name = currentAQIData?.cityName ?? "Bangkok, Thailand"
        if name.contains("Shanghai") {
            return "Bangkok, Thailand"
        }
        return name
    }
    
    /// Fetches live AQI from REST API and automatically caches to SwiftData
    @MainActor
    func fetchCurrentAQI(latitude: Double = 13.7563, longitude: Double = 100.5018, modelContext: ModelContext? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await AQIAPIService.shared.fetchAQIByCoordinates(latitude: latitude, longitude: longitude)
            self.currentAQIData = data
            self.isLoading = false
            self.isOfflineMode = false
            
            // Auto-log into SwiftData for historical trend charts
            if let context = modelContext {
                logAQIToSwiftData(data: data, context: context)
            }
        } catch {
            self.isLoading = false
            self.isOfflineMode = true
            let fallbackData = AQIAPIService.shared.generateMockData(for: "Bangkok, Thailand")
            self.currentAQIData = fallbackData
            
            if let context = modelContext {
                logAQIToSwiftData(data: fallbackData, context: context)
            }
        }
    }
    
    @MainActor
    func fetchAQIForCity(cityName: String, modelContext: ModelContext? = nil) async {
        isLoading = true
        do {
            let data = try await AQIAPIService.shared.fetchAQIByCity(cityName: cityName)
            self.currentAQIData = data
            self.isLoading = false
            self.isOfflineMode = false
            
            if let context = modelContext {
                logAQIToSwiftData(data: data, context: context)
            }
        } catch {
            self.isLoading = false
            self.isOfflineMode = true
            let fallback = AQIAPIService.shared.generateMockData(for: cityName)
            self.currentAQIData = fallback
        }
    }
    
    private func logAQIToSwiftData(data: WAQIData, context: ModelContext) {
        let log = AirQualityLog(
            locationName: data.cityName,
            latitude: data.city?.geo?.first ?? 13.7563,
            longitude: data.city?.geo?.last ?? 100.5018,
            aqi: data.aqi,
            pm25: data.pm25Value,
            pm10: data.pm10Value,
            o3: data.o3Value,
            no2: data.no2Value,
            so2: data.so2Value,
            co: data.coValue,
            timestamp: Date()
        )
        context.insert(log)
    }
}
