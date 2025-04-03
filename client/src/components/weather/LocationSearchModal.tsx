import React, { useState, useEffect } from 'react';
import { Location, SavedLocation } from '@/types/weather';
import WeatherIcon from './WeatherIcon';
import { Dialog, DialogContent } from '@/components/ui/dialog';
import { motion, AnimatePresence } from 'framer-motion';
import { Skeleton } from '@/components/ui/skeleton';
import { Button } from '@/components/ui/button';
import { X, Search, Plus, Trash2 } from 'lucide-react';

interface LocationSearchModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSelectLocation: (location: Location) => void;
  savedLocations: SavedLocation[];
  isLoading: boolean;
  searchLocation: (query: string) => void;
  searchResults: Location[];
  isSearching: boolean;
  addLocation: (location: Location) => void;
  removeLocation: (id: string) => void;
  isAdding: boolean;
  isRemoving: boolean;
}

export default function LocationSearchModal({
  isOpen,
  onClose,
  onSelectLocation,
  savedLocations,
  isLoading,
  searchLocation,
  searchResults,
  isSearching,
  addLocation,
  removeLocation,
  isAdding,
  isRemoving
}: LocationSearchModalProps) {
  const [searchQuery, setSearchQuery] = useState('');
  
  // Reset search query when dialog closes
  useEffect(() => {
    if (!isOpen) {
      setSearchQuery('');
    }
  }, [isOpen]);

  // Debounce search
  useEffect(() => {
    const timer = setTimeout(() => {
      if (searchQuery) {
        searchLocation(searchQuery);
      }
    }, 500);
    
    return () => clearTimeout(timer);
  }, [searchQuery, searchLocation]);

  const handleSearch = (e: React.ChangeEvent<HTMLInputElement>) => {
    setSearchQuery(e.target.value);
  };

  const handleSelectLocation = (location: Location) => {
    onSelectLocation(location);
    onClose();
  };

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="bg-clear-day border-none text-white p-0 max-w-md w-full h-[80vh] sm:h-[70vh] max-h-screen overflow-hidden flex flex-col">
        <div className="pt-6 px-4 flex justify-between items-center">
          <button 
            className="text-white focus:outline-none"
            onClick={onClose}
          >
            <X />
          </button>
          <h2 className="text-xl font-medium">Weather Locations</h2>
          <div className="w-6"></div>
        </div>
        
        <div className="px-4 pt-6">
          <div className="relative">
            <input 
              type="text" 
              placeholder="Search for a city" 
              className="w-full bg-white/20 backdrop-blur px-4 py-3 rounded-full text-white placeholder-white/70 focus:outline-none"
              value={searchQuery}
              onChange={handleSearch}
            />
            <Search className="absolute right-3 top-1/2 transform -translate-y-1/2" />
          </div>
        </div>
        
        <div className="flex-1 overflow-y-auto px-4 pt-6 pb-4">
          {searchQuery ? (
            <div className="space-y-2">
              <h3 className="text-lg mb-2">Search Results</h3>
              
              {isSearching ? (
                <div className="space-y-2">
                  <Skeleton className="h-16 w-full bg-white/10" />
                  <Skeleton className="h-16 w-full bg-white/10" />
                </div>
              ) : searchResults.length > 0 ? (
                <AnimatePresence>
                  {searchResults.map((location, index) => (
                    <motion.div
                      key={`${location.lat}-${location.lon}`}
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: -10 }}
                      transition={{ duration: 0.2, delay: index * 0.05 }}
                      className="flex items-center justify-between py-3 px-4 backdrop-blur bg-white/10 rounded-xl"
                    >
                      <div>
                        <div className="font-medium">
                          {location.name}
                          {location.state && `, ${location.state}`}
                        </div>
                        <div className="text-sm opacity-80">{location.country}</div>
                      </div>
                      <div className="flex gap-2">
                        <Button 
                          variant="ghost" 
                          size="icon"
                          onClick={() => handleSelectLocation(location)}
                          className="text-white hover:bg-white/20"
                        >
                          <Search size={16} />
                        </Button>
                        <Button 
                          variant="ghost" 
                          size="icon"
                          onClick={() => addLocation(location)}
                          disabled={isAdding}
                          className="text-white hover:bg-white/20"
                        >
                          <Plus size={16} />
                        </Button>
                      </div>
                    </motion.div>
                  ))}
                </AnimatePresence>
              ) : (
                <div className="text-center py-8 opacity-70">
                  No locations found
                </div>
              )}
            </div>
          ) : (
            <div className="space-y-2">
              <h3 className="text-lg mb-2">Saved Locations</h3>
              
              {isLoading ? (
                <div className="space-y-2">
                  <Skeleton className="h-16 w-full bg-white/10" />
                  <Skeleton className="h-16 w-full bg-white/10" />
                  <Skeleton className="h-16 w-full bg-white/10" />
                </div>
              ) : savedLocations.length > 0 ? (
                <AnimatePresence>
                  {savedLocations.map((location, index) => (
                    <motion.div
                      key={location.id}
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: -10 }}
                      transition={{ duration: 0.2, delay: index * 0.05 }}
                      className="flex items-center justify-between py-3 px-4 backdrop-blur bg-white/10 rounded-xl"
                    >
                      <div className="flex-1 cursor-pointer" onClick={() => handleSelectLocation(location)}>
                        <div className="font-medium">{location.name}</div>
                        {location.current && (
                          <div className="text-sm opacity-80">
                            {location.current.temp}° | {location.current.description}
                          </div>
                        )}
                      </div>
                      <div className="flex gap-2 items-center">
                        {location.current && (
                          <WeatherIcon weatherId={location.current.weatherId} size="sm" />
                        )}
                        <Button 
                          variant="ghost" 
                          size="icon"
                          onClick={() => removeLocation(location.id)}
                          disabled={isRemoving}
                          className="text-white hover:bg-white/20"
                        >
                          <Trash2 size={16} />
                        </Button>
                      </div>
                    </motion.div>
                  ))}
                </AnimatePresence>
              ) : (
                <div className="text-center py-8 opacity-70">
                  No saved locations yet.<br />
                  Search for a city to add it to your list.
                </div>
              )}
            </div>
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
}
