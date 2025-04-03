import React, { useState } from 'react';
import { useToast } from '@/hooks/use-toast';
import { useGeoLocation } from '@/hooks/useGeoLocation';
import { useWeather, useLocations } from '@/hooks/useWeather';
import { Location } from '@/types/weather';
import { motion } from 'framer-motion';

// Components
import WeatherBackdrop from '@/components/weather/WeatherBackdrop';
import LocationHeader from '@/components/weather/LocationHeader';
import MainWeatherInfo from '@/components/weather/MainWeatherInfo';
import HourlyForecast from '@/components/weather/HourlyForecast';
import DailyForecast from '@/components/weather/DailyForecast';
import WeatherDetails from '@/components/weather/WeatherDetails';
import WeatherAlert from '@/components/weather/WeatherAlert';
import LocationSearchModal from '@/components/weather/LocationSearchModal';
import { Skeleton } from '@/components/ui/skeleton';

export default function Home() {
  const { toast } = useToast();
  const [locationModalOpen, setLocationModalOpen] = useState(false);
  const [selectedLocation, setSelectedLocation] = useState<Location | null>(null);
  
  // Get user's geolocation
  const { location: geoLocation, loading: geoLoading, error: geoError } = useGeoLocation();
  
  // Use the selected location or fall back to geolocation
  const currentLocation = selectedLocation || geoLocation;
  
  // Get weather data for the current location
  const { 
    currentWeather, 
    hourlyForecast, 
    dailyForecast, 
    alerts,
    isLoading: weatherLoading,
    refetch: refetchWeather
  } = useWeather(currentLocation);
  
  // Get saved locations and search functionality
  const {
    savedLocations,
    isLoading: locationsLoading,
    searchLocation,
    searchResults,
    isSearching,
    addLocation,
    removeLocation,
    isAdding,
    isRemoving
  } = useLocations();
  
  // Handle refresh button click
  const handleRefresh = () => {
    refetchWeather();
    toast({
      title: "Refreshing weather data",
      description: "Getting the latest weather information"
    });
  };
  
  // Handle location selection
  const handleSelectLocation = (location: Location) => {
    setSelectedLocation(location);
  };
  
  // Determine if we're loading
  const isLoading = geoLoading || weatherLoading || !currentWeather;
  
  if (geoError && !selectedLocation) {
    return (
      <div className="min-h-screen bg-clear-day flex items-center justify-center p-4">
        <div className="glass-panel rounded-xl p-6 max-w-md w-full text-white">
          <h1 className="text-xl font-bold mb-2">Location Access Required</h1>
          <p className="mb-4">
            We need access to your location to show weather information.
            Please enable location services and refresh the page.
          </p>
          <p className="text-sm opacity-70">Error: {geoError}</p>
          <button 
            className="mt-4 px-4 py-2 bg-white/20 rounded-lg hover:bg-white/30 transition-colors"
            onClick={() => window.location.reload()}
          >
            Refresh Page
          </button>
        </div>
      </div>
    );
  }
  
  // Loading skeleton
  if (isLoading) {
    return (
      <div className="min-h-screen bg-clear-day text-white">
        <header className="pt-12 pb-2 px-4 flex justify-between items-center">
          <Skeleton className="h-8 w-40 bg-white/20" />
          <Skeleton className="h-8 w-20 bg-white/20" />
        </header>
        
        <div className="pt-8 pb-12 px-4 text-center">
          <div className="flex flex-col items-center">
            <Skeleton className="h-32 w-32 rounded-full bg-white/20 mb-4" />
            <Skeleton className="h-16 w-32 bg-white/20 mb-2" />
            <Skeleton className="h-6 w-24 bg-white/20 mb-2" />
            <Skeleton className="h-4 w-32 bg-white/20" />
          </div>
        </div>
        
        <div className="glass-panel rounded-t-3xl p-4">
          <Skeleton className="h-8 w-40 bg-white/20 mb-4" />
          <div className="flex gap-4 overflow-x-auto pb-4">
            {[...Array(8)].map((_, i) => (
              <Skeleton key={i} className="h-24 w-16 flex-shrink-0 bg-white/20" />
            ))}
          </div>
        </div>
      </div>
    );
  }
  
  return (
    <>
      <WeatherBackdrop 
        weatherId={currentWeather.weather[0].id}
        sunrise={currentWeather.sunrise}
        sunset={currentWeather.sunset}
        timestamp={currentWeather.dt}
        className="text-white pb-20"
      >
        <LocationHeader 
          locationName={currentWeather.location}
          onLocationClick={() => setLocationModalOpen(true)}
          onRefresh={handleRefresh}
        />
        
        <MainWeatherInfo 
          temperature={currentWeather.temp}
          condition={currentWeather.weather[0].description}
          weatherId={currentWeather.weather[0].id}
          high={dailyForecast[0]?.temp.max || 0}
          low={dailyForecast[0]?.temp.min || 0}
          timestamp={currentWeather.dt}
          sunrise={currentWeather.sunrise}
          sunset={currentWeather.sunset}
          timezone={currentWeather.timezone_offset}
        />
        
        <HourlyForecast 
          hourlyData={hourlyForecast} 
          timezone={currentWeather.timezone_offset}
          sunrise={currentWeather.sunrise}
          sunset={currentWeather.sunset}
        />
        
        <DailyForecast 
          dailyData={dailyForecast}
          timezone={currentWeather.timezone_offset}
        />
        
        <WeatherDetails 
          weather={currentWeather}
          timezone={currentWeather.timezone_offset}
        />
        
        {alerts && alerts.map((alert, index) => (
          <WeatherAlert 
            key={`${alert.event}-${index}`} 
            alert={alert}
            timezone={currentWeather.timezone_offset}
          />
        ))}
      </WeatherBackdrop>
      
      <LocationSearchModal 
        isOpen={locationModalOpen}
        onClose={() => setLocationModalOpen(false)}
        onSelectLocation={handleSelectLocation}
        savedLocations={savedLocations}
        isLoading={locationsLoading}
        searchLocation={searchLocation}
        searchResults={searchResults}
        isSearching={isSearching}
        addLocation={addLocation}
        removeLocation={removeLocation}
        isAdding={isAdding}
        isRemoving={isRemoving}
      />
    </>
  );
}
