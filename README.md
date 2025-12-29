# Weather App

A full-stack weather application with web and iOS clients, providing comprehensive weather information, forecasts, and location management.

## Features

### Web Client
- 🌤️ **Current Weather Conditions** - Real-time weather data with dynamic backgrounds
- 📅 **Hourly Forecast** - 24-hour detailed forecast
- 📆 **Daily Forecast** - 7-day weather outlook
- 📍 **Location Management** - Search and save multiple locations
- 🌍 **Geolocation Support** - Automatic location detection
- 🌡️ **Temperature Units** - Toggle between Celsius and Fahrenheit
- ⚠️ **Weather Alerts** - Display important weather warnings
- 📊 **Detailed Metrics** - Wind speed, humidity, pressure, UV index, and more
- 🎨 **Modern UI** - Beautiful, responsive design with smooth animations

### iOS Client
- Native iOS experience with Apple-inspired design
- All web features available on iOS
- Smooth animations and transitions
- Optimized for iPhone and iPad

## Tech Stack

### Frontend (Web)
- **React 18** - UI framework
- **TypeScript** - Type safety
- **Vite** - Build tool and dev server
- **Tailwind CSS** - Styling
- **shadcn/ui** - UI component library
- **React Query** - Data fetching and caching
- **Framer Motion** - Animations
- **Wouter** - Lightweight routing

### Backend
- **Express.js** - Web server
- **TypeScript** - Type safety
- **Drizzle ORM** - Database toolkit
- **OpenWeatherMap API** - Weather data source

### iOS
- **Swift** - Native iOS development
- **CocoaPods** - Dependency management
- **Kingfisher** - Image loading and caching
- **Lottie** - Animations
- **SkeletonView** - Loading states

## Prerequisites

- **Node.js** 18+ and npm
- **OpenWeatherMap API Key** - [Get one here](https://openweathermap.org/api)
- For iOS development:
  - **Xcode** 13.0+
  - **CocoaPods** (`sudo gem install cocoapods`)
  - **iOS 14.0+** deployment target

## Installation

### 1. Clone the repository

```bash
git clone <repository-url>
cd Weather-App
```

### 2. Install dependencies

```bash
npm install
```

### 3. Configure environment variables

Create a `.env` file in the root directory:

```env
OPENWEATHER_API_KEY=your_api_key_here
```

### 4. Set up the database (optional)

If using a database for persistent storage:

```bash
npm run db:push
```

## Running the Application

### Development Mode

Start the development server:

```bash
npm run dev
```

The application will be available at `http://localhost:5000`

### Production Build

Build for production:

```bash
npm run build
```

Start the production server:

```bash
npm start
```

## iOS Setup

1. Navigate to the iOS project directory:

```bash
cd WeatherApp
```

2. Install CocoaPods dependencies:

```bash
pod install
```

3. Open the workspace in Xcode:

```bash
open project.xcworkspace
```

4. Configure the API key:
   - Open `WeatherService.swift`
   - Replace `YOUR_OPENWEATHER_API_KEY` with your actual API key

5. Run the project on a simulator or device

## API Endpoints

The backend provides the following REST API endpoints:

### Weather Data
- `GET /api/weather/onecall?lat={lat}&lon={lon}` - Get comprehensive weather data for a location
- `GET /api/weather/geocode?q={query}` - Search for locations by name
- `GET /api/weather/reverse-geocode?lat={lat}&lon={lon}` - Get location name from coordinates

### Location Management
- `GET /api/weather/locations` - Get all saved locations
- `POST /api/weather/locations` - Add a new saved location
  ```json
  {
    "name": "New York",
    "lat": 40.7128,
    "lon": -74.0060,
    "country": "US",
    "state": "NY"
  }
  ```
- `DELETE /api/weather/locations/:id` - Remove a saved location

## Project Structure

```
Weather-App/
├── client/                 # Web client application
│   ├── src/
│   │   ├── components/     # React components
│   │   │   ├── ui/         # shadcn/ui components
│   │   │   └── weather/    # Weather-specific components
│   │   ├── hooks/          # Custom React hooks
│   │   ├── pages/          # Page components
│   │   ├── types/          # TypeScript type definitions
│   │   └── lib/            # Utility functions
│   └── index.html
├── server/                 # Backend server
│   ├── index.ts           # Server entry point
│   ├── routes.ts          # API route definitions
│   ├── weather.ts         # Weather API handlers
│   └── storage.ts         # Storage abstraction
├── shared/                # Shared code between client and server
│   └── schema.ts          # Shared schemas
├── WeatherApp/           # iOS application
│   ├── WeatherApp/        # iOS app source
│   └── project.xcworkspace
├── package.json
├── vite.config.ts
└── tsconfig.json
```

## Development

### Type Checking

```bash
npm run check
```

### Database Migrations

```bash
npm run db:push
```

## Features in Detail

### Dynamic Weather Backgrounds
The app displays different background colors and gradients based on:
- Current weather conditions (clear, cloudy, rain, etc.)
- Time of day (sunrise/sunset detection)
- Weather severity

### Location Search
- Search for locations worldwide
- Autocomplete suggestions
- Save favorite locations for quick access
- View current weather for all saved locations

### Weather Details
Comprehensive weather information including:
- Temperature (current, high, low)
- Feels like temperature
- Humidity percentage
- Wind speed and direction
- Atmospheric pressure
- UV index
- Visibility
- Cloud coverage
- Sunrise and sunset times

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Weather data provided by [OpenWeatherMap](https://openweathermap.org/)
- UI components from [shadcn/ui](https://ui.shadcn.com/)
- Icons from [Lucide](https://lucide.dev/)

## Support

For issues, questions, or contributions, please open an issue on the repository.

