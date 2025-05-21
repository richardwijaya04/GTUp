//
//  GTUpWidgetEntryView.swift
//  CoreChal1
//
//  Created by Richard WIjaya Harianto on 15/05/25.
//

import SwiftUI
import WidgetKit

// Waiters: Cuma nampilin data dari ViewModel
struct GTUpWidgetEntryView: View {
    let entry: TimerEntry
    private let viewModel: WidgetViewModel
    
    init(entry: TimerEntry) {
        self.entry = entry
        self.viewModel = WidgetViewModel()
    }
    
    var body: some View {
        ZStack {
            if entry.isDone {
                VStack {
                    Text("Done!")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                    Text(entry.timerLabel)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.white)
                }
                .accessibilityLabel("Timer Done")
            } else if entry.timerRunning {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                        .frame(width: 50, height: 50)
                    Circle()
                        .trim(from: 0, to: viewModel.getProgress(timeRemaining: entry.timeRemaining, timerLabel: entry.timerLabel))
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 2) {
                        Text(entry.timerLabel)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.white)
                        Text(viewModel.formatTime(entry.timeRemaining))
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .accessibilityLabel("\(entry.timerLabel) timer: \(viewModel.formatTime(entry.timeRemaining))")
            } else {
                VStack {
                    Text("GTUp!")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                    Text("Start Timer")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.white)
                }
                .accessibilityLabel("Start Timer")
            }
        }
        .containerBackground(.gray.opacity(0.3), for: .widget)
        .widgetURL(URL(string: entry.isDone ? "gtup://timer/done" : "gtup://timer/running"))
    }
}

#Preview {
    GTUpWidgetEntryView(entry: TimerEntry(
        date: Date(),
        timerRunning: true,
        timeRemaining: 300,
        timerLabel: "Break",
        isDone: false
    ))
    .previewContext(WidgetPreviewContext(family: .accessoryCircular))
}
