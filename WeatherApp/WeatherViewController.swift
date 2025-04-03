import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    // MARK: - Properties
    private let weatherService = WeatherService()
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    private var currentWeather: WeatherData?
    private var hourlyForecasts: [HourlyForecast]?
    private var dailyForecasts: [DailyForecast]?
    private var savedLocations: [SavedLocation] = []
    
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let locationButton = UIButton(type: .system)
    private let refreshButton = UIButton(type: .system)
    
    private let temperatureLabel = UILabel()
    private let conditionLabel = UILabel()
    private let highLowLabel = UILabel()
    private let weatherIcon = UIImageView()
    
    private let hourlyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: 60, height: 100)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private let dailyTableView = UITableView()
    private let weatherDetailsView = UIView()
    
    // Temperature unit toggle
    private var temperatureUnit: TemperatureUnit = .celsius {
        didSet {
            updateTemperatureDisplay()
        }
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
        
        // Initial configuration of UI components
        configureNavigationBar()
        configureScrollView()
        configureHeaderView()
        configureMainWeatherInfo()
        configureHourlyForecast()
        configureDailyForecast()
        configureWeatherDetails()
        
        // Hide navigation bar by default
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkLocationAuthorization()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(named: "ClearDayBackground") ?? .systemBlue
        
        // Setup UI components
        setupScrollView()
        setupLocationHeader()
        setupMainWeatherInfo()
        setupHourlyForecast()
        setupDailyForecast()
        setupWeatherDetails()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    private func setupLocationHeader() {
        // Location Header
        contentView.addSubview(locationButton)
        contentView.addSubview(refreshButton)
        
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        
        locationButton.setTitle("Current Location", for: .normal)
        locationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        locationButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        locationButton.tintColor = .white
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        
        refreshButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        refreshButton.tintColor = .white
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            locationButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            locationButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            refreshButton.centerYAnchor.constraint(equalTo: locationButton.centerYAnchor),
            refreshButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupMainWeatherInfo() {
        // Main Weather Info
        contentView.addSubview(weatherIcon)
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(conditionLabel)
        contentView.addSubview(highLowLabel)
        
        weatherIcon.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        conditionLabel.translatesAutoresizingMaskIntoConstraints = false
        highLowLabel.translatesAutoresizingMaskIntoConstraints = false
        
        weatherIcon.contentMode = .scaleAspectFit
        weatherIcon.image = UIImage(systemName: "sun.max.fill")
        weatherIcon.tintColor = .white
        
        temperatureLabel.text = "--°"
        temperatureLabel.font = UIFont.systemFont(ofSize: 72, weight: .thin)
        temperatureLabel.textColor = .white
        temperatureLabel.textAlignment = .center
        
        conditionLabel.text = "Loading..."
        conditionLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        conditionLabel.textColor = .white
        conditionLabel.textAlignment = .center
        
        highLowLabel.text = "H:--° L:--°"
        highLowLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        highLowLabel.textColor = .white
        highLowLabel.textAlignment = .center
        
        NSLayoutConstraint.activate([
            weatherIcon.topAnchor.constraint(equalTo: locationButton.bottomAnchor, constant: 32),
            weatherIcon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            weatherIcon.widthAnchor.constraint(equalToConstant: 120),
            weatherIcon.heightAnchor.constraint(equalToConstant: 120),
            
            temperatureLabel.topAnchor.constraint(equalTo: weatherIcon.bottomAnchor, constant: 16),
            temperatureLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            conditionLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 8),
            conditionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            highLowLabel.topAnchor.constraint(equalTo: conditionLabel.bottomAnchor, constant: 8),
            highLowLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    private func setupHourlyForecast() {
        // Hourly Forecast
        contentView.addSubview(hourlyCollectionView)
        hourlyCollectionView.translatesAutoresizingMaskIntoConstraints = false
        hourlyCollectionView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        hourlyCollectionView.layer.cornerRadius = 16
        hourlyCollectionView.showsHorizontalScrollIndicator = false
        
        hourlyCollectionView.register(HourlyForecastCell.self, forCellWithReuseIdentifier: "HourlyForecastCell")
        hourlyCollectionView.dataSource = self
        hourlyCollectionView.delegate = self
        
        NSLayoutConstraint.activate([
            hourlyCollectionView.topAnchor.constraint(equalTo: highLowLabel.bottomAnchor, constant: 32),
            hourlyCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hourlyCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            hourlyCollectionView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func setupDailyForecast() {
        // Daily Forecast
        contentView.addSubview(dailyTableView)
        dailyTableView.translatesAutoresizingMaskIntoConstraints = false
        dailyTableView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        dailyTableView.layer.cornerRadius = 16
        dailyTableView.isScrollEnabled = false
        dailyTableView.separatorStyle = .none
        
        dailyTableView.register(DailyForecastCell.self, forCellReuseIdentifier: "DailyForecastCell")
        dailyTableView.dataSource = self
        dailyTableView.delegate = self
        
        let dailyTableViewHeight: CGFloat = 7 * 50  // 7 days x 50 points per row
        
        NSLayoutConstraint.activate([
            dailyTableView.topAnchor.constraint(equalTo: hourlyCollectionView.bottomAnchor, constant: 16),
            dailyTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dailyTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dailyTableView.heightAnchor.constraint(equalToConstant: dailyTableViewHeight)
        ])
    }
    
    private func setupWeatherDetails() {
        // Weather Details (grid view for metrics)
        contentView.addSubview(weatherDetailsView)
        weatherDetailsView.translatesAutoresizingMaskIntoConstraints = false
        weatherDetailsView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        weatherDetailsView.layer.cornerRadius = 16
        
        NSLayoutConstraint.activate([
            weatherDetailsView.topAnchor.constraint(equalTo: dailyTableView.bottomAnchor, constant: 16),
            weatherDetailsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            weatherDetailsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            weatherDetailsView.heightAnchor.constraint(equalToConstant: 300),
            weatherDetailsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
        
        // Weather details grid will be populated when data is available
    }
    
    // MARK: - Location Manager Setup
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            showLocationAccessDeniedAlert()
        @unknown default:
            break
        }
    }
    
    // MARK: - Actions
    @objc private func locationButtonTapped() {
        // Show location selection modal
        let locationVC = LocationSelectionViewController(savedLocations: savedLocations)
        locationVC.delegate = self
        let navController = UINavigationController(rootViewController: locationVC)
        present(navController, animated: true)
    }
    
    @objc private func refreshButtonTapped() {
        // Refresh weather data
        if let location = currentLocation {
            fetchWeather(for: location)
        } else {
            locationManager.requestLocation()
        }
    }
    
    @objc private func temperatureUnitButtonTapped() {
        // Toggle temperature unit
        temperatureUnit = temperatureUnit == .celsius ? .fahrenheit : .celsius
    }
    
    // MARK: - Weather Data
    private func fetchWeather(for location: CLLocation) {
        // Show loading state
        updateUIForLoading(true)
        
        // Fetch weather data from service
        weatherService.fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.updateUIForLoading(false)
                
                switch result {
                case .success(let weatherResponse):
                    self.currentWeather = weatherResponse.current
                    self.hourlyForecasts = weatherResponse.hourly
                    self.dailyForecasts = weatherResponse.daily
                    
                    // Update UI with new data
                    self.updateWeatherUI()
                    
                case .failure(let error):
                    self.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func updateWeatherUI() {
        guard let currentWeather = currentWeather else { return }
        
        // Update background based on weather condition and time
        updateBackgroundForWeather(weatherId: currentWeather.weather[0].id)
        
        // Update main weather info
        updateTemperatureDisplay()
        conditionLabel.text = currentWeather.weather[0].description.capitalized
        
        // Update weather icon
        let isDay = isTimeDay(sunrise: currentWeather.sunrise, sunset: currentWeather.sunset, current: currentWeather.dt)
        weatherIcon.image = getWeatherIcon(weatherId: currentWeather.weather[0].id, isDay: isDay)
        
        // Update high/low if daily forecast is available
        if let todayForecast = dailyForecasts?.first {
            let highTemp = formatTemperature(todayForecast.temp.max, unit: temperatureUnit)
            let lowTemp = formatTemperature(todayForecast.temp.min, unit: temperatureUnit)
            highLowLabel.text = "H:\(highTemp) L:\(lowTemp)"
        }
        
        // Refresh collection and table views
        hourlyCollectionView.reloadData()
        dailyTableView.reloadData()
        
        // Update weather details
        updateWeatherDetailsView()
    }
    
    private func updateTemperatureDisplay() {
        guard let currentWeather = currentWeather else { return }
        
        let temperature = formatTemperature(currentWeather.temp, unit: temperatureUnit)
        temperatureLabel.text = temperature
    }
    
    private func updateBackgroundForWeather(weatherId: Int) {
        // Set background color based on weather condition
        let backgroundColor: UIColor
        
        // Simple logic to determine background color based on weather ID
        switch weatherId {
        case 200...299: // Thunderstorm
            backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        case 300...399: // Drizzle
            backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 1.0)
        case 500...599: // Rain
            backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.5, alpha: 1.0)
        case 600...699: // Snow
            backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1.0)
        case 700...799: // Atmosphere (fog, mist, etc.)
            backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        case 800: // Clear
            backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0)
        case 801...899: // Clouds
            backgroundColor = UIColor(red: 0.5, green: 0.6, blue: 0.7, alpha: 1.0)
        default:
            backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0) // Default blue
        }
        
        // Animate the background color change
        UIView.animate(withDuration: 0.5) {
            self.view.backgroundColor = backgroundColor
        }
    }
    
    private func updateWeatherDetailsView() {
        // Clear existing subviews
        weatherDetailsView.subviews.forEach { $0.removeFromSuperview() }
        
        guard let weather = currentWeather else { return }
        
        // Configure grid layout
        let metrics: [(title: String, value: String, icon: String)] = [
            ("FEELS LIKE", formatTemperature(weather.feels_like, unit: temperatureUnit), "thermometer"),
            ("HUMIDITY", "\(weather.humidity)%", "humidity"),
            ("WIND", "\(Int(weather.wind_speed)) m/s", "wind"),
            ("UV INDEX", "\(weather.uvi)", "sun.max.fill"),
            ("VISIBILITY", "\(weather.visibility / 1000) km", "eye.fill"),
            ("PRESSURE", "\(weather.pressure) hPa", "gauge")
        ]
        
        // Create a 2x3 grid
        let columns = 2
        let rows = 3
        let cellWidth = (weatherDetailsView.bounds.width - 32) / CGFloat(columns)
        let cellHeight = (weatherDetailsView.bounds.height - 32) / CGFloat(rows)
        
        for (index, metric) in metrics.enumerated() {
            let row = index / columns
            let column = index % columns
            
            let x = 16 + CGFloat(column) * cellWidth
            let y = 16 + CGFloat(row) * cellHeight
            
            let metricView = createMetricView(
                title: metric.title,
                value: metric.value,
                icon: metric.icon,
                frame: CGRect(x: x, y: y, width: cellWidth, height: cellHeight)
            )
            
            weatherDetailsView.addSubview(metricView)
        }
    }
    
    private func createMetricView(title: String, value: String, icon: String, frame: CGRect) -> UIView {
        let view = UIView(frame: frame)
        
        let iconImageView = UIImageView(image: UIImage(systemName: icon))
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = .white.withAlphaComponent(0.7)
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        valueLabel.textColor = .white
        
        // Add subviews
        view.addSubview(iconImageView)
        view.addSubview(titleLabel)
        view.addSubview(valueLabel)
        
        // Configure layout
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            iconImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
        
        return view
    }
    
    // MARK: - Helper Methods
    private func updateUIForLoading(_ isLoading: Bool) {
        if isLoading {
            temperatureLabel.text = "--°"
            conditionLabel.text = "Loading..."
            highLowLabel.text = "H:--° L:--°"
        }
    }
    
    private func formatTemperature(_ kelvin: Double, unit: TemperatureUnit) -> String {
        switch unit {
        case .celsius:
            let celsius = kelvin - 273.15
            return "\(Int(round(celsius)))°C"
        case .fahrenheit:
            let fahrenheit = (kelvin - 273.15) * 9/5 + 32
            return "\(Int(round(fahrenheit)))°F"
        }
    }
    
    private func isTimeDay(sunrise: Double, sunset: Double, current: Double) -> Bool {
        return current >= sunrise && current < sunset
    }
    
    private func getWeatherIcon(weatherId: Int, isDay: Bool) -> UIImage? {
        // Return appropriate system icon based on weather condition and time of day
        let iconName: String
        
        switch weatherId {
        case 200...232: // Thunderstorm
            iconName = "cloud.bolt.rain.fill"
        case 300...321: // Drizzle
            iconName = "cloud.drizzle.fill"
        case 500...531: // Rain
            iconName = "cloud.rain.fill"
        case 600...622: // Snow
            iconName = "cloud.snow.fill"
        case 700...781: // Atmosphere (fog, mist, etc.)
            iconName = "cloud.fog.fill"
        case 800: // Clear
            iconName = isDay ? "sun.max.fill" : "moon.stars.fill"
        case 801...802: // Few clouds
            iconName = isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case 803...804: // Broken clouds and overcast
            iconName = "cloud.fill"
        default:
            iconName = "questionmark.circle.fill"
        }
        
        return UIImage(systemName: iconName)
    }
    
    // MARK: - Alerts
    private func showLocationAccessDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Access Required",
            message: "We need access to your location to show you local weather information. Please enable location services in Settings.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension WeatherViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(hourlyForecasts?.count ?? 0, 24) // Show max 24 hours
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyForecastCell", for: indexPath) as? HourlyForecastCell,
              let hourlyData = hourlyForecasts?[indexPath.item] else {
            return UICollectionViewCell()
        }
        
        // Format time from timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        let time = formatter.string(from: Date(timeIntervalSince1970: hourlyData.dt))
        
        // Check if it's day or night for this hour
        let isDay = isTimeDay(
            sunrise: currentWeather?.sunrise ?? 0,
            sunset: currentWeather?.sunset ?? 0,
            current: hourlyData.dt
        )
        
        cell.configure(
            time: time,
            temperature: formatTemperature(hourlyData.temp, unit: temperatureUnit),
            icon: getWeatherIcon(weatherId: hourlyData.weather[0].id, isDay: isDay)
        )
        
        return cell
    }
}

// MARK: - UITableView DataSource & Delegate
extension WeatherViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(dailyForecasts?.count ?? 0, 7) // Show max 7 days
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DailyForecastCell", for: indexPath) as? DailyForecastCell,
              let dailyData = dailyForecasts?[indexPath.row] else {
            return UITableViewCell()
        }
        
        // Format day name from timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let day = formatter.string(from: Date(timeIntervalSince1970: dailyData.dt))
        
        // Day 0 is today
        let displayDay = indexPath.row == 0 ? "Today" : day
        
        cell.configure(
            day: displayDay,
            high: formatTemperature(dailyData.temp.max, unit: temperatureUnit),
            low: formatTemperature(dailyData.temp.min, unit: temperatureUnit),
            icon: getWeatherIcon(weatherId: dailyData.weather[0].id, isDay: true)
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationManager.stopUpdatingLocation()
            currentLocation = location
            fetchWeather(for: location)
            
            // Update location name via reverse geocoding
            reverseGeocodeLocation(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    private func reverseGeocodeLocation(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self, error == nil, let placemark = placemarks?.first else { return }
            
            let locationName = placemark.locality ?? "Current Location"
            DispatchQueue.main.async {
                self.locationButton.setTitle(locationName, for: .normal)
            }
        }
    }
}

// MARK: - LocationSelectionDelegate
extension WeatherViewController: LocationSelectionDelegate {
    func didSelectLocation(_ location: SavedLocation) {
        // Update UI with the selected location
        locationButton.setTitle(location.name, for: .normal)
        
        // Create a CLLocation to fetch weather
        let selectedCLLocation = CLLocation(latitude: location.lat, longitude: location.lon)
        currentLocation = selectedCLLocation
        fetchWeather(for: selectedCLLocation)
    }
    
    func didSelectCurrentLocation() {
        // Request current location again
        locationManager.requestLocation()
    }
}

// MARK: - Temperature Unit
enum TemperatureUnit {
    case celsius
    case fahrenheit
}