import Foundation
import CoreLocation

// MARK: - Service errors
enum WeatherServiceError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case networkError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from the server"
        case .invalidData:
            return "Invalid data received"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Weather Service
class WeatherService {
    // OpenWeatherMap API key - this should be stored securely
    private let apiKey = "YOUR_OPENWEATHER_API_KEY"
    private let baseURL = "https://api.openweathermap.org"
    
    // MARK: - Weather Data Methods
    func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherResponse, WeatherServiceError>) -> Void) {
        // Create URL for OneCall API
        guard let url = URL(string: "\(baseURL)/data/3.0/onecall?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&exclude=minutely") else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Create and execute data task
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle any errors
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            // Check response status
            guard let httpResponse = response as? HTTPURLResponse, 
                  200...299 ~= httpResponse.statusCode else {
                completion(.failure(.invalidResponse))
                return
            }
            
            // Check if data exists
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            // Try to decode the data
            do {
                let decoder = JSONDecoder()
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                
                // Add location name using reverse geocoding
                self.reverseGeocodeLocation(latitude: latitude, longitude: longitude) { locationName in
                    var modifiedResponse = weatherResponse
                    modifiedResponse.current.location = locationName
                    completion(.success(modifiedResponse))
                }
            } catch {
                print("Decoding error:", error)
                completion(.failure(.invalidData))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Geocoding Methods
    func geocodeLocation(query: String, completion: @escaping (Result<[Location], WeatherServiceError>) -> Void) {
        // Encode the query string for URL
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/geo/1.0/direct?q=\(encodedQuery)&limit=5&appid=\(apiKey)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Create and execute data task
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle any errors
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            // Check response status
            guard let httpResponse = response as? HTTPURLResponse, 
                  200...299 ~= httpResponse.statusCode else {
                completion(.failure(.invalidResponse))
                return
            }
            
            // Check if data exists
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            // Try to decode the data
            do {
                let decoder = JSONDecoder()
                let locations = try decoder.decode([Location].self, from: data)
                completion(.success(locations))
            } catch {
                print("Decoding error:", error)
                completion(.failure(.invalidData))
            }
        }
        
        task.resume()
    }
    
    // Helper method to get location name from coordinates
    private func reverseGeocodeLocation(latitude: Double, longitude: Double, completion: @escaping (String) -> Void) {
        // Use CLGeocoder for reverse geocoding
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding error:", error.localizedDescription)
                completion("Unknown Location")
                return
            }
            
            if let placemark = placemarks?.first {
                let locationName = placemark.locality ?? placemark.name ?? "Unknown Location"
                completion(locationName)
            } else {
                completion("Unknown Location")
            }
        }
    }
}