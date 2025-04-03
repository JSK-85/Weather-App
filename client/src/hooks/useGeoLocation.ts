import { useState, useEffect } from 'react';
import { apiRequest } from '@/lib/queryClient';
import { Location } from '@/types/weather';

interface GeoLocationState {
  loading: boolean;
  error: string | null;
  location: Location | null;
}

export function useGeoLocation() {
  const [state, setState] = useState<GeoLocationState>({
    loading: true,
    error: null,
    location: null,
  });

  useEffect(() => {
    if (!navigator.geolocation) {
      setState({
        loading: false,
        error: "Geolocation is not supported by your browser",
        location: null,
      });
      return;
    }

    navigator.geolocation.getCurrentPosition(
      async (position) => {
        try {
          const { latitude, longitude } = position.coords;
          
          // Reverse geocode to get location name
          const response = await apiRequest(
            'GET',
            `/api/weather/reverse-geocode?lat=${latitude}&lon=${longitude}`,
          );
          
          const locationData = await response.json();
          
          if (locationData && locationData.length > 0) {
            setState({
              loading: false,
              error: null,
              location: locationData[0],
            });
          } else {
            setState({
              loading: false,
              error: "Could not determine your location name",
              location: {
                name: "Current Location",
                lat: latitude,
                lon: longitude,
                country: "",
              },
            });
          }
        } catch (error) {
          setState({
            loading: false,
            error: "Failed to fetch location details",
            location: null,
          });
        }
      },
      (error) => {
        setState({
          loading: false,
          error: `Error getting location: ${error.message}`,
          location: null,
        });
      },
      { enableHighAccuracy: true, timeout: 10000, maximumAge: 60000 }
    );
  }, []);

  return state;
}
