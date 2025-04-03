import Foundation

// MARK: - Weather Response Model
struct WeatherResponse: Codable {
    var lat: Double
    var lon: Double
    var timezone: String
    var timezone_offset: Int
    var current: CurrentWeather
    var hourly: [HourlyForecast]
    var daily: [DailyForecast]
    var alerts: [WeatherAlert]?
}

// MARK: - Current Weather
struct CurrentWeather: Codable {
    var dt: Double
    var sunrise: Double
    var sunset: Double
    var temp: Double
    var feels_like: Double
    var pressure: Int
    var humidity: Int
    var dew_point: Double
    var uvi: Double
    var clouds: Int
    var visibility: Int
    var wind_speed: Double
    var wind_deg: Int
    var wind_gust: Double?
    var weather: [WeatherCondition]
    var rain: RainData?
    var snow: SnowData?
    
    // Non-API property for the location name (added after response)
    var location: String = "Loading..."
}

// MARK: - Hourly Forecast
struct HourlyForecast: Codable {
    var dt: Double
    var temp: Double
    var feels_like: Double
    var pressure: Int
    var humidity: Int
    var dew_point: Double
    var uvi: Double
    var clouds: Int
    var visibility: Int
    var wind_speed: Double
    var wind_deg: Int
    var wind_gust: Double?
    var weather: [WeatherCondition]
    var pop: Double
    var rain: RainData?
    var snow: SnowData?
}

// MARK: - Daily Forecast
struct DailyForecast: Codable {
    var dt: Double
    var sunrise: Double
    var sunset: Double
    var moonrise: Double
    var moonset: Double
    var moon_phase: Double
    var temp: DailyTemperature
    var feels_like: DailyFeelsLike
    var pressure: Int
    var humidity: Int
    var dew_point: Double
    var wind_speed: Double
    var wind_deg: Int
    var wind_gust: Double?
    var weather: [WeatherCondition]
    var clouds: Int
    var pop: Double
    var rain: Double?
    var snow: Double?
    var uvi: Double
}

// MARK: - Weather Condition
struct WeatherCondition: Codable {
    var id: Int
    var main: String
    var description: String
    var icon: String
}

// MARK: - Daily Temperature
struct DailyTemperature: Codable {
    var day: Double
    var min: Double
    var max: Double
    var night: Double
    var eve: Double
    var morn: Double
}

// MARK: - Daily Feels Like
struct DailyFeelsLike: Codable {
    var day: Double
    var night: Double
    var eve: Double
    var morn: Double
}

// MARK: - Rain Data
struct RainData: Codable {
    var oneHour: Double?
    
    enum CodingKeys: String, CodingKey {
        case oneHour = "1h"
    }
}

// MARK: - Snow Data
struct SnowData: Codable {
    var oneHour: Double?
    
    enum CodingKeys: String, CodingKey {
        case oneHour = "1h"
    }
}

// MARK: - Weather Alert
struct WeatherAlert: Codable {
    var sender_name: String
    var event: String
    var start: Double
    var end: Double
    var description: String
    var tags: [String]?
}

// MARK: - Location
struct Location: Codable {
    var name: String
    var lat: Double
    var lon: Double
    var country: String
    var state: String?
}

// MARK: - Saved Location
struct SavedLocation: Codable {
    var id: String
    var name: String
    var lat: Double
    var lon: Double
    var country: String
    var state: String?
    var current: CurrentLocationWeather?
}

// MARK: - Current Location Weather (simplified for saved locations)
struct CurrentLocationWeather: Codable {
    var temp: Double
    var weatherId: Int
    var description: String
}