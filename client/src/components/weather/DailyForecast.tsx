import React from 'react';
import WeatherIcon from './WeatherIcon';
import { DailyForecast as DailyForecastType } from '@/types/weather';
import { getDayFromTimestamp } from '@/lib/utils';
import { motion } from 'framer-motion';

interface DailyForecastProps {
  dailyData: DailyForecastType[];
  timezone: number;
}

export default function DailyForecast({ dailyData, timezone }: DailyForecastProps) {
  if (!dailyData || dailyData.length === 0) {
    return null;
  }

  return (
    <motion.div 
      className="glass-panel px-4 py-6"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.5, delay: 0.7 }}
    >
      <h2 className="text-xl font-semibold mb-4">10-Day Forecast</h2>
      <div className="flex flex-col">
        {dailyData.map((day, index) => {
          const dateLabel = index === 0 
            ? 'Today' 
            : getDayFromTimestamp(day.dt, timezone);
          
          return (
            <motion.div 
              key={day.dt}
              className="flex items-center justify-between py-3 border-b border-white/10"
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.3, delay: 0.1 * index }}
            >
              <div className="w-20 text-sm font-medium">{dateLabel}</div>
              <div className="flex items-center gap-2">
                <WeatherIcon weatherId={day.weather[0].id} size="sm" />
              </div>
              <div className="flex justify-end w-20 gap-2">
                <span className="text-sm opacity-80">{day.temp.min}°</span>
                <span className="text-sm">{day.temp.max}°</span>
              </div>
            </motion.div>
          );
        })}
      </div>
    </motion.div>
  );
}
