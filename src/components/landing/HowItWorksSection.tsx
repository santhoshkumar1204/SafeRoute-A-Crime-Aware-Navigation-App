import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { ChevronDown } from "lucide-react";
import howItWorksImg from "@/assets/how-it-works.png";

const steps = [
  { num: "01", title: "Enter Source & Destination", desc: "User inputs origin and destination for the trip." },
  { num: "02", title: "Routes Retrieved", desc: "Multiple candidate routes are fetched from Maps API." },
  { num: "03", title: "Crime Data & ML Analysis", desc: "Historical crime data is analyzed with ML models per route segment." },
  { num: "04", title: "Risk Scoring & Optimization", desc: "Dynamic graph optimization assigns risk-weighted scores." },
  { num: "05", title: "Safest Route Selected", desc: "The optimal balance of safety, distance and time is recommended." },
  { num: "06", title: "Real-Time Monitoring", desc: "Continuous GPS tracking with live risk alerts during navigation." },
  { num: "07", title: "Feedback & Learning", desc: "User feedback and trip data improve future predictions." },
];

const HowItWorksSection = () => {
  const [expanded, setExpanded] = useState<number | null>(null);

  return (
    <section id="how-it-works" className="py-20">
      <div className="container mx-auto px-4">
        <motion.div initial={{ opacity: 0, y: 20 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true }} className="text-center mb-14">
          <span className="text-sm font-semibold text-primary uppercase tracking-wider">Process</span>
          <h2 className="text-3xl md:text-4xl font-display font-bold mt-2">
            How <span className="text-gradient-primary">SafeRoute Works</span>
          </h2>
        </motion.div>

        <div className="grid lg:grid-cols-2 gap-16 items-start">
          <motion.div initial={{ opacity: 0 }} whileInView={{ opacity: 1 }} viewport={{ once: true }}>
            <img src={howItWorksImg} alt="How it works" className="w-full max-w-lg mx-auto" />
          </motion.div>

          <div className="space-y-3">
            {steps.map((s, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, x: 20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.05 }}
                className="bg-card rounded-xl shadow-card overflow-hidden"
              >
                <button
                  onClick={() => setExpanded(expanded === i ? null : i)}
                  className="w-full flex items-center gap-4 p-4 text-left"
                >
                  <span className="flex-shrink-0 w-10 h-10 rounded-lg bg-gradient-primary text-primary-foreground flex items-center justify-center font-display font-bold text-sm">
                    {s.num}
                  </span>
                  <span className="flex-1 font-semibold text-sm">{s.title}</span>
                  <ChevronDown className={`w-4 h-4 text-muted-foreground transition-transform ${expanded === i ? "rotate-180" : ""}`} />
                </button>
                <AnimatePresence>
                  {expanded === i && (
                    <motion.div
                      initial={{ height: 0, opacity: 0 }}
                      animate={{ height: "auto", opacity: 1 }}
                      exit={{ height: 0, opacity: 0 }}
                      className="overflow-hidden"
                    >
                      <p className="px-4 pb-4 pl-[4.5rem] text-sm text-muted-foreground">{s.desc}</p>
                    </motion.div>
                  )}
                </AnimatePresence>
              </motion.div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
};

export default HowItWorksSection;
