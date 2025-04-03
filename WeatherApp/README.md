# iOS Weather App

This is a modern iOS weather application with an Apple-inspired design, providing comprehensive weather information, forecasts, and detailed weather metrics.

## Features

- Current weather conditions with dynamic backgrounds
- Hourly forecast for the next 24 hours
- 7-day daily forecast
- Detailed weather metrics (wind, humidity, pressure, etc.)
- Multiple saved locations
- Location search functionality
- Temperature unit toggle (Celsius/Fahrenheit)
- Weather alerts display
- Smooth animations and transitions

## Requirements

- iOS 14.0+
- Xcode 13.0+
- Swift 5.5+
- OpenWeatherMap API Key

## Setup

1. Clone this repository
2. Open the project in Xcode
3. In `WeatherService.swift`, replace `YOUR_OPENWEATHER_API_KEY` with your actual OpenWeatherMap API key
4. Run the project on a simulator or device

## Architecture

This app follows a standard iOS MVC (Model-View-Controller) architecture:

- **Models:** Defines data structures for weather information
- **Views:** Custom UI components like cells for forecasts
- **Controllers:** Manages the data flow between models and views

## Dependencies

The app uses the following dependencies (via CocoaPods):

- **Kingfisher:** For image loading and caching
- **SkeletonView:** For loading states
- **Lottie:** For animations

## API

The app uses OpenWeatherMap's One Call API 3.0 for weather data and Geocoding API for location search. You'll need to sign up for an API key at [OpenWeatherMap](https://openweathermap.org/api).

## License

This project is available under the MIT license. See the LICENSE file for more info.