import SwiftUI
import MapKit
import CoreLocation

/// Helper class for live place search autocomplete using MKLocalSearchCompleter
class LocationSearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchResults: [MKLocalSearchCompletion] = []
    private var completer = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }
    
    func search(query: String) {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            searchResults = []
        } else {
            completer.queryFragment = query
        }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Silently handle search error
    }
}

/// Modal Sheet for adding a new bookmarked location with Live Place Search & MapKit
struct AddLocationSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("appLanguage") private var appLanguage: String = "th"
    @Binding var isPresented: Bool
    var onAdd: (String, Double, Double) -> Void
    
    @State private var name: String = ""
    @State private var searchQuery: String = ""
    @StateObject private var searchCompleter = LocationSearchCompleter()
    @State private var isSearching: Bool = false
    
    private var isThai: Bool { appLanguage == "th" }
    
    @State private var selectedCoordinate = CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018)
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    private func reverseGeocode(_ coord: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let first = placemarks?.first {
                let placeName = first.name ?? first.locality ?? first.subLocality ?? (isThai ? "ตำแหน่งที่เลือก" : "Selected Location")
                if self.name.isEmpty || self.name.contains("Selected") || self.name.contains("Location") || self.name.contains("ตำแหน่งที่เลือก") {
                    self.name = placeName
                }
            }
        }
    }
    
    private func selectCompletion(_ completion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            if let coordinate = response?.mapItems.first?.placemark.coordinate {
                self.selectedCoordinate = coordinate
                self.name = completion.title
                self.position = .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                    )
                )
                self.searchQuery = ""
                self.searchCompleter.searchResults = []
                self.isSearching = false
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                (colorScheme == .dark ? Color(red: 0.08, green: 0.12, blue: 0.20) : Color(red: 0.96, green: 0.97, blue: 0.99))
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
                        Text(isThai ? "เพิ่มสถานที่ใหม่" : "Add New Location")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.1, green: 0.15, blue: 0.25))
                            .padding(.top, 16)
                        
                        // 1. Live Place Search Bar
                        VStack(alignment: .leading, spacing: 6) {
                            Text(isThai ? "ค้นหาด้วยชื่อสถานที่" : "SEARCH LOCATION")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(red: 0.45, green: 0.5, blue: 0.6))
                            
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.blue)
                                
                                TextField(isThai ? "พิมพ์ชื่อสถานที่ เช่น เชียงใหม่, สยาม, Central..." : "Search location e.g. Chiang Mai, Siam, Central...", text: $searchQuery)
                                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.1, green: 0.15, blue: 0.25))
                                    .onChange(of: searchQuery) { _, newValue in
                                        searchCompleter.search(query: newValue)
                                        isSearching = !newValue.isEmpty
                                    }
                                
                                if !searchQuery.isEmpty {
                                    Button {
                                        searchQuery = ""
                                        searchCompleter.searchResults = []
                                        isSearching = false
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorScheme == .dark ? Color.white.opacity(0.12) : Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
                            )
                            
                            // Autocomplete Results Dropdown List
                            if isSearching && !searchCompleter.searchResults.isEmpty {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(searchCompleter.searchResults.prefix(5), id: \.self) { result in
                                        Button {
                                            selectCompletion(result)
                                        } label: {
                                            HStack(spacing: 12) {
                                                Image(systemName: "mappin.and.ellipse")
                                                    .foregroundColor(.blue)
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(result.title)
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.1, green: 0.15, blue: 0.25))
                                                    
                                                    if !result.subtitle.isEmpty {
                                                        Text(result.subtitle)
                                                            .font(.system(size: 11))
                                                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color.gray)
                                                    }
                                                }
                                                Spacer()
                                            }
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                        }
                                        Divider()
                                    }
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.2, blue: 0.3) : Color.white)
                                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                                )
                                .padding(.top, 4)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 2. Location Name Input Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text(isThai ? "ชื่อสถานที่บันทึก" : "LOCATION NAME")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(red: 0.45, green: 0.5, blue: 0.6))
                            TextField(isThai ? "เช่น บ้านพักกรุงเทพ, คอนโดอารีย์, ศูนย์การค้า" : "e.g. Home, Office, Condo...", text: $name)
                                .padding(12)
                                .background(RoundedRectangle(cornerRadius: 12).fill(colorScheme == .dark ? Color.white.opacity(0.12) : Color.white))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.1, green: 0.15, blue: 0.25))
                        }
                        .padding(.horizontal, 20)
                        
                        // 3. Interactive Map Picker
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(isThai ? "แตะบนแผนที่เพื่อเลือกจุดตำแหน่ง" : "Tap on map to select location pin")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(red: 0.45, green: 0.5, blue: 0.6))
                                Spacer()
                                Image(systemName: "hand.tap.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.cyan)
                            }
                            
                            MapReader { proxy in
                                Map(position: $position) {
                                    Marker(name.isEmpty ? (isThai ? "ตำแหน่งที่เลือก" : "Selected Location") : name, systemImage: "mappin.circle.fill", coordinate: selectedCoordinate)
                                        .tint(.red)
                                }
                                .onTapGesture { screenPoint in
                                    if let coord = proxy.convert(screenPoint, from: .local) {
                                        selectedCoordinate = coord
                                        reverseGeocode(coord)
                                    }
                                }
                            }
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(colorScheme == .dark ? Color.white.opacity(0.2) : Color.white, lineWidth: 1.5)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)
                        
                        // Coordinates Badge Info
                        HStack(spacing: 8) {
                            Image(systemName: "location.circle.fill")
                                .foregroundColor(.blue)
                            Text("GPS: \(String(format: "%.4f", selectedCoordinate.latitude)), \(String(format: "%.4f", selectedCoordinate.longitude))")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.8) : Color(red: 0.2, green: 0.25, blue: 0.35))
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.8))
                        )
                        .padding(.horizontal, 20)
                        
                        // Save Button
                        Button {
                            let placeTitle = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? (isThai ? "สถานที่บันทึก" : "Saved Location") : name
                            onAdd(placeTitle, selectedCoordinate.latitude, selectedCoordinate.longitude)
                            isPresented = false
                        } label: {
                            Text(isThai ? "บันทึกตำแหน่งนี้" : "Save Location")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Capsule().fill(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing)))
                                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }
}


