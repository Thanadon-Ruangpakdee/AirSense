import Foundation
import SwiftData

/// SwiftData Model for caching hourly/daily AQI readings locally to power Swift Charts 7-Day trends offline
@Model
final class AirQualityLog {
    var id: UUID
    var locationName: String
    var latitude: Double
    var longitude: Double
    var aqi: Int
    var pm25: Double
    var pm10: Double
    var o3: Double
    var no2: Double
    var so2: Double
    var co: Double
    var timestamp: Date
    
    init(
        id: UUID = UUID(),
        locationName: String,
        latitude: Double,
        longitude: Double,
        aqi: Int,
        pm25: Double,
        pm10: Double,
        o3: Double = 14.2,
        no2: Double = 8.6,
        so2: Double = 3.1,
        co: Double = 0.8,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.aqi = aqi
        self.pm25 = pm25
        self.pm10 = pm10
        self.o3 = o3
        self.no2 = no2
        self.so2 = so2
        self.co = co
        self.timestamp = timestamp
    }
}
