import { type Request, Response } from "express";
import { IStorage } from "./storage";
import crypto from "crypto";

// Interfaces
interface Location {
  name: string;
  lat: number;
  lon: number;
  country: string;
  state?: string;
}

interface SavedLocation extends Location {
  id: string;
  current?: {
    temp: number;
    weatherId: number;
    description: string;
  };
}

// In-memory storage for saved locations
const savedLocations: Map<string, SavedLocation> = new Map();

// OpenWeatherMap API key
const OPENWEATHER_API_KEY = process.env.OPENWEATHER_API_KEY || '';

// Constants
const BASE_URL = 'https://api.openweathermap.org/';

// Helper functions
async function fetchWithAuth(url: string) {
  const response = await fetch(url);
  
  if (!response.ok) {
    const text = await response.text();
    throw new Error(`OpenWeatherMap API error (${response.status}): ${text}`);
  }
  
  return response.json();
}

// Weather API handlers
export async function getOneCallWeather(req: Request, res: Response) {
  try {
    const { lat, lon } = req.query;
    
    if (!lat || !lon) {
      return res.status(400).json({ message: 'Latitude and longitude are required' });
    }
    
    if (!OPENWEATHER_API_KEY) {
      return res.status(500).json({ message: 'Weather API key is not configured' });
    }
    
    const url = `${BASE_URL}data/3.0/onecall?lat=${lat}&lon=${lon}&appid=${OPENWEATHER_API_KEY}&exclude=minutely`;
    const data = await fetchWithAuth(url);
    
    res.json(data);
  } catch (error) {
    console.error('Error fetching weather data:', error);
    res.status(500).json({ message: error instanceof Error ? error.message : 'Failed to fetch weather data' });
  }
}

export async function geocodeLocation(req: Request, res: Response) {
  try {
    const { q } = req.query;
    
    if (!q) {
      return res.status(400).json({ message: 'Query parameter is required' });
    }
    
    if (!OPENWEATHER_API_KEY) {
      return res.status(500).json({ message: 'Weather API key is not configured' });
    }
    
    const url = `${BASE_URL}geo/1.0/direct?q=${q}&limit=5&appid=${OPENWEATHER_API_KEY}`;
    const data = await fetchWithAuth(url);
    
    res.json(data);
  } catch (error) {
    console.error('Error geocoding location:', error);
    res.status(500).json({ message: error instanceof Error ? error.message : 'Failed to geocode location' });
  }
}

export async function reverseGeocode(req: Request, res: Response) {
  try {
    const { lat, lon } = req.query;
    
    if (!lat || !lon) {
      return res.status(400).json({ message: 'Latitude and longitude are required' });
    }
    
    if (!OPENWEATHER_API_KEY) {
      return res.status(500).json({ message: 'Weather API key is not configured' });
    }
    
    const url = `${BASE_URL}geo/1.0/reverse?lat=${lat}&lon=${lon}&limit=1&appid=${OPENWEATHER_API_KEY}`;
    const data = await fetchWithAuth(url);
    
    res.json(data);
  } catch (error) {
    console.error('Error reverse geocoding:', error);
    res.status(500).json({ message: error instanceof Error ? error.message : 'Failed to reverse geocode' });
  }
}

// Location management handlers
export async function getSavedLocations(req: Request, res: Response) {
  try {
    const locations = Array.from(savedLocations.values());
    
    // Update current weather for all locations if needed
    await Promise.all(
      locations.map(async (location) => {
        // Only update if weather data is older than 1 hour or doesn't exist
        const needsUpdate = !location.current;
        
        if (needsUpdate && OPENWEATHER_API_KEY) {
          try {
            const url = `${BASE_URL}data/2.5/weather?lat=${location.lat}&lon=${location.lon}&appid=${OPENWEATHER_API_KEY}`;
            const weatherData = await fetchWithAuth(url);
            
            location.current = {
              temp: Math.round(weatherData.main.temp - 273.15), // Convert to Celsius
              weatherId: weatherData.weather[0].id,
              description: weatherData.weather[0].main,
            };
            
            // Update in map
            savedLocations.set(location.id, location);
          } catch (error) {
            console.error(`Failed to update weather for ${location.name}:`, error);
          }
        }
      })
    );
    
    res.json(locations);
  } catch (error) {
    console.error('Error getting saved locations:', error);
    res.status(500).json({ message: error instanceof Error ? error.message : 'Failed to get saved locations' });
  }
}

export async function addSavedLocation(req: Request, res: Response) {
  try {
    const { name, lat, lon, country, state } = req.body;
    
    if (!name || lat === undefined || lon === undefined || !country) {
      return res.status(400).json({ message: 'Name, coordinates, and country are required' });
    }
    
    // Check if location already exists
    const exists = Array.from(savedLocations.values()).some(
      loc => loc.lat === lat && loc.lon === lon
    );
    
    if (exists) {
      return res.status(409).json({ message: 'Location already exists' });
    }
    
    // Generate unique ID
    const id = crypto.randomUUID();
    
    const newLocation: SavedLocation = {
      id,
      name,
      lat,
      lon,
      country,
      state,
    };
    
    // Add current weather data if API key exists
    if (OPENWEATHER_API_KEY) {
      try {
        const url = `${BASE_URL}data/2.5/weather?lat=${lat}&lon=${lon}&appid=${OPENWEATHER_API_KEY}`;
        const weatherData = await fetchWithAuth(url);
        
        newLocation.current = {
          temp: Math.round(weatherData.main.temp - 273.15), // Convert to Celsius
          weatherId: weatherData.weather[0].id,
          description: weatherData.weather[0].main,
        };
      } catch (error) {
        console.error(`Failed to get current weather for new location:`, error);
      }
    }
    
    savedLocations.set(id, newLocation);
    res.status(201).json(newLocation);
  } catch (error) {
    console.error('Error adding location:', error);
    res.status(500).json({ message: error instanceof Error ? error.message : 'Failed to add location' });
  }
}

export async function removeSavedLocation(req: Request, res: Response) {
  try {
    const { id } = req.params;
    
    if (!savedLocations.has(id)) {
      return res.status(404).json({ message: 'Location not found' });
    }
    
    savedLocations.delete(id);
    res.json({ message: 'Location removed successfully' });
  } catch (error) {
    console.error('Error removing location:', error);
    res.status(500).json({ message: error instanceof Error ? error.message : 'Failed to remove location' });
  }
}
