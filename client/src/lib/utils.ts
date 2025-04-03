import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function kelvinToCelsius(kelvin: number): number {
  return Math.round(kelvin - 273.15);
}

export function kelvinToFahrenheit(kelvin: number): number {
  return Math.round((kelvin - 273.15) * 9/5 + 32);
}

export function convertTemp(kelvin: number, unit: 'celsius' | 'fahrenheit'): number {
  return unit === 'celsius' ? kelvinToCelsius(kelvin) : kelvinToFahrenheit(kelvin);
}

export function formatTemp(temp: number, unit: 'celsius' | 'fahrenheit'): string {
  return `${temp}°${unit === 'celsius' ? 'C' : 'F'}`;
}

export function getWeatherBackground(weatherId: number, isDay: boolean): string {
  // Weather condition codes as per OpenWeatherMap API
  // https://openweathermap.org/weather-conditions
  
  if (weatherId >= 200 && weatherId < 300) {
    return 'bg-thunderstorm';
  } else if (weatherId >= 300 && weatherId < 400) {
    return 'bg-rainy';
  } else if (weatherId >= 500 && weatherId < 600) {
    return 'bg-rainy';
  } else if (weatherId >= 600 && weatherId < 700) {
    return 'bg-snow';
  } else if (weatherId >= 700 && weatherId < 800) {
    if (weatherId === 731 || weatherId === 751 || weatherId === 761) {
      return 'bg-dust';
    }
    return 'bg-fog';
  } else if (weatherId === 800) {
    return isDay ? 'bg-clear-day' : 'bg-night';
  } else if (weatherId > 800) {
    return 'bg-cloudy';
  }
  
  return isDay ? 'bg-clear-day' : 'bg-night';
}

export function getTimeFromTimestamp(timestamp: number, timezone: number): string {
  const date = new Date((timestamp + timezone) * 1000);
  return date.toLocaleTimeString('en-US', {
    hour: 'numeric',
    minute: '2-digit',
    hour12: true,
    timeZone: 'UTC',
  });
}

export function getDayFromTimestamp(timestamp: number, timezone: number): string {
  const date = new Date((timestamp + timezone) * 1000);
  return date.toLocaleDateString('en-US', {
    weekday: 'short',
    timeZone: 'UTC',
  });
}

export function formatDate(timestamp: number, timezone: number): string {
  const date = new Date((timestamp + timezone) * 1000);
  return date.toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'long',
    day: 'numeric',
    timeZone: 'UTC',
  });
}

export function isDay(sunrise: number, sunset: number, current: number): boolean {
  return current > sunrise && current < sunset;
}
