import React from 'react';
import WeatherIcon from './WeatherIcon';
import { motion } from 'framer-motion';
import { formatDate, isDay } from '@/lib/utils';

interface MainWeatherInfoProps {
  temperature: number;
  condition: string;
  weatherId: number;
  high: number;
  low: number;
  timestamp: number;
  sunrise: number;
  sunset: number;
  timezone: number;
}

export default function MainWeatherInfo({
  temperature,
  condition,
  weatherId,
  high,
  low,
  timestamp,
  sunrise,
  sunset,
  timezone
}: MainWeatherInfoProps) {
  const daylight = isDay(sunrise, sunset, timestamp);
  const date = formatDate(timestamp, timezone);

  return (
    <div className="pt-8 pb-12 px-4 text-center relative">
      <div className="flex flex-col items-center">
        <motion.div 
          className="mb-2" 
          initial={{ y: -20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ duration: 0.5 }}
        >
          <div className="animate-float">
            <WeatherIcon 
              weatherId={weatherId} 
              size="xl" 
              isDay={daylight}
            />
          </div>
        </motion.div>
        
        <motion.h1 
          className="text-7xl font-light mb-2"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.2 }}
        >
          {temperature}°
        </motion.h1>
        
        <motion.div 
          className="text-xl mb-2 opacity-90"
          initial={{ opacity: 0 }}
          animate={{ opacity: 0.9 }}
          transition={{ duration: 0.5, delay: 0.3 }}
        >
          {condition}
        </motion.div>
        
        <motion.div 
          className="flex items-center justify-center gap-2 text-lg opacity-80"
          initial={{ opacity: 0 }}
          animate={{ opacity: 0.8 }}
          transition={{ duration: 0.5, delay: 0.4 }}
        >
          <span>{high}°</span>
          <span className="mx-1">|</span>
          <span>{low}°</span>
        </motion.div>
        
        <motion.div 
          className="text-sm opacity-70 mt-2"
          initial={{ opacity: 0 }}
          animate={{ opacity: 0.7 }}
          transition={{ duration: 0.5, delay: 0.5 }}
        >
          {date}
        </motion.div>
      </div>
    </div>
  );
}
