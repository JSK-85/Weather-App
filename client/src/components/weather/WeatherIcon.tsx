import React from 'react';
import { cn } from '@/lib/utils';

interface WeatherIconProps {
  weatherId: number;
  className?: string;
  size?: 'sm' | 'md' | 'lg' | 'xl';
  isDay?: boolean;
}

export default function WeatherIcon({ 
  weatherId, 
  className, 
  size = 'md',
  isDay = true 
}: WeatherIconProps) {
  const getIconName = (id: number): string => {
    // Map OpenWeatherMap condition codes to Material Icons
    // https://openweathermap.org/weather-conditions
    
    if (id >= 200 && id < 300) {
      return 'thunderstorm';
    } else if (id >= 300 && id < 400) {
      return 'grain';
    } else if (id >= 500 && id < 600) {
      return id >= 520 ? 'water_drop' : 'water_drop';
    } else if (id >= 600 && id < 700) {
      return 'ac_unit';
    } else if (id >= 700 && id < 800) {
      if (id === 781) return 'cyclone';
      return 'foggy';
    } else if (id === 800) {
      return isDay ? 'wb_sunny' : 'nights_stay';
    } else if (id === 801) {
      return isDay ? 'partly_cloudy_day' : 'nights_stay';
    } else if (id > 801) {
      return 'wb_cloudy';
    }
    
    return isDay ? 'wb_sunny' : 'nights_stay';
  };

  const sizeClasses = {
    sm: 'text-2xl',
    md: 'text-4xl',
    lg: 'text-6xl',
    xl: 'text-8xl',
  };

  return (
    <span className={cn(
      'material-icons',
      sizeClasses[size],
      className
    )}>
      {getIconName(weatherId)}
    </span>
  );
}
