import Foundation
import CoreLocation
import Combine

/// CoreLocation Manager service using ObservableObject for 100% build compatibility across all Xcode toolchains
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var locationName: String = "Bangkok, Thailand"
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocating: Bool = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    func requestLocation() {
        isLocating = true
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.requestLocation()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isLocating = false
        guard let location = locations.last else { return }
        userLocation = location.coordinate
        
        // Reverse Geocode
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            if let placemark = placemarks?.first {
                let city = placemark.locality ?? placemark.administrativeArea ?? "Bangkok"
                let country = placemark.country ?? "Thailand"
                DispatchQueue.main.async {
                    self?.locationName = "\(city), \(country)"
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLocating = false
        // Fallback default coordinates (Bangkok: 13.7563, 100.5018)
        if userLocation == nil {
            userLocation = CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018)
            locationName = "Bangkok, Thailand"
        }
    }
}
