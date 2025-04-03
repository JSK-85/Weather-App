import { useState, useEffect, useContext } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { apiRequest } from '@/lib/queryClient';
import { UnitContext } from '@/App';
import { OneCallResponse, Location, SavedLocation } from '@/types/weather';
import { convertTemp } from '@/lib/utils';
import { useToast } from '@/hooks/use-toast';

// Get weather data for a location
export function useWeather(location: Location | null) {
  const { unit } = useContext(UnitContext);
  const { toast } = useToast();
  
  const {
    data: weather,
    isLoading,
    isError,
    error,
    refetch,
  } = useQuery({
    queryKey: [
      `/api/weather/onecall?lat=${location?.lat}&lon=${location?.lon}`,
    ],
    enabled: !!location,
    staleTime: 1000 * 60 * 10, // 10 minutes
    refetchInterval: 1000 * 60 * 10, // 10 minutes
  });

  useEffect(() => {
    if (isError && error) {
      toast({
        title: "Error loading weather data",
        description: error.message || "Please try again later",
        variant: "destructive",
      });
    }
  }, [isError, error, toast]);

  // Memoize current weather data with converted temperatures
  const currentWeather = weather ? {
    ...weather.current,
    temp: convertTemp(weather.current.temp, unit),
    feels_like: convertTemp(weather.current.feels_like, unit),
    timezone_offset: weather.timezone_offset,
    location: location?.name || "Unknown Location",
  } : null;

  // Process hourly forecast
  const hourlyForecast = weather?.hourly.slice(0, 24).map(hour => ({
    ...hour,
    temp: convertTemp(hour.temp, unit),
    feels_like: convertTemp(hour.feels_like, unit),
  })) || [];

  // Process daily forecast
  const dailyForecast = weather?.daily.map(day => ({
    ...day,
    temp: {
      ...day.temp,
      min: convertTemp(day.temp.min, unit),
      max: convertTemp(day.temp.max, unit),
      day: convertTemp(day.temp.day, unit),
      night: convertTemp(day.temp.night, unit),
      eve: convertTemp(day.temp.eve, unit),
      morn: convertTemp(day.temp.morn, unit),
    },
    feels_like: {
      ...day.feels_like,
      day: convertTemp(day.feels_like.day, unit),
      night: convertTemp(day.feels_like.night, unit),
      eve: convertTemp(day.feels_like.eve, unit),
      morn: convertTemp(day.feels_like.morn, unit),
    },
  })) || [];

  return {
    weather: weather as OneCallResponse | undefined,
    currentWeather,
    hourlyForecast,
    dailyForecast,
    alerts: weather?.alerts || [],
    isLoading,
    isError,
    error,
    refetch,
  };
}

// Manage saved locations
export function useLocations() {
  const queryClient = useQueryClient();
  const { toast } = useToast();
  
  // Fetch all saved locations
  const {
    data: savedLocations = [],
    isLoading,
    isError,
  } = useQuery({
    queryKey: ['/api/weather/locations'],
  });

  // Search for locations
  const [searchResults, setSearchResults] = useState<Location[]>([]);
  const [isSearching, setIsSearching] = useState(false);

  const searchLocation = async (query: string) => {
    if (!query || query.trim().length < 2) {
      setSearchResults([]);
      return;
    }

    setIsSearching(true);
    try {
      const response = await apiRequest(
        'GET',
        `/api/weather/geocode?q=${encodeURIComponent(query)}`
      );
      const data = await response.json();
      setSearchResults(data || []);
    } catch (error) {
      toast({
        title: "Search failed",
        description: "Could not search for locations",
        variant: "destructive",
      });
      setSearchResults([]);
    } finally {
      setIsSearching(false);
    }
  };

  // Add a new location
  const addLocationMutation = useMutation({
    mutationFn: async (location: Location) => {
      const response = await apiRequest('POST', '/api/weather/locations', location);
      return response.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/weather/locations'] });
      toast({
        title: "Location saved",
        description: "The location has been added to your saved locations",
      });
    },
    onError: (error) => {
      toast({
        title: "Error saving location",
        description: error instanceof Error ? error.message : "Please try again",
        variant: "destructive",
      });
    },
  });

  // Remove a location
  const removeLocationMutation = useMutation({
    mutationFn: async (id: string) => {
      const response = await apiRequest('DELETE', `/api/weather/locations/${id}`, {});
      return response.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/weather/locations'] });
      toast({
        title: "Location removed",
        description: "The location has been removed from your saved locations",
      });
    },
    onError: (error) => {
      toast({
        title: "Error removing location",
        description: error instanceof Error ? error.message : "Please try again",
        variant: "destructive",
      });
    },
  });

  return {
    savedLocations: savedLocations as SavedLocation[],
    isLoading,
    isError,
    searchLocation,
    searchResults,
    isSearching,
    addLocation: (location: Location) => addLocationMutation.mutate(location),
    removeLocation: (id: string) => removeLocationMutation.mutate(id),
    isAdding: addLocationMutation.isPending,
    isRemoving: removeLocationMutation.isPending,
  };
}
