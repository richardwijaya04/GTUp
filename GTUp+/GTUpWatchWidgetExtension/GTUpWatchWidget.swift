//import WidgetKit
//import SwiftUI
//
//struct Provider: TimelineProvider {
//    let userDefaults: UserDefaults
//    
//    init() {
//        self.userDefaults = UserDefaults(suiteName: "group.com.richardwijaya.CoreChal1") ?? .standard
//    }
//    
//    func placeholder(in context: Context) -> TimerEntry {
//        TimerEntry(date: Date(), timerRunning: false, timeRemaining: 1500, timerLabel: "Work", isDone: false)
//    }
//    
//    func getSnapshot(in context: Context, completion: @escaping (TimerEntry) -> ()) {
//        let entry = TimerEntry(
//            date: Date(),
//            timerRunning: userDefaults.bool(forKey: "isTimerRunning"),
//            timeRemaining: max(0, userDefaults.integer(forKey: "currentTimeRemaining")),
//            timerLabel: userDefaults.string(forKey: "selectedLabel") ?? "Work",
//            isDone: userDefaults.bool(forKey: "isTimerDone")
//        )
//        completion(entry)
//    }
//    
//    func getTimeline(in context: Context, completion: @escaping (Timeline<TimerEntry>) -> ()) {
//        let currentDate = Date()
//        let isTimerRunning = userDefaults.bool(forKey: "isTimerRunning")
//        let isTimerDone = userDefaults.bool(forKey: "isTimerDone")
//        let timeRemaining = max(0, userDefaults.integer(forKey: "currentTimeRemaining"))
//        let timerLabel = userDefaults.string(forKey: "selectedLabel") ?? "Work"
//        
//        var entries: [TimerEntry] = []
//        
//        if isTimerRunning && !isTimerDone && timeRemaining > 0 {
//            // Buat entri untuk setiap detik sampai timer selesai (batasi 60 detik untuk efisiensi)
//            for secondOffset in 0...min(timeRemaining, 60) {
//                let entryDate = Calendar.current.date(byAdding: .second, value: secondOffset, to: currentDate)!
//                let remainingTime = max(0, timeRemaining - secondOffset)
//                let entry = TimerEntry(
//                    date: entryDate,
//                    timerRunning: true,
//                    timeRemaining: remainingTime,
//                    timerLabel: timerLabel,
//                    isDone: remainingTime == 0
//                )
//                entries.append(entry)
//            }
//        } else {
//            let entry = TimerEntry(
//                date: currentDate,
//                timerRunning: isTimerRunning,
//                timeRemaining: timeRemaining,
//                timerLabel: timerLabel,
//                isDone: isTimerDone
//            )
//            entries.append(entry)
//        }
//        
//        // Refresh tiap detik kalau running, tiap 15 menit kalau idle/done
//        let refreshDate = isTimerRunning ?
//            Calendar.current.date(byAdding: .second, value: 1, to: currentDate)! :
//            Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
//        
//        let timeline = Timeline(entries: entries, policy: .after(refreshDate))
//        completion(timeline)
//    }
//}
//
//struct TimerEntry: TimelineEntry {
//    let date: Date
//    let timerRunning: Bool
//    let timeRemaining: Int
//    let timerLabel: String
//    let isDone: Bool
//}
//
//struct GTUpWidgetEntryView: View {
//    var entry: Provider.Entry
//    
//    func formatTime(_ totalSeconds: Int) -> String {
//        let minutes = (totalSeconds % 3600) / 60
//        let seconds = totalSeconds % 60
//        return String(format: "%02d:%02d", minutes, seconds)
//    }
//    
//    func progress() -> CGFloat {
//        if !entry.timerRunning { return 0 }
//        let initialTime = entry.timerLabel == "Work" ? 1500 : 300 // Default dari TimerModel
//        if initialTime == 0 { return 0 }
//        return 1.0 - CGFloat(entry.timeRemaining) / CGFloat(initialTime)
//    }
//    
//    var body: some View {
//        ZStack {
//            if entry.isDone {
//                VStack {
//                    Text("Done!")
//                        .font(.system(.headline, design: .rounded))
//                        .foregroundColor(.white)
//                    Text(entry.timerLabel)
//                        .font(.system(.caption, design: .rounded))
//                        .foregroundColor(.white)
//                }
//                .accessibilityLabel("Timer Done")
//            } else if entry.timerRunning {
//                ZStack {
//                    Circle()
//                        .stroke(Color.gray.opacity(0.3), lineWidth: 4)
//                        .frame(width: 50, height: 50)
//                    Circle()
//                        .trim(from: 0, to: progress())
//                        .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
//                        .frame(width: 50, height: 50)
//                        .rotationEffect(.degrees(-90))
//                    VStack(spacing: 2) {
//                        Text(entry.timerLabel)
//                            .font(.system(.caption2, design: .rounded))
//                            .foregroundColor(.white)
//                        Text(formatTime(entry.timeRemaining))
//                            .font(.system(.caption, design: .rounded))
//                            .foregroundColor(.white)
//                    }
//                }
//                .accessibilityLabel("\(entry.timerLabel) timer: \(formatTime(entry.timeRemaining))")
//            } else {
//                VStack {
//                    Text("GTUp!")
//                        .font(.system(.headline, design: .rounded))
//                        .foregroundColor(.white)
//                    Text("Start Timer")
//                        .font(.system(.caption, design: .rounded))
//                        .foregroundColor(.white)
//                }
//                .accessibilityLabel("Start Timer")
//            }
//        }
//        .containerBackground(.gray.opacity(0.3), for: .widget)
//        .widgetURL(URL(string: entry.isDone ? "gtup://timer/done" : "gtup://timer/running"))
//    }
//}
//
//struct GTUpWidget: Widget {
//    let kind: String = "GTUpWidget"
//    
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: Provider()) { entry in
//            GTUpWidgetEntryView(entry: entry)
//        }
//        .configurationDisplayName("GTUp Timer")
//        .description("Keep track of your work and break timers.")
//        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
//    }
//}
//
//#Preview(as: .accessoryCircular) {
//    GTUpWidget()
//} timeline: {
//    TimerEntry(date: Date(), timerRunning: false, timeRemaining: 1500, timerLabel: "Work", isDone: false)
//    TimerEntry(date: Date(), timerRunning: true, timeRemaining: 300, timerLabel: "Break", isDone: false)
//    TimerEntry(date: Date(), timerRunning: false, timeRemaining: 0, timerLabel: "Work", isDone: true)
//}
//
//@main
//struct GTUpWidgets: WidgetBundle {
//    var body: some Widget {
//        GTUpWidget()
//    }
//}
