//
//  WidgetViewModel.swift
//  CoreChal1
//
//  Created by Richard WIjaya Harianto on 15/05/25.
//

import Foundation
import WidgetKit

// Chef: Ngolah data dari UserDefaults, bikin timeline
struct WidgetViewModel {
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults(suiteName: "group.com.richardwijaya.CoreChal1") ?? .standard) {
        self.userDefaults = userDefaults
    }
    
    func getSnapshotEntry() -> TimerEntry {
        TimerEntry(
            date: Date(),
            timerRunning: userDefaults.bool(forKey: "isTimerRunning"),
            timeRemaining: max(0, userDefaults.integer(forKey: "currentTimeRemaining")),
            timerLabel: userDefaults.string(forKey: "selectedLabel") ?? "Work",
            isDone: userDefaults.bool(forKey: "isTimerDone")
        )
    }
    
    func getTimelineEntries() -> (entries: [TimerEntry], refreshDate: Date) {
        let currentDate = Date()
        let isTimerRunning = userDefaults.bool(forKey: "isTimerRunning")
        let isDone = userDefaults.bool(forKey: "isTimerDone")
        let timeRemaining = max(0, userDefaults.integer(forKey: "currentTimeRemaining"))
        let timerLabel = userDefaults.string(forKey: "selectedLabel") ?? "Work"
        
        var entries: [TimerEntry] = []
        
        if isTimerRunning && !isDone && timeRemaining > 0 {
            // Buat entri tiap detik (batasi 60 detik buat efisiensi)
            for secondOffset in 0...min(timeRemaining, 60) {
                let entryDate = Calendar.current.date(byAdding: .second, value: secondOffset, to: currentDate)!
                let remainingTime = max(0, timeRemaining - secondOffset)
                let entry = TimerEntry(
                    date: entryDate,
                    timerRunning: true,
                    timeRemaining: remainingTime,
                    timerLabel: timerLabel,
                    isDone: remainingTime == 0
                )
                entries.append(entry)
            }
        } else {
            let entry = TimerEntry(
                date: currentDate,
                timerRunning: isTimerRunning,
                timeRemaining: timeRemaining,
                timerLabel: timerLabel,
                isDone: isDone
            )
            entries.append(entry)
        }
        
        // Refresh tiap detik kalau running, 15 menit kalau idle/done
        let refreshDate = isTimerRunning ?
            Calendar.current.date(byAdding: .second, value: 1, to: currentDate)! :
            Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        
        return (entries, refreshDate)
    }
    
    func getProgress(timeRemaining: Int, timerLabel: String) -> CGFloat {
        if timeRemaining == 0 { return 0 }
        let initialTime = timerLabel == "Work" ? 1500 : 300 // Default dari TimerModel
        if initialTime == 0 { return 0 }
        return 1.0 - CGFloat(timeRemaining) / CGFloat(initialTime)
    }
    
    func formatTime(_ totalSeconds: Int) -> String {
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
