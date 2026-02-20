import { createContext, useContext, useState, ReactNode } from "react";

interface MapState {
  showHeatmap: boolean;
  showRoute: boolean;
  showPoliceStations: boolean;
  riskZones: { lat: number; lng: number; level: "safe" | "moderate" | "danger" }[];
}

interface RouteState {
  source: string;
  destination: string;
  mode: "safest" | "balanced" | "fastest";
  riskProbability: number;
  riskLevel: "low" | "moderate" | "high";
  routeWeight: number;
}

interface RiskState {
  alertTrigger: boolean;
  todaySafetyScore: number;
  nearbyHighRiskAreas: number;
  recentAlerts: number;
  tripsThisWeek: number;
}

interface NotificationState {
  unreadCount: number;
  notifications: { id: string; message: string; time: string; read: boolean }[];
}

interface AppState {
  mapState: MapState;
  setMapState: React.Dispatch<React.SetStateAction<MapState>>;
  routeState: RouteState;
  setRouteState: React.Dispatch<React.SetStateAction<RouteState>>;
  riskState: RiskState;
  notificationState: NotificationState;
}

const AppStateContext = createContext<AppState>({} as AppState);
export const useAppState = () => useContext(AppStateContext);

export const AppStateProvider = ({ children }: { children: ReactNode }) => {
  const [mapState, setMapState] = useState<MapState>({
    showHeatmap: true,
    showRoute: true,
    showPoliceStations: false,
    riskZones: [],
  });

  const [routeState, setRouteState] = useState<RouteState>({
    source: "",
    destination: "",
    mode: "safest",
    riskProbability: 0.32,
    riskLevel: "low",
    routeWeight: 0.78,
  });

  const riskState: RiskState = {
    alertTrigger: false,
    todaySafetyScore: 87,
    nearbyHighRiskAreas: 3,
    recentAlerts: 5,
    tripsThisWeek: 12,
  };

  const notificationState: NotificationState = {
    unreadCount: 3,
    notifications: [
      { id: "1", message: "High risk alert near Central Park", time: "2m ago", read: false },
      { id: "2", message: "New safe zone confirmed downtown", time: "15m ago", read: false },
      { id: "3", message: "Weekly safety report ready", time: "1h ago", read: true },
    ],
  };

  return (
    <AppStateContext.Provider value={{ mapState, setMapState, routeState, setRouteState, riskState, notificationState }}>
      {children}
    </AppStateContext.Provider>
  );
};
