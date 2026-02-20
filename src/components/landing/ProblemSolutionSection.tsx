import { motion } from "framer-motion";
import { AlertTriangle, Brain, Route, Shield } from "lucide-react";
import problemImg from "@/assets/problem-solution.png";

const points = [
  { icon: <Brain className="w-5 h-5" />, title: "Spatio-Temporal Crime Analysis", desc: "Analyze crime patterns across space and time" },
  { icon: <Shield className="w-5 h-5" />, title: "ML-Based Risk Prediction", desc: "Machine learning models predict area risk levels" },
  { icon: <Route className="w-5 h-5" />, title: "Dynamic Route Weighting", desc: "Graph algorithms find optimally safe routes" },
  { icon: <AlertTriangle className="w-5 h-5" />, title: "Real-Time Alerts", desc: "Live monitoring with instant notifications" },
];

const ProblemSolutionSection = () => (
  <section className="py-20">
    <div className="container mx-auto px-4">
      <div className="grid lg:grid-cols-2 gap-16 items-center">
        <motion.div
          initial={{ opacity: 0, x: -30 }}
          whileInView={{ opacity: 1, x: 0 }}
          viewport={{ once: true }}
        >
          <img src={problemImg} alt="Problem and Solution" className="w-full max-w-lg mx-auto" />
        </motion.div>

        <motion.div
          initial={{ opacity: 0, x: 30 }}
          whileInView={{ opacity: 1, x: 0 }}
          viewport={{ once: true }}
          className="space-y-8"
        >
          <div>
            <span className="text-sm font-semibold text-primary uppercase tracking-wider">Why SafeRoute?</span>
            <h2 className="text-3xl md:text-4xl font-display font-bold mt-2 mb-4">
              Shortest Route ≠ <span className="text-gradient-primary">Safest Route</span>
            </h2>
            <p className="text-muted-foreground">
              Traditional navigation ignores crime data entirely. SafeRoute integrates AI-driven crime intelligence to protect every journey.
            </p>
          </div>

          <div className="grid gap-4">
            {points.map((p, i) => (
              <div key={i} className="flex gap-4 p-4 rounded-xl bg-card shadow-card hover:shadow-card-hover transition-shadow">
                <div className="flex-shrink-0 w-10 h-10 rounded-lg bg-primary/10 text-primary flex items-center justify-center">
                  {p.icon}
                </div>
                <div>
                  <h4 className="font-semibold text-sm">{p.title}</h4>
                  <p className="text-xs text-muted-foreground mt-0.5">{p.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </motion.div>
      </div>
    </div>
  </section>
);

export default ProblemSolutionSection;
