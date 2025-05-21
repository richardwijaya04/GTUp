//
//  TimerView.swift
//  CoreChal1
//
//  Created by Hendrik Nicolas Carlo on 24/03/25.
//

import SwiftUI
import Combine
import UserNotifications

struct TimerView: View {
    @EnvironmentObject var manager: HealthKitManager
    let breakRecord: Break
    var onBreakRecorded: () -> Void
    
    @Binding var isTimerRunning: Bool
    
    @State private var isAnimating: Bool = false
    @State private var lineOffset: CGFloat = 0
    @State private var textOpacity: Double = 0
    @State private var textScale: CGFloat = 0.5
    @State private var workPulse: CGFloat = 1.0
    @State private var breakPulse: CGFloat = 1.0
    @State private var selectedMode: String? = nil
    @State private var workScale: CGFloat = 1.0
    @State private var breakScale: CGFloat = 1.0
    @State private var lineScale: CGFloat = 1.0
    @State private var workOffset: CGSize = .zero
    @State private var breakOffset: CGSize = .zero
    @State private var lineOffsetXY: CGSize = .zero
    @State private var workImageOpacity: Double = 0
    @State private var breakImageOpacity: Double = 0
    @State private var workDurationOpacity: Double = 0
    @State private var breakDurationOpacity: Double = 0
    
    @State private var workTimeRemaining: Int = 0
    @State private var breakTimeRemaining: Int = 0
    @State private var initialWorkTime: Int = 0
    @State private var initialBreakTime: Int = 0
    @State private var timer: Timer? = nil
    
    @State private var prevStep: Int = 0
    @State private var currStep: Int = 0
    @State private var tempStep: Int = 0
    @State private var stepPatienceCounter: Int = 0
    
    @State private var isLongPressing: Bool = false
    @State private var longPressProgress: CGFloat = 0.0
    private let longPressDuration: Double = 1.0
    @State var longPressTime = 0.0
    
    @State private var timerStartDate: Date? = nil

    var body: some View {
        ZStack {
            Color.primaryApp
                .ignoresSafeArea()
            
            CurvedLine()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.9),
                            Color.white.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 300, height: 500)
                .scaleEffect(lineScale)
                .offset(lineOffsetXY)
                // Hapus animasi berulang untuk lineOffset
                .animation(
                    Animation.spring(response: 0.7, dampingFraction: 0.8), // Buat spring lebih halus
                    value: lineScale
                )
                .animation(
                    Animation.spring(response: 0.7, dampingFraction: 0.8), // Buat spring lebih halus
                    value: lineOffsetXY
                )
                .onAppear {
                    lineOffset = 20
                }
            
            VStack(spacing: 25) {
                Image("Work")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.white)
                    .opacity(workImageOpacity)
                    .animation(
                        Animation.easeInOut(duration: 0.5),
                        value: workImageOpacity
                    )
                
