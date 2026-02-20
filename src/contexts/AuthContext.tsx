import { createContext, useContext, useState, useEffect, ReactNode } from "react";

interface User {
  name: string;
  email: string;
  role: "User" | "Admin";
}

interface AuthState {
  isAuthenticated: boolean;
  user: User | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  signup: (name: string, email: string, password: string, role: "User" | "Admin") => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthState>({} as AuthState);

export const useAuth = () => useContext(AuthContext);

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const stored = localStorage.getItem("saferoute_user");
    if (stored) {
      try { setUser(JSON.parse(stored)); } catch { /* ignore */ }
    }
    setLoading(false);
  }, []);

  const login = async (email: string, _password: string) => {
    setLoading(true);
    await new Promise((r) => setTimeout(r, 800));
    const u: User = { name: email.split("@")[0], email, role: "User" };
    localStorage.setItem("saferoute_user", JSON.stringify(u));
    setUser(u);
    setLoading(false);
  };

  const signup = async (name: string, email: string, _password: string, role: "User" | "Admin") => {
    setLoading(true);
    await new Promise((r) => setTimeout(r, 800));
    const u: User = { name, email, role };
    localStorage.setItem("saferoute_user", JSON.stringify(u));
    setUser(u);
    setLoading(false);
  };

  const logout = () => {
    localStorage.removeItem("saferoute_user");
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ isAuthenticated: !!user, user, loading, login, signup, logout }}>
      {children}
    </AuthContext.Provider>
  );
};
