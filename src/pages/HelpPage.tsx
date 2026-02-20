import { useState } from "react";
import { ChevronDown, Send, Mail } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";

const faqs = [
  { q: "How does SafeRoute calculate risk scores?", a: "SafeRoute uses ensemble ML models analyzing historical crime data, time-of-day patterns, weather, socioeconomic factors, and community reports to generate risk probabilities for each route segment." },
  { q: "How accurate is the AI prediction?", a: "Our models achieve 94-98% accuracy depending on the region, trained on millions of data points and continuously improved with user feedback." },
  { q: "Is my data private?", a: "Yes. All personal data is encrypted. You can report incidents anonymously, and location data is only shared with your explicit consent." },
  { q: "What is the Safety Score?", a: "The Safety Score is a 0-100 metric calculated daily based on your routes, nearby incident density, and time-based risk patterns." },
  { q: "How does the ML prediction model work?", a: "We use a combination of Random Forests, Gradient Boosting, and LSTM networks trained on spatio-temporal crime data. The model considers 40+ features including location, time, weather, and historical patterns." },
  { q: "Can I use SafeRoute offline?", a: "Limited offline mode is available with cached risk data for your frequent routes. Full features require an internet connection." },
];

const HelpPage = () => {
  const [expanded, setExpanded] = useState<number | null>(null);

  return (
    <div className="space-y-6 max-w-3xl pb-20 lg:pb-0">
      {/* FAQ */}
      <div>
        <h3 className="font-display font-semibold text-lg mb-4">Frequently Asked Questions</h3>
        <div className="space-y-2">
          {faqs.map((f, i) => (
            <div key={i} className="bg-card rounded-xl shadow-card overflow-hidden">
              <button onClick={() => setExpanded(expanded === i ? null : i)} className="w-full flex items-center justify-between p-4 text-left text-sm font-medium">
                {f.q}
                <ChevronDown className={`w-4 h-4 text-muted-foreground transition-transform flex-shrink-0 ${expanded === i ? "rotate-180" : ""}`} />
              </button>
              <AnimatePresence>
                {expanded === i && (
                  <motion.div initial={{ height: 0, opacity: 0 }} animate={{ height: "auto", opacity: 1 }} exit={{ height: 0, opacity: 0 }} className="overflow-hidden">
                    <p className="px-4 pb-4 text-sm text-muted-foreground">{f.a}</p>
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          ))}
        </div>
      </div>

      {/* Contact */}
      <div className="bg-card rounded-2xl shadow-card p-6 space-y-4">
        <h3 className="font-display font-semibold flex items-center gap-2"><Mail className="w-4 h-4" /> Contact Us</h3>
        <div className="space-y-3">
          <input placeholder="Your email" className="w-full px-4 py-3 rounded-xl border border-input bg-background text-sm focus:outline-none focus:ring-2 focus:ring-primary/30" />
          <input placeholder="Subject" className="w-full px-4 py-3 rounded-xl border border-input bg-background text-sm focus:outline-none focus:ring-2 focus:ring-primary/30" />
          <textarea placeholder="Your message..." rows={4} className="w-full px-4 py-3 rounded-xl border border-input bg-background text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 resize-none" />
          <button className="px-6 py-3 rounded-xl bg-gradient-primary text-primary-foreground font-semibold flex items-center gap-2 hover:opacity-90 transition-opacity text-sm">
            <Send className="w-4 h-4" /> Send Message
          </button>
        </div>
      </div>
    </div>
  );
};

export default HelpPage;
