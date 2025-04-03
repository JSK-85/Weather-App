import React from 'react';
import WeatherIcon from './WeatherIcon';
import { HourlyForecast as HourlyForecastType } from '@/types/weather';
import { getTimeFromTimestamp, isDay } from '@/lib/utils';
import { motion } from 'framer-motion';

interface HourlyForecastProps {
  hourlyData: HourlyForecastType[];
  timezone: number;
  sunrise: number;
  sunset: number;
}

export default function HourlyForecast({ 
  hourlyData, 
  timezone,
  sunrise,
  sunset
}: HourlyForecastProps) {
  if (!hourlyData || hourlyData.length === 0) {
    return null;
  }

  return (
    <motion.div 
      className="glass-panel rounded-t-3xl px-4 pt-8 pb-6"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5, delay: 0.6 }}
    >
      <h2 className="text-xl font-semibold mb-4">Hourly Forecast</h2>
      <div className="flex overflow-x-auto custom-scrollbar pb-4 gap-4">
        {hourlyData.map((hour, index) => {
          const time = getTimeFromTimestamp(hour.dt, timezone);
          const daylight = isDay(sunrise, sunset, hour.dt);
          
          return (
            <motion.div 
              key={hour.dt}
              className="flex-shrink-0 flex flex-col items-center gap-2 min-w-[60px]"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.3, delay: 0.1 * (index % 8) }}
            >
              <div className="text-sm font-medium">
                {index === 0 ? 'Now' : time}
              </div>
              <WeatherIcon 
                weatherId={hour.weather[0].id} 
                size="sm" 
                isDay={daylight}
              />
              <div className="text-lg font-medium">{hour.temp}°</div>
            </motion.div>
          );
        })}
      </div>
    </motion.div>
  );
}
