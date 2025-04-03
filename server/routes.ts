import type { Express } from "express";
import { createServer, type Server } from "http";
import { storage } from "./storage";
import { 
  getOneCallWeather,
  geocodeLocation,
  reverseGeocode,
  getSavedLocations,
  addSavedLocation,
  removeSavedLocation
} from "./weather";

export async function registerRoutes(app: Express): Promise<Server> {
  // Weather API routes
  app.get("/api/weather/onecall", getOneCallWeather);
  app.get("/api/weather/geocode", geocodeLocation);
  app.get("/api/weather/reverse-geocode", reverseGeocode);
  
  // Location management routes
  app.get("/api/weather/locations", getSavedLocations);
  app.post("/api/weather/locations", addSavedLocation);
  app.delete("/api/weather/locations/:id", removeSavedLocation);

  const httpServer = createServer(app);

  return httpServer;
}
