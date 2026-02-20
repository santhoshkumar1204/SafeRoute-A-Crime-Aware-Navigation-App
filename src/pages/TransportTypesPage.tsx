import { useState } from "react";
import { Bus, ChevronDown } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";
import { mockBusData } from "@/data/mockData";
import typesOfBusImg from "@/assets/typesofbus.jpeg";

const TransportTypesPage = () => {
  const [expanded, setExpanded] = useState<number | null>(null);

  return (
    <div className="space-y-6 pb-20 lg:pb-0">
      <div className="bg-card rounded-2xl shadow-card p-6">
        <h3 className="font-display font-semibold text-lg mb-4 flex items-center gap-2">
          <Bus className="w-5 h-5 text-primary" /> MTC Bus Types & Services
        </h3>
        <img src={typesOfBusImg} alt="MTC Bus Types" className="w-full rounded-xl mb-6 object-contain max-h-64" />
      </div>

      <div className="space-y-3">
        {mockBusData.busTypes.map((bus, i) => (
          <div key={i} className="bg-card rounded-2xl shadow-card overflow-hidden">
            <button
              onClick={() => setExpanded(expanded === i ? null : i)}
              className="w-full flex items-center justify-between p-5 text-left"
            >
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-primary/10 text-primary flex items-center justify-center">
                  <Bus className="w-5 h-5" />
                </div>
                <div>
                  <p className="font-semibold text-sm">{bus.type}</p>
                  <p className="text-xs text-muted-foreground">{bus.fare}</p>
                </div>
              </div>
              <ChevronDown className={`w-4 h-4 text-muted-foreground transition-transform ${expanded === i ? "rotate-180" : ""}`} />
            </button>
            <AnimatePresence>
              {expanded === i && (
                <motion.div initial={{ height: 0 }} animate={{ height: "auto" }} exit={{ height: 0 }} className="overflow-hidden">
                  <div className="px-5 pb-5 space-y-2 border-t border-border pt-3">
                    <p className="text-sm text-muted-foreground">{bus.desc}</p>
                    <div className="bg-muted/50 rounded-xl p-3">
                      <p className="text-xs font-medium mb-1">Popular Routes</p>
                      <p className="text-xs text-muted-foreground">{bus.routes}</p>
                    </div>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>
        ))}
      </div>
    </div>
  );
};

export default TransportTypesPage;
