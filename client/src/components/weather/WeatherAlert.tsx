import React from 'react';
import { WeatherAlert as WeatherAlertType } from '@/types/weather';
import { getTimeFromTimestamp } from '@/lib/utils';
import { motion } from 'framer-motion';

interface WeatherAlertProps {
  alert: WeatherAlertType;
  timezone: number;
}

export default function WeatherAlert({ alert, timezone }: WeatherAlertProps) {
  const startTime = getTimeFromTimestamp(alert.start, timezone);
  const endTime = getTimeFromTimestamp(alert.end, timezone);
  
  return (
    <motion.div 
      className="backdrop-blur bg-danger/20 px-4 py-4 mt-4 mx-4 rounded-xl border border-white/20"
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ duration: 0.3 }}
    >
      <div className="flex items-start gap-3">
        <span className="material-icons text-2xl text-warning">warning</span>
        <div>
          <h3 className="font-medium">{alert.event}</h3>
          <p className="text-sm opacity-90">{alert.description}</p>
          <p className="text-xs mt-1 opacity-80">
            {startTime} - {endTime} • {alert.sender_name}
          </p>
        </div>
      </div>
    </motion.div>
  );
}
