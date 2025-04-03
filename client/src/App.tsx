import { Switch, Route } from "wouter";
import { queryClient } from "./lib/queryClient";
import { QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/toaster";
import Home from "@/pages/Home";
import NotFound from "@/pages/not-found";
import { useState } from "react";

// Create a context for temperature unit
import { createContext } from "react";

export type TemperatureUnit = "celsius" | "fahrenheit";
export const UnitContext = createContext<{
  unit: TemperatureUnit;
  toggleUnit: () => void;
}>({
  unit: "celsius",
  toggleUnit: () => {},
});

function Router() {
  return (
    <Switch>
      <Route path="/" component={Home} />
      <Route component={NotFound} />
    </Switch>
  );
}

function App() {
  const [unit, setUnit] = useState<TemperatureUnit>("celsius");

  const toggleUnit = () => {
    setUnit((prev) => (prev === "celsius" ? "fahrenheit" : "celsius"));
  };

  return (
    <QueryClientProvider client={queryClient}>
      <UnitContext.Provider value={{ unit, toggleUnit }}>
        <Router />
        <Toaster />
      </UnitContext.Provider>
    </QueryClientProvider>
  );
}

export default App;
