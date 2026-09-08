import SwiftUI
import SwiftData

/// Tab 2: Saved Places Screen with SwiftData location bookmarking, glassmorphic cards, and search filtering
struct SavedPlacesView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedLocation.createdAt, order: .reverse) private var savedLocations: [SavedLocation]
    
    @AppStorage("appLanguage") private var appLanguage: String = "th"
    @ObservedObject var viewModel: AirSenseViewModel
    @State private var showingAddSheet: Bool = false
    @State private var selectedLocationForDetail: SavedLocation? = nil
    @State private var searchFilter: String = ""
    
    private var isThai: Bool { appLanguage == "th" }
    
    var filteredLocations: [SavedLocation] {
        if searchFilter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return savedLocations
        } else {
            return savedLocations.filter { $0.name.localizedCaseInsensitiveContains(searchFilter) }
        }
    }
    
    var body: some View {
        ZStack {
            ParticleBackgroundView(severity: viewModel.currentSeverity)
            
            VStack(spacing: 16) {
                // Header Bar with (+) Button
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isThai ? "สถานที่ที่บันทึกไว้" : "Saved Places")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.1, green: 0.15, blue: 0.25))
                        
                        Text(isThai ? "\(savedLocations.count) รายการที่บันทึกไว้" : "\(savedLocations.count) BOOKMARKED LOCATIONS")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(red: 0.45, green: 0.5, blue: 0.6))
                            .tracking(1.2)
                    }
                    
                    Spacer()
                    
                    Button {
                        showingAddSheet = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18, weight: .bold))
                            Text(isThai ? "เพิ่มสถานที่" : "Add Location")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing)))
                        .shadow(color: Color.blue.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Search Bar Filter
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(red: 0.45, green: 0.5, blue: 0.6))
                    
                    TextField(isThai ? "ค้นหาจากชื่อสถานที่ที่บันทึกไว้..." : "Search saved locations...", text: $searchFilter)
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.1, green: 0.15, blue: 0.25))
                    
                    if !searchFilter.isEmpty {
                        Button {
                            searchFilter = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.12) : Color.white.opacity(0.85))
                        .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(colorScheme == .dark ? Color.white.opacity(0.2) : Color.white, lineWidth: 1.5))
                )
                .padding(.horizontal, 20)
                
                // List of Saved Places Cards
                if filteredLocations.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: searchFilter.isEmpty ? "bookmark.slash.fill" : "magnifyingglass")
                            .font(.system(size: 44))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.4) : Color(red: 0.75, green: 0.8, blue: 0.85))
                        
                        Text(searchFilter.isEmpty ? (isThai ? "ยังไม่มีสถานที่ที่บันทึกไว้" : "No Saved Places Yet") : (isThai ? "ไม่พบสถานที่ชื่อ \"\(searchFilter)\"" : "No locations found for \"\(searchFilter)\""))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(red: 0.25, green: 0.3, blue: 0.4))
                        
                        Text(searchFilter.isEmpty ? (isThai ? "กดปุ่ม (+ เพิ่มสถานที่) เพื่อบุ๊คมาร์ก บ้าน มหาวิทยาลัย หรือที่ทำงานของคุณ" : "Tap (+ Add Location) to bookmark your home, office, or favorite spots.") : (isThai ? "ลองค้นหาด้วยคำอื่น หรือกดเพิ่มสถานที่ใหม่" : "Try searching with a different term or add a new place."))
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(red: 0.45, green: 0.5, blue: 0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Spacer()
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredLocations) { location in
                                let severity = AQISeverity.from(aqi: location.cachedAQI)
                                
                                Button {
                                    selectedLocationForDetail = location
                                } label: {
                                    GlassCard(cornerRadius: 20, padding: 16) {
                                        HStack(spacing: 14) {
                                            Text(severity.badgeDot)
                                                .font(.system(size: 24))
                                            
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(location.name)
                                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.1, green: 0.15, blue: 0.25))
                                                
                                                Text("PM2.5: \(String(format: "%.1f", location.cachedPM25)) µg/m³")
                                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(red: 0.4, green: 0.45, blue: 0.55))
                                            }
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .trailing, spacing: 2) {
                                                Text("\(location.cachedAQI)")
                                                    .font(.system(size: 26, weight: .black, design: .rounded))
                                                    .foregroundColor(severity.primaryColor)
                                                
                                                Text(severity.title)
                                                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                                                    .foregroundColor(severity.primaryColor)
                                            }
                                        }
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        modelContext.delete(location)
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddLocationSheet(isPresented: $showingAddSheet, onAdd: { name, lat, lon in
                let newLoc = SavedLocation(name: name, latitude: lat, longitude: lon, cachedAQI: Int.random(in: 60...160), cachedPM25: Double.random(in: 20...70))
                modelContext.insert(newLoc)
            })
        }
        .sheet(item: $selectedLocationForDetail) { location in
            SavedLocationDetailSheet(location: $selectedLocationForDetail) { targetLoc in
                Task {
                    await viewModel.fetchAQIForCity(cityName: targetLoc.name, modelContext: modelContext)
                }
            }
        }
        .onAppear {
            // Seed sample locations if database is empty for demo
            if savedLocations.isEmpty {
                let loc1 = SavedLocation(name: "🏠 Home (Sukhumvit)", latitude: 13.7367, longitude: 100.5604, cachedAQI: 152, cachedPM25: 65.4)
                let loc2 = SavedLocation(name: "🎓 Kasetsart University", latitude: 13.8479, longitude: 100.5696, cachedAQI: 85, cachedPM25: 28.1)
                let loc3 = SavedLocation(name: "🏢 Silom Office", latitude: 13.7268, longitude: 100.5312, cachedAQI: 128, cachedPM25: 46.2)
                modelContext.insert(loc1)
                modelContext.insert(loc2)
                modelContext.insert(loc3)
            }
        }
    }
}
