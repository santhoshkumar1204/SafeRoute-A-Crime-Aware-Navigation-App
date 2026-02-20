import { useState } from "react";
import { Bell, X, Check, Trash2 } from "lucide-react";
import { mockAlerts } from "@/data/mockData";

const NotificationPanel = () => {
  const [open, setOpen] = useState(false);
  const [alerts, setAlerts] = useState(mockAlerts);

  const unreadCount = alerts.filter((a) => !a.read).length;

  const markRead = (id: string) => setAlerts((a) => a.map((n) => (n.id === id ? { ...n, read: true } : n)));
  const markAllRead = () => setAlerts((a) => a.map((n) => ({ ...n, read: true })));
  const clearAll = () => setAlerts([]);

  return (
    <div className="relative">
      <button onClick={() => setOpen(!open)} className="relative p-2 rounded-lg hover:bg-muted transition-colors">
        <Bell className="w-5 h-5" />
        {unreadCount > 0 && (
          <span className="absolute top-0.5 right-0.5 w-4 h-4 rounded-full bg-danger text-danger-foreground text-[10px] font-bold flex items-center justify-center">
            {unreadCount}
          </span>
        )}
      </button>

      {open && (
        <>
          <div className="fixed inset-0 z-40" onClick={() => setOpen(false)} />
          <div className="absolute right-0 top-full mt-2 w-80 sm:w-96 bg-card rounded-2xl shadow-card-hover border border-border z-50 overflow-hidden">
            <div className="flex items-center justify-between p-4 border-b border-border">
              <h3 className="font-display font-semibold text-sm">Notifications</h3>
              <div className="flex items-center gap-2">
                <button onClick={markAllRead} className="text-xs text-primary hover:underline flex items-center gap-1">
                  <Check className="w-3 h-3" /> Mark all read
                </button>
                <button onClick={clearAll} className="text-xs text-muted-foreground hover:text-danger flex items-center gap-1">
                  <Trash2 className="w-3 h-3" /> Clear
                </button>
              </div>
            </div>

            <div className="max-h-80 overflow-y-auto">
              {alerts.length === 0 ? (
                <p className="p-6 text-center text-sm text-muted-foreground">No notifications</p>
              ) : (
                alerts.map((alert) => (
                  <button
                    key={alert.id}
                    onClick={() => markRead(alert.id)}
                    className={`w-full text-left p-3 border-b border-border/50 hover:bg-muted/50 transition-colors ${!alert.read ? "bg-primary/5" : ""}`}
                  >
                    <div className="flex items-start gap-3">
                      <div className={`w-2 h-2 rounded-full mt-1.5 flex-shrink-0 ${
                        alert.type === "danger" ? "bg-danger" : alert.type === "warning" ? "bg-warning" : "bg-primary"
                      }`} />
                      <div className="flex-1 min-w-0">
                        <p className={`text-sm ${!alert.read ? "font-medium" : "text-muted-foreground"}`}>{alert.message}</p>
                        <p className="text-[10px] text-muted-foreground mt-0.5">{alert.time}</p>
                      </div>
                    </div>
                  </button>
                ))
              )}
            </div>
          </div>
        </>
      )}
    </div>
  );
};

export default NotificationPanel;
