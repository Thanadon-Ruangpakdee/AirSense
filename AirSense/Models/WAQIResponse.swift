import Foundation

/// Root Response from WAQI REST API (https://api.waqi.info/)
struct WAQIResponse: Codable {
    let status: String
    let data: WAQIData?
}

struct WAQIData: Codable {
    let aqi: Int
    let idx: Int?
    let city: WAQICity?
    let iaqi: WAQIIAQI?
    let time: WAQITime?
    
    var pm25Value: Double {
        iaqi?.pm25?.v ?? Double(aqi) * 0.42
    }
    
    var pm10Value: Double {
        iaqi?.pm10?.v ?? Double(aqi) * 0.58
    }
    
    var o3Value: Double {
        iaqi?.o3?.v ?? 14.2
    }
    
    var no2Value: Double {
        iaqi?.no2?.v ?? 8.6
    }
    
    var so2Value: Double {
        iaqi?.so2?.v ?? 3.1
    }
    
    var coValue: Double {
        iaqi?.co?.v ?? 0.8
    }
    
    var cityName: String {
        city?.name ?? "Bangkok, Thailand"
    }
}

struct WAQICity: Codable {
    let name: String
    let geo: [Double]?
}

struct WAQIIAQI: Codable {
    let pm25: WAQIVal?
    let pm10: WAQIVal?
    let o3: WAQIVal?
    let no2: WAQIVal?
    let so2: WAQIVal?
    let co: WAQIVal?
}

struct WAQIVal: Codable {
    let v: Double
}

struct WAQITime: Codable {
    let s: String?
    let tz: String?
}
