import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { motion, AnimatePresence } from "framer-motion";
import { X, Brain, Route, Bell, Navigation, Map, Users, BarChart3, RefreshCw, ShieldCheck, Moon, Phone, History } from "lucide-react";
import { useAuth } from "@/contexts/AuthContext";

const features = [
  { icon: <Brain />, title: "AI Risk Prediction Engine", short: "ML models predict crime probability for any area", detail: "Leverages historical crime data, weather, time-of-day, and socioeconomic factors through ensemble ML models to generate granular risk predictions.", route: "/analytics" },
  { icon: <Route />, title: "Dynamic Route Scoring", short: "Real-time risk-weighted pathfinding", detail: "Dijkstra-based graph optimization where edge weights dynamically update based on predicted crime risk, time, and user preferences.", route: "/navigation" },
  { icon: <Bell />, title: "Real-Time Crime Alerts", short: "Instant notifications for nearby incidents", detail: "Push notifications triggered by live crime feeds and community reports within configurable proximity radius.", route: "/dashboard" },
  { icon: <Navigation />, title: "Live GPS Monitoring", short: "Continuous safety tracking during navigation", detail: "Background GPS tracking with automatic rerouting if the user deviates or new risks are detected along the current path.", route: "/navigation" },
  { icon: <Map />, title: "Crime Heatmap Visualization", short: "Visual crime density overlays", detail: "Multi-layer heatmaps showing historical crime density, predicted risk zones, and temporal patterns with filtering controls.", route: "/heatmap" },
  { icon: <Users />, title: "Community Crime Reporting", short: "Crowd-sourced safety intelligence", detail: "Users can report incidents, suspicious activity, and safety concerns that feed into the AI model for improved predictions.", route: "/report" },
  { icon: <BarChart3 />, title: "Route Risk Dashboard", short: "Detailed analytics for every route", detail: "Comprehensive breakdown showing risk scores per segment, alternative comparisons, and historical safety trends.", route: "/analytics" },
  { icon: <RefreshCw />, title: "Smart Rerouting", short: "Automatic safer path suggestions", detail: "When new threats emerge mid-journey, the system instantly calculates and suggests safer alternative routes.", route: "/navigation" },
  { icon: <ShieldCheck />, title: "Women Safety Mode", short: "Enhanced safety features for women", detail: "Prioritizes well-lit paths, populated areas, and CCTV-covered routes. Includes quick-share location and emergency contacts.", route: "/settings" },
  { icon: <Moon />, title: "Night Travel Mode", short: "Optimized for after-dark navigation", detail: "Adjusts risk models for nighttime crime patterns, prioritizes well-lit and patrolled routes.", route: "/navigation" },
  { icon: <Phone />, title: "Emergency SOS Integration", short: "One-tap emergency assistance", detail: "Instantly alerts emergency contacts, shares live location, and connects to nearest emergency services.", route: "/emergency" },
  { icon: <History />, title: "Safety Score History", short: "Track your safety over time", detail: "Personal analytics dashboard showing trip history, cumulative risk exposure, and safety improvement trends.", route: "/analytics" },
];

const FeaturesSection = () => {
  const [selected, setSelected] = useState<number | null>(null);
  const { isAuthenticated } = useAuth();
  const navigate = useNavigate();

  const handleFeatureClick = (index: number) => {
    setSelected(index);
  };

  const handleGoToFeature = (route: string) => {
    setSelected(null);
    if (isAuthenticated) {
      navigate(route);
    } else {
      navigate("/login");
    }
  };

  return (
    <section id="features" className="py-20 bg-secondary/30">
      <div className="container mx-auto px-4">
        <motion.div initial={{ opacity: 0, y: 20 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true }} className="text-center mb-14">
          <span className="text-sm font-semibold text-primary uppercase tracking-wider">Features</span>
          <h2 className="text-3xl md:text-4xl font-display font-bold mt-2">
            Comprehensive <span className="text-gradient-primary">Safety Platform</span>
          </h2>
        </motion.div>

        <div className="grid sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
          {features.map((f, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.05 }}
              onClick={() => handleFeatureClick(i)}
              className="bg-card rounded-2xl p-6 shadow-card hover:shadow-card-hover cursor-pointer transition-all hover:-translate-y-1 group"
            >
              <div className="w-12 h-12 rounded-xl bg-primary/10 text-primary flex items-center justify-center mb-4 group-hover:bg-gradient-primary group-hover:text-primary-foreground transition-colors [&>svg]:w-5 [&>svg]:h-5">
                {f.icon}
              </div>
              <h3 className="font-display font-semibold text-sm mb-1">{f.title}</h3>
              <p className="text-xs text-muted-foreground">{f.short}</p>
            </motion.div>
          ))}
        </div>

        {/* Modal */}
        <AnimatePresence>
          {selected !== null && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 z-50 flex items-center justify-center bg-foreground/40 backdrop-blur-sm p-4"
              onClick={() => setSelected(null)}
            >
              <motion.div
                initial={{ scale: 0.9, opacity: 0 }}
                animate={{ scale: 1, opacity: 1 }}
                exit={{ scale: 0.9, opacity: 0 }}
                onClick={(e) => e.stopPropagation()}
                className="bg-card rounded-2xl shadow-card-hover p-8 max-w-md w-full relative"
              >
                <button onClick={() => setSelected(null)} className="absolute top-4 right-4 text-muted-foreground hover:text-foreground">
                  <X className="w-5 h-5" />
                </button>
                <div className="w-14 h-14 rounded-xl bg-gradient-primary text-primary-foreground flex items-center justify-center mb-5 [&>svg]:w-6 [&>svg]:h-6">
                  {features[selected].icon}
                </div>
                <h3 className="font-display font-bold text-xl mb-2">{features[selected].title}</h3>
                <p className="text-muted-foreground text-sm mb-5">{features[selected].detail}</p>
                <button
                  onClick={() => handleGoToFeature(features[selected].route)}
                  className="px-6 py-2.5 rounded-xl bg-gradient-primary text-primary-foreground text-sm font-semibold hover:opacity-90 transition-opacity"
                >
                  {isAuthenticated ? "Open Feature →" : "Login to Access →"}
                </button>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </section>
  );
};

export default FeaturesSection;
