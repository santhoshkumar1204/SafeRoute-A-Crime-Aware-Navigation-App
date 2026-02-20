import { Link } from "react-router-dom";
import { Shield, HelpCircle, Mail, FileText } from "lucide-react";
import logo from "@/assets/saferoute-logo.png";

const Footer = () => (
  <footer id="about" className="bg-foreground text-background py-16">
    <div className="container mx-auto px-4">
      <div className="grid md:grid-cols-4 gap-10 mb-12">
        <div className="space-y-4">
          <div className="flex items-center gap-2">
            <div className="w-10 h-10 rounded-full bg-gradient-primary p-0.5">
              <img src={logo} alt="SafeRoute" className="w-full h-full rounded-full object-cover" />
            </div>
            <span className="font-display font-bold text-lg">SafeRoute</span>
          </div>
          <p className="text-sm opacity-70">
            AI-powered crime-aware navigation for safer urban mobility. Aligned with UN SDG 11 & SDG 16.
          </p>
        </div>

        <div>
          <h4 className="font-display font-semibold mb-4">Product</h4>
          <ul className="space-y-2 text-sm opacity-70">
            <li><a href="#features">Features</a></li>
            <li><a href="#live-map">Live Map</a></li>
            <li><a href="#how-it-works">How It Works</a></li>
            <li><Link to="/dashboard">Dashboard</Link></li>
          </ul>
        </div>

        <div>
          <h4 className="font-display font-semibold mb-4">Company</h4>
          <ul className="space-y-2 text-sm opacity-70">
            <li><a href="#about">About</a></li>
            <li><Link to="/help">Contact</Link></li>
            <li><Link to="/help">Help</Link></li>
          </ul>
        </div>

        <div>
          <h4 className="font-display font-semibold mb-4">Legal</h4>
          <ul className="space-y-2 text-sm opacity-70">
            <li><a href="#" className="flex items-center gap-1.5"><FileText className="w-3 h-3" /> Privacy Policy</a></li>
            <li><a href="#" className="flex items-center gap-1.5"><Shield className="w-3 h-3" /> Terms of Service</a></li>
            <li><a href="#" className="flex items-center gap-1.5"><HelpCircle className="w-3 h-3" /> FAQ</a></li>
            <li><a href="#" className="flex items-center gap-1.5"><Mail className="w-3 h-3" /> support@saferoute.ai</a></li>
          </ul>
        </div>
      </div>

      <div className="border-t border-background/10 pt-6 text-center text-sm opacity-50">
        © 2026 SafeRoute. All rights reserved.
      </div>
    </div>
  </footer>
);

export default Footer;
