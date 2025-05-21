import SwiftUI
import WatchKit

@main
struct GTUpWatch_Watch_AppApp: App {
    @StateObject private var viewModel = TimerViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .onOpenURL { url in
                    if url.scheme == "gtup" && url.host == "timer" {
                        if url.path == "/running" && viewModel.isTimerRunning {
                            // Tetap di RunningTimerView
                        } else if url.path == "/done" && viewModel.isTimerDone {
                            // Tetap di DoneTimerView
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TimerDone"))) { _ in
                    viewModel.isTimerDone = true
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AppBecameActive"))) { _ in
                    viewModel.checkTimerState()
                }
        }
    }
}
