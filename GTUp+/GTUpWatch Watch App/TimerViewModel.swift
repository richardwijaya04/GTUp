import Foundation
import SwiftUI
import WatchKit
import WidgetKit
import UserNotifications

class TimerViewModel: ObservableObject {
    @Published var selectedLabel: String? = "Work"
    @Published var currentTimeRemaining: Int = 0
    @Published var isTimerRunning: Bool = false
    @Published var isTimerDone: Bool = false
    @Published var labels: [String] = []
    
    private var model: TimerModel
    private let userDefaults: UserDefaults
    private var timerStartDate: Date?
    private var scheduledEndDate: Date?
    
    init(model: TimerModel = TimerModel()) {
        self.model = model
        self.userDefaults = UserDefaults(suiteName: "group.com.richardwijaya.CoreChal1") ?? .standard
        loadData()
        requestNotificationPermission()
        startTimerUpdateLoop()
    }
    
    var workTime: Int { model.workTime }
    var breakTime: Int { model.breakTime }
    
    func startTimer() {
        stopTimer()
        
        // Set start dan end time
        timerStartDate = Date()
        currentTimeRemaining = selectedLabel == "Work" ? workTime : breakTime
        scheduledEndDate = timerStartDate?.addingTimeInterval(Double(currentTimeRemaining))
        
        // Simpan ke UserDefaults
        userDefaults.set(timerStartDate, forKey: "timerStartDate")
        userDefaults.set(scheduledEndDate, forKey: "scheduledEndDate")
        
        // Schedule notifikasi
        scheduleTimerEndNotification()
        
        isTimerRunning = true
        updateWidgetData()
        checkTimerState()
    }
    
    func stopTimer() {
        isTimerRunning = false
        isTimerDone = false
        timerStartDate = nil
        scheduledEndDate = nil
        currentTimeRemaining = selectedLabel == "Work" ? workTime : breakTime
        
        // Clear UserDefaults
        userDefaults.removeObject(forKey: "timerStartDate")
        userDefaults.removeObject(forKey: "scheduledEndDate")
        
        // Cancel notifikasi
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        updateWidgetData()
    }
    
    func resetTimerToInitial() {
        stopTimer()
        currentTimeRemaining = selectedLabel == "Work" ? workTime : breakTime
        isTimerRunning = true
        updateWidgetData()
        startTimer()
    }
    
    func progress() -> CGFloat {
        let initialTime = selectedLabel == "Work" ? workTime : breakTime
        if initialTime == 0 { return 0 }
        return 1.0 - CGFloat(currentTimeRemaining) / CGFloat(initialTime)
    }
    
    func formatTime(_ totalSeconds: Int) -> String {
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func loadData() {
        if let savedLabels = userDefaults.array(forKey: "labels") as? [String], !savedLabels.isEmpty {
            labels = savedLabels
        } else {
            labels = ["Work", "Break"]
            userDefaults.set(labels, forKey: "labels")
        }
        
        let hours = userDefaults.integer(forKey: "timerHours")
        let minutes = userDefaults.integer(forKey: "timerMinutes")
        let seconds = userDefaults.integer(forKey: "timerSeconds")
        let breakMinutes = userDefaults.integer(forKey: "breakMinutes")
        
        model.workTime = (hours * 3600) + (minutes * 60) + seconds
        model.breakTime = breakMinutes * 60
        
        if model.workTime == 0 {
            model.workTime = 1500
            userDefaults.set(0, forKey: "timerHours")
            userDefaults.set(0, forKey: "timerMinutes")
            userDefaults.set(0, forKey: "timerSeconds")
        }
        
        if model.breakTime == 0 {
            model.breakTime = 300
            userDefaults.set(5, forKey: "breakMinutes")
        }
        
        userDefaults.set(model.workTime, forKey: "workTime")
        userDefaults.set(model.breakTime, forKey: "breakTime")
        
        currentTimeRemaining = selectedLabel == "Work" ? model.workTime : model.breakTime
        
        // Load state timer
        if userDefaults.bool(forKey: "isTimerRunning") {
            isTimerRunning = true
            selectedLabel = userDefaults.string(forKey: "selectedLabel") ?? "Work"
            isTimerDone = userDefaults.bool(forKey: "isTimerDone")
            checkTimerState()
        }
    }
    
    private func updateWidgetData() {
        userDefaults.set(isTimerRunning, forKey: "isTimerRunning")
        userDefaults.set(isTimerDone, forKey: "isTimerDone")
        userDefaults.set(currentTimeRemaining, forKey: "currentTimeRemaining")
        userDefaults.set(selectedLabel, forKey: "selectedLabel")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func startHapticFeedback() {
        WKInterfaceDevice.current().play(.notification) // Mirip Apple Timer
    }
    
    func checkTimerState() {
        guard isTimerRunning, let startDate = timerStartDate, let endDate = scheduledEndDate else {
            return
        }
        
        let now = Date()
        if now >= endDate {
            // Timer selesai
            currentTimeRemaining = 0
            isTimerRunning = false
            isTimerDone = true
            timerStartDate = nil
            scheduledEndDate = nil
            userDefaults.removeObject(forKey: "timerStartDate")
            userDefaults.removeObject(forKey: "scheduledEndDate")
            updateWidgetData()
            startHapticFeedback()
            // Kirim notifikasi kuat buat pindah ke DoneTimerView
            NotificationCenter.default.post(name: NSNotification.Name("TimerDone"), object: nil)
        } else {
            // Timer masih jalan
            let elapsed = now.timeIntervalSince(startDate)
            currentTimeRemaining = max(0, Int(Double(selectedLabel == "Work" ? workTime : breakTime) - elapsed))
            updateWidgetData()
        }
    }
    
    private func startTimerUpdateLoop() {
        // Update timer tiap detik saat app aktif
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.isTimerRunning {
                self.checkTimerState()
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
    
    private func scheduleTimerEndNotification() {
        guard let endDate = scheduledEndDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Timer Finished"
        content.body = "\(selectedLabel ?? "Timer") session completed!"
        content.sound = .default
        content.userInfo = ["navigateToDone": true] // Buat trigger navigasi
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: endDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: "timerEnd", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}
