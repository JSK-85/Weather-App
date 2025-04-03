import React, { useContext } from 'react';
import { UnitContext } from '@/App';

interface LocationHeaderProps {
  locationName: string;
  onLocationClick: () => void;
  onRefresh: () => void;
}

export default function LocationHeader({ 
  locationName,
  onLocationClick,
  onRefresh 
}: LocationHeaderProps) {
  const { unit, toggleUnit } = useContext(UnitContext);

  return (
    <header className="pt-12 pb-2 px-4 flex justify-between items-center">
      <button 
        className="flex items-center gap-1 focus:outline-none"
        onClick={onLocationClick}
      >
        <span className="material-icons text-2xl">location_on</span>
        <span className="text-lg font-medium">{locationName}</span>
        <span className="material-icons">keyboard_arrow_down</span>
      </button>
      <div className="flex gap-2">
        <button 
          className="focus:outline-none"
          onClick={toggleUnit}
        >
          <span className="text-lg font-medium">°{unit === 'celsius' ? 'C' : 'F'}</span>
        </button>
        <button 
          className="focus:outline-none"
          onClick={onRefresh}
        >
          <span className="material-icons text-2xl">refresh</span>
        </button>
      </div>
    </header>
  );
}