                Text("Work")
                    .font(.system(size: 60, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .opacity(textOpacity)
                    .scaleEffect(textScale * workScale) // Hapus workPulse
                    .offset(workOffset)
                    .animation(
                        Animation.spring(response: 0.7, dampingFraction: 0.8) // Buat spring lebih halus
                            .delay(0.2),
                        value: textScale
                    )
                    // Hapus animasi workPulse
                    .animation(
                        Animation.spring(response: 0.7, dampingFraction: 0.8), // Buat spring lebih halus
                        value: workScale
                    )
                    .animation(
                        Animation.spring(response: 0.7, dampingFraction: 0.8), // Buat spring lebih halus
                        value: workOffset
                    )
                
                ZStack {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: geometry.size.width, height: 50)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue.opacity(0.7))
                                .frame(width: geometry.size.width * progress(for: workTimeRemaining, initial: initialWorkTime), height: 50)
                        }
                    }
                    .frame(width: 150, height: 50)
                    
                    Text(formatTime(workTimeRemaining))
                        .font(.system(size: 25, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                }
                .opacity(workDurationOpacity)
                .animation(
                    Animation.easeInOut(duration: 0.5),
                    value: workDurationOpacity
                )

                // Tambah "Hold to Stop" di sini untuk Work
                if isTimerRunning && selectedMode == "Work" {
                    Text("Hold to Stop")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.top, 10) // Jarak sedikit dari progress bar
                }
            }
            .position(x: selectedMode == "Work" ? UIScreen.main.bounds.width / 2 : UIScreen.main.bounds.width / 3.5,
                      y: selectedMode == "Work" ? UIScreen.main.bounds.height / 2 : UIScreen.main.bounds.height / 5.6)
            .animation(
                Animation.spring(response: 0.5, dampingFraction: 0.6),
                value: selectedMode
            )
            .onTapGesture {
                if !isTimerRunning {
                    withAnimation {
                        selectedMode = "Work"
                        workScale = 1.5
                        breakScale = 0.5
                        lineScale = 0.5
                        workOffset = .zero
                        breakOffset = CGSize(width: 100, height: 200)
                        lineOffsetXY = CGSize(width: 100, height: 200)
                        workImageOpacity = 1
                        breakImageOpacity = 0
                        workDurationOpacity = 1
                        breakDurationOpacity = 0
                        startTimer()
                    }
                }
            }
            .gesture(
                LongPressGesture(minimumDuration: longPressDuration)
                    .onChanged { _ in
                        if selectedMode == "Work" && isTimerRunning {
                            startLongPress()
                        }
                    }
                    .onEnded { _ in
                        if selectedMode == "Work" && isTimerRunning {
                            stopLongPress()
                            resetToInitialState()
                        }
                    }
            )
            .onAppear {
                // Hapus pengaturan workPulse
            }
            
            VStack(spacing: 25) {
                Image("Break")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.white)
                    .opacity(breakImageOpacity)
                    .animation(
                        Animation.easeInOut(duration: 0.5),
                        value: breakImageOpacity
                    )
                
                Text("Break")
                    .font(.system(size: 60, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .opacity(textOpacity)
                    .scaleEffect(textScale * breakScale) // Hapus breakPulse
                    .offset(breakOffset)
                    .animation(
                        Animation.spring(response: 0.7, dampingFraction: 0.8) // Buat spring lebih halus
                            .delay(0.4),
                        value: textScale
                    )
                    // Hapus animasi breakPulse
                    .animation(
                        Animation.spring(response: 0.7, dampingFraction: 0.8), // Buat spring lebih halus
                        value: breakScale
                    )
                    .animation(
                        Animation.spring(response: 0.7, dampingFraction: 0.8), // Buat spring lebih halus
                        value: breakOffset
                    )
                
                ZStack {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: geometry.size.width, height: 50)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.green.opacity(0.7))
                                .frame(width: geometry.size.width * progress(for: breakTimeRemaining, initial: initialBreakTime), height: 50)
                        }
                    }
                    .frame(width: 150, height: 50)
                    
                    Text(formatTime(breakTimeRemaining))
                        .font(.system(size: 25, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                }
                .opacity(breakDurationOpacity)
                .animation(
                    Animation.easeInOut(duration: 0.5),
                    value: breakDurationOpacity
                )

                // Tambah "Hold to Stop" di sini untuk Break
                if isTimerRunning && selectedMode == "Break" {
                    Text("Hold to Stop")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.top, 10) // Jarak sedikit dari progress bar
                }
            }
            .position(x: selectedMode == "Break" ? UIScreen.main.bounds.width / 2 : 3 * UIScreen.main.bounds.width / 4.4,
                      y: selectedMode == "Break" ? UIScreen.main.bounds.height / 2 : 2 * UIScreen.main.bounds.height / 3.6)
            .animation(
                Animation.spring(response: 0.5, dampingFraction: 0.6),
                value: selectedMode
            )
            .onTapGesture {
                if !isTimerRunning {
                    withAnimation {
                        selectedMode = "Break"
                        breakScale = 1.5
                        workScale = 0.5
                        lineScale = 0.5
                        breakOffset = .zero
                        workOffset = CGSize(width: -100, height: -200)
                        lineOffsetXY = CGSize(width: -100, height: -200)
                        workImageOpacity = 0
                        breakImageOpacity = 1
                        workDurationOpacity = 0
                        breakDurationOpacity = 1
                        startTimer()
                    }
                }
            }
            .gesture(
                LongPressGesture(minimumDuration: longPressDuration)
                    .onChanged { _ in
                        if selectedMode == "Break" && isTimerRunning {
                            startLongPress()
                        }
                    }
                    .onEnded { _ in
                        if selectedMode == "Break" && isTimerRunning {
                            stopLongPress()
                            resetToInitialState()
                        }
                    }
            )
            .onAppear {
                // Hapus pengaturan breakPulse
            }
        }
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("Error requesting notification permission: \(error)")
                } else {
                    print("Notification permission granted: \(granted)")
                }
            }

            withAnimation {
                textOpacity = 1
                textScale = 1
            }
            loadTimerValues()
            checkForBackgroundTimer()
        }
        .onDisappear {
            saveTimerState()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TimerSetNotification"))) { _ in
            loadTimerValues()
        }
    }
    
    private func loadTimerValues() {
        let hours = UserDefaults.standard.integer(forKey: "timerHours")
        let minutes = UserDefaults.standard.integer(forKey: "timerMinutes")
        let seconds = UserDefaults.standard.integer(forKey: "timerSeconds")
        let breakMinutes = UserDefaults.standard.integer(forKey: "breakMinutes")
        
        // Jika semua nilai 0 (user baru), set default ke 5 menit untuk work dan break
        if hours == 0 && minutes == 0 && seconds == 0 {
            workTimeRemaining = 5 * 60 // Default 5 menit (300 detik)
            initialWorkTime = workTimeRemaining
        } else {
            workTimeRemaining = (hours * 3600) + (minutes * 60) + seconds
            initialWorkTime = workTimeRemaining
        }
        
        if breakMinutes == 0 {
            breakTimeRemaining = 5 * 60 // Default 5 menit (300 detik)
            initialBreakTime = breakTimeRemaining
        } else {
            breakTimeRemaining = breakMinutes * 60
            initialBreakTime = breakTimeRemaining
        }
        
        stopTimer()
    }
    
    private func startTimer() {
        guard !isTimerRunning else { return }
        self.isTimerRunning = true
        timerStartDate = Date()
        
        // Pastikan workTimeRemaining dan breakTimeRemaining minimal 1 detik
        if workTimeRemaining < 1 {
            workTimeRemaining = 5 * 60 // Default 5 menit
            initialWorkTime = workTimeRemaining
        }
        if breakTimeRemaining < 1 {
            breakTimeRemaining = 5 * 60 // Default 5 menit
            initialBreakTime = breakTimeRemaining
        }
        
        // Schedule notifikasi hanya jika timeInterval > 0
        if (selectedMode == "Work" && workTimeRemaining > 0) || (selectedMode == "Break" && breakTimeRemaining > 0) {
            scheduleNotification()
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if selectedMode == "Work" {
                if workTimeRemaining > 0 {
                    workTimeRemaining -= 1
                    //add logic here
                    interuptTimer(time: workTimeRemaining)
                    
                } else {
                    stopTimer()
                    withAnimation {
                        selectedMode = "Break"
                        breakScale = 1.5
                        workScale = 0.5
                        lineScale = 0.5
                        breakOffset = .zero
                        workOffset = CGSize(width: -100, height: -200)
                        lineOffsetXY = CGSize(width: -100, height: -200)
                        workImageOpacity = 0
                        breakImageOpacity = 1
                        workDurationOpacity = 0
                        breakDurationOpacity = 1
                        startTimer()
                    }
                }
            } else if selectedMode == "Break" {
                if breakTimeRemaining > 0 {
                    breakTimeRemaining -= 1
                } else {
                    stopTimer()
                    withAnimation {
                        selectedMode = nil
                        workScale = 1.0
                        breakScale = 1.0
                        lineScale = 1.0
                        workOffset = .zero
                        breakOffset = .zero
                        lineOffsetXY = .zero
                        workImageOpacity = 0
                        breakImageOpacity = 0
                        workDurationOpacity = 0
                        breakDurationOpacity = 0
                    }
                    loadTimerValues()
                    breakRecord.recordBreak()
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        self.isTimerRunning = false
        timerStartDate = nil
        
        UserDefaults.standard.removeObject(forKey: "timerStartDate")
        UserDefaults.standard.removeObject(forKey: "timerMode")
        UserDefaults.standard.removeObject(forKey: "workTimeRemaining")
        UserDefaults.standard.removeObject(forKey: "breakTimeRemaining")
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /// test features
    private func interuptTimer(time: Int){
        if (stepPatienceCounter <= 3){
            if (time % 60 == 0 ){
                print("fetching steps \(stepPatienceCounter)")
                manager.getTodayStep()
                currStep = manager.activity
                tempStep = currStep - prevStep
                
                if tempStep >= 50 {
                    stepPatienceCounter += 1
                }else {
                    stepPatienceCounter = 0
                }
                
                prevStep = currStep
            }
        }else {
            stepPatienceCounter = 0
            stopTimer()
            currStep = 0
            prevStep = 0
            tempStep = 0
        }
    }
    
    private func progress(for timeRemaining: Int, initial: Int) -> CGFloat {
        if initial == 0 { return 0 }
        let progress = 1.0 - CGFloat(timeRemaining) / CGFloat(initial)
        return max(0, min(progress, 1.0))
    }
    
    private func formatTime(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func startLongPress() {
        print("startLongPress called")
        isLongPressing = true
        longPressProgress = 0.0

        withAnimation(.linear(duration: longPressDuration)) {
            longPressProgress = 1.0
        }
    }
    
    private func stopLongPress() {
        print("stopLongPress called")
        isLongPressing = false
        withAnimation(.linear(duration: 0.2)) {
            longPressProgress = 0.0
        }
    }
    
    private func resetToInitialState() {
        withAnimation {
            selectedMode = nil
            workScale = 1.0
            breakScale = 1.0
            lineScale = 1.0
            workOffset = .zero
            breakOffset = .zero
            lineOffsetXY = .zero
            workImageOpacity = 0
            breakImageOpacity = 0
            workDurationOpacity = 0
            breakDurationOpacity = 0
            stopTimer()
            loadTimerValues()
        }
    }
    
    private func saveTimerState() {
        if isTimerRunning, let mode = selectedMode, let startDate = timerStartDate {
            UserDefaults.standard.set(startDate, forKey: "timerStartDate")
            UserDefaults.standard.set(mode, forKey: "timerMode")
            UserDefaults.standard.set(workTimeRemaining, forKey: "workTimeRemaining")
            UserDefaults.standard.set(breakTimeRemaining, forKey: "breakTimeRemaining")
        }
    }
    
    private func checkForBackgroundTimer() {
        if let startDate = UserDefaults.standard.object(forKey: "timerStartDate") as? Date,
           let mode = UserDefaults.standard.string(forKey: "timerMode"),
           let savedWorkTime = UserDefaults.standard.object(forKey: "workTimeRemaining") as? Int,
           let savedBreakTime = UserDefaults.standard.object(forKey: "breakTimeRemaining") as? Int {
            
            let elapsedTime = Int(Date().timeIntervalSince(startDate))
            
            if mode == "Work" {
                workTimeRemaining = max(0, savedWorkTime - elapsedTime)
                breakTimeRemaining = savedBreakTime
                if workTimeRemaining == 0 {
                    selectedMode = "Break"
                    breakScale = 1.5
                    workScale = 0.5
                    lineScale = 0.5
                    breakOffset = .zero
                    workOffset = CGSize(width: -100, height: -200)
                    lineOffsetXY = CGSize(width: -100, height: -200)
                    workImageOpacity = 0
                    breakImageOpacity = 1
                    workDurationOpacity = 0
                    breakDurationOpacity = 1
                    startTimer()
                } else {
                    selectedMode = "Work"
                    workScale = 1.5
                    breakScale = 0.5
                    lineScale = 0.5
                    workOffset = .zero
                    breakOffset = CGSize(width: 100, height: 200)
                    lineOffsetXY = CGSize(width: 100, height: 200)
                    workImageOpacity = 1
                    breakImageOpacity = 0
                    workDurationOpacity = 1
                    breakDurationOpacity = 0
                    startTimer()
                }
            } else if mode == "Break" {
                breakTimeRemaining = max(0, savedBreakTime - elapsedTime)
                workTimeRemaining = savedWorkTime
                if breakTimeRemaining == 0 {
                    resetToInitialState()
                } else {
                    selectedMode = "Break"
                    breakScale = 1.5
                    workScale = 0.5
                    lineScale = 0.5
                    breakOffset = .zero
                    workOffset = CGSize(width: -100, height: -200)
                    lineOffsetXY = CGSize(width: -100, height: -200)
                    workImageOpacity = 0
                    breakImageOpacity = 1
                    workDurationOpacity = 0
                    breakDurationOpacity = 1
                    startTimer()
                }
            }
        }
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "\(selectedMode ?? "Timer") Finished!"
        content.body = "Your \(selectedMode ?? "timer") has completed."
        content.sound = UNNotificationSound.default

        let timeInterval = Double(selectedMode == "Work" ? workTimeRemaining : breakTimeRemaining)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

        let request = UNNotificationRequest(identifier: "\(selectedMode ?? "timer")_end", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled for \(selectedMode ?? "timer")")
            }
        }
    }
}

struct CurvedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let startPoint = CGPoint(x: rect.minX, y: rect.maxY)
        let endPoint = CGPoint(x: rect.maxX, y: rect.minY)
        let controlPoint1 = CGPoint(x: rect.midX - 50, y: rect.maxY)
        let controlPoint2 = CGPoint(x: rect.midX + 50, y: rect.minY)
        
        path.move(to: startPoint)
        path.addCurve(to: endPoint, control1: controlPoint1, control2: controlPoint2)
        
        return path
    }
}
