import React from 'react';
import { CurrentWeather } from '@/types/weather';
import { getTimeFromTimestamp } from '@/lib/utils';
import { motion } from 'framer-motion';

interface WeatherDetailCardProps {
  title: string;
  value: string;
  subtitle?: string;
  icon: string;
  delay: number;
}

function WeatherDetailCard({ title, value, subtitle, icon, delay }: WeatherDetailCardProps) {
  return (
    <motion.div 
      className="backdrop-blur bg-white/5 rounded-xl p-4"
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3, delay }}
    >
      <div className="flex items-center gap-2 mb-2 text-sm opacity-80">
        <span className="material-icons text-lg">{icon}</span>
        <span>{title}</span>
      </div>
      <div className="text-xl font-medium">{value}</div>
      {subtitle && (
        <div className="text-xs opacity-70 mt-1">{subtitle}</div>
      )}
    </motion.div>
  );
}

interface WeatherDetailsProps {
  weather: CurrentWeather;
  timezone: number;
}

export default function WeatherDetails({ weather, timezone }: WeatherDetailsProps) {
  const windDirection = () => {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    const index = Math.round(weather.wind_deg / 45) % 8;
    return directions[index];
  };

  const uvLevel = () => {
    if (weather.uvi < 3) return 'Low';
    if (weather.uvi < 6) return 'Moderate';
    if (weather.uvi < 8) return 'High';
    if (weather.uvi < 11) return 'Very High';
    return 'Extreme';
  };

  const visibilityText = () => {
    const visKm = Math.round(weather.visibility / 1000);
    return `${visKm} km`;
  };

  const pressureTrend = () => {
    // This would need historical data to be accurate
    return 'Stable';
  };

  const sunriseTime = getTimeFromTimestamp(weather.sunrise, timezone);
  const sunsetTime = getTimeFromTimestamp(weather.sunset, timezone);

  return (
    <motion.div 
      className="glass-panel px-4 py-6"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.5, delay: 0.8 }}
    >
      <h2 className="text-xl font-semibold mb-4">Weather Details</h2>
      <div className="grid grid-cols-2 gap-4">
        <WeatherDetailCard
          title="Wind"
          value={`${Math.round(weather.wind_speed * 3.6)} km/h`} // Convert m/s to km/h
          subtitle={`${windDirection()} Direction`}
          icon="air"
          delay={0.1}
        />
        
        <WeatherDetailCard
          title="Humidity"
          value={`${weather.humidity}%`}
          subtitle={`Dew point: ${Math.round(weather.dew_point)}°`}
          icon="water_drop"
          delay={0.2}
        />
        
        <WeatherDetailCard
          title="UV Index"
          value={`${Math.round(weather.uvi)}`}
          subtitle={uvLevel()}
          icon="wb_sunny"
          delay={0.3}
        />
        
        <WeatherDetailCard
          title="Visibility"
          value={visibilityText()}
          subtitle={weather.visibility >= 10000 ? "Clear conditions" : "Limited visibility"}
          icon="visibility"
          delay={0.4}
        />
        
        <WeatherDetailCard
          title="Pressure"
          value={`${weather.pressure} hPa`}
          subtitle={pressureTrend()}
          icon="compress"
          delay={0.5}
        />
        
        <WeatherDetailCard
          title="Sunrise"
          value={sunriseTime}
          subtitle={`Sunset: ${sunsetTime}`}
          icon="wb_twilight"
          delay={0.6}
        />
      </div>
    </motion.div>
  );
}
