import React, { useEffect, useState } from 'react';
import { getWeatherBackground, isDay } from '@/lib/utils';
import { cn } from '@/lib/utils';

interface WeatherBackdropProps {
  weatherId: number;
  sunrise: number;
  sunset: number;
  timestamp: number;
  children: React.ReactNode;
  className?: string;
}

export default function WeatherBackdrop({
  weatherId,
  sunrise,
  sunset,
  timestamp,
  children,
  className,
}: WeatherBackdropProps) {
  const [bgClass, setBgClass] = useState<string>('bg-clear-day');
  
  useEffect(() => {
    const daylight = isDay(sunrise, sunset, timestamp);
    setBgClass(getWeatherBackground(weatherId, daylight));
  }, [weatherId, sunrise, sunset, timestamp]);

  return (
    <div className={cn('min-h-screen transition-colors duration-1000', bgClass, className)}>
      {children}
    </div>
  );
}