/// Detailed Modal Sheet displayed when tapping a Saved Location card
struct SavedLocationDetailSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("appLanguage") private var appLanguage: String = "th"
    @Binding var location: SavedLocation?
    var onSelectAsActive: (SavedLocation) -> Void
    
    private var isThai: Bool { appLanguage == "th" }
    
    var body: some View {
        if let targetLocation = location {
            let severity = AQISeverity.from(aqi: targetLocation.cachedAQI)
            
            NavigationStack {
                ZStack {
                    ParticleBackgroundView(severity: severity)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Top Header & AQI Gauge Side-by-Side with Mascot
                            HStack(alignment: .center, spacing: 10) {
                                AQICircularGauge(aqi: targetLocation.cachedAQI, severity: severity)
                                    .scaleEffect(0.9)
                                
                                AirDragonMascotView(severity: severity)
                            }
                            .padding(.top, 10)
                            
                            // Location Info Header Card
                            GlassCard(cornerRadius: 18, padding: 14) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(targetLocation.name)
                                            .font(.system(size: 20, weight: .black, design: .rounded))
                                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.1, green: 0.15, blue: 0.25))
                                        
                                        Text("GPS: \(String(format: "%.4f", targetLocation.latitude)), \(String(format: "%.4f", targetLocation.longitude))")
                                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(red: 0.45, green: 0.5, blue: 0.6))
                                    }
                                    Spacer()
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Detailed Pollutants Breakdown
                            GlassCard(cornerRadius: 22, padding: 16) {
                                VStack(alignment: .leading, spacing: 14) {
                                    Text(isThai ? "สถิติมลพิษในอากาศ" : "AIR POLLUTANTS BREAKDOWN")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(red: 0.45, green: 0.5, blue: 0.6))
                                        .tracking(1.2)
                                    
                                    PollutantProgressBar(title: "PM2.5 (Fine Particulate)", val: targetLocation.cachedPM25, maxVal: 150, unit: "µg/m³", color: severity.primaryColor)
                                    PollutantProgressBar(title: "PM10 (Coarse Particulate)", val: targetLocation.cachedPM25 * 1.4, maxVal: 200, unit: "µg/m³", color: .yellow)
                                    PollutantProgressBar(title: "O3 (Ozone)", val: 24.5, maxVal: 100, unit: "ppb", color: .cyan)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Health Recommendations ("ควรปฏิบัติตัวอย่างไร")
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(isThai ? "ข้อแนะนำในการปฏิบัติตน" : "HOW TO PROTECT YOURSELF")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(red: 0.45, green: 0.5, blue: 0.6))
                                        .tracking(1.2)
                                    Spacer()
                                }
                                .padding(.horizontal, 24)
                                
                                VStack(spacing: 10) {
                                    ForEach(severity.healthAdviceList(isThai: isThai)) { advice in
                                        HealthAdviceCard(item: advice, severity: severity)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            // Button to Set as Active Radar Location
                            Button {
                                onSelectAsActive(targetLocation)
                                location = nil
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "radar")
                                        .font(.system(size: 16, weight: .bold))
                                    Text(isThai ? "ดูเรดาร์สดบนหน้าหลัก" : "View Live Radar on Dashboard")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    Capsule()
                                        .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                                        .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            .padding(.bottom, 30)
                        }
                    }
                }
                .navigationTitle(isThai ? "รายละเอียดคุณภาพอากาศ" : "Location Air Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            location = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : Color(red: 0.4, green: 0.45, blue: 0.55))
                        }
                    }
                }
            }
        }
    }
}

