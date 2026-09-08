import Foundation
import SwiftData

/// SwiftData Model for user bookmarked locations (e.g. Home, Condo, University)
@Model
final class SavedLocation {
    @Attribute(.unique) var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var isPrimary: Bool
    var cachedAQI: Int
    var cachedPM25: Double
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double,
        isPrimary: Bool = false,
        cachedAQI: Int = 50,
        cachedPM25: Double = 15.0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.isPrimary = isPrimary
        self.cachedAQI = cachedAQI
        self.cachedPM25 = cachedPM25
        self.createdAt = createdAt
    }
}
