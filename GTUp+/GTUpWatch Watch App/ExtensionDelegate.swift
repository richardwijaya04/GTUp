import WatchKit
import WidgetKit
import UserNotifications

class ExtensionDelegate: NSObject, WKExtensionDelegate, UNUserNotificationCenterDelegate {
    private let userDefaults = UserDefaults(suiteName: "group.com.richardwijaya.CoreChal1") ?? .standard
    
    override init() {
        super.init()
        // Set delegate untuk notifikasi
        UNUserNotificationCenter.current().delegate = self
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            if let refreshTask = task as? WKApplicationRefreshBackgroundTask {
                if userDefaults.bool(forKey: "isTimerRunning"),
                   let startDate = userDefaults.object(forKey: "timerStartDate") as? Date,
                   let endDate = userDefaults.object(forKey: "scheduledEndDate") as? Date {
                    let now = Date()
                    
                    if now >= endDate {
                        // Timer selesai
                        userDefaults.set(0, forKey: "currentTimeRemaining")
                        userDefaults.set(true, forKey: "isTimerDone")
                        userDefaults.set(false, forKey: "isTimerRunning")
                        userDefaults.removeObject(forKey: "timerStartDate")
                        userDefaults.removeObject(forKey: "scheduledEndDate")
                        
                        // Trigger haptic dan notifikasi
                        WKInterfaceDevice.current().play(.notification)
                        NotificationCenter.default.post(name: NSNotification.Name("TimerDone"), object: nil)
                    } else {
                        // Timer masih jalan
                        let elapsed = now.timeIntervalSince(startDate)
                        let initialTime = userDefaults.string(forKey: "selectedLabel") == "Work" ? 1500 : 300
                        let newRemaining = max(0, Int(Double(initialTime) - elapsed))
                        userDefaults.set(newRemaining, forKey: "currentTimeRemaining")
                        
                        // Schedule refresh berikutnya (~30 detik)
                        WKExtension.shared().scheduleBackgroundRefresh(
                            withPreferredDate: Date().addingTimeInterval(30),
                            userInfo: nil
                        ) { error in
                            if let error = error {
                                print("Failed to schedule background refresh: \(error)")
                            }
                        }
                    }
                    
                    // Update widget
                    WidgetCenter.shared.reloadAllTimelines()
                }
                
                refreshTask.setTaskCompletedWithSnapshot(false)
            } else {
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    func applicationDidFinishLaunching() {
        if userDefaults.bool(forKey: "isTimerRunning") {
            WKExtension.shared().scheduleBackgroundRefresh(
                withPreferredDate: Date().addingTimeInterval(30),
                userInfo: nil
            ) { error in
                if let error = error {
                    print("Failed to schedule background refresh: \(error)")
                }
            }
        }
    }
    
    func applicationDidBecomeActive() {
        NotificationCenter.default.post(name: NSNotification.Name("AppBecameActive"), object: nil)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // UNUserNotificationCenterDelegate: Tangani notifikasi foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if notification.request.identifier == "timerEnd",
           let navigateToDone = notification.request.content.userInfo["navigateToDone"] as? Bool,
           navigateToDone {
            // Trigger navigasi ke DoneTimerView
            NotificationCenter.default.post(name: NSNotification.Name("TimerDone"), object: nil)
            // Tampilkan notifikasi dengan suara
            completionHandler([.banner, .sound])
        } else {
            completionHandler([])
        }
    }
}
