//
//  GTUpWidget.swift
//  CoreChal1
//
//  Created by Richard WIjaya Harianto on 15/05/25.
//

import WidgetKit
import SwiftUI

// Provider: Jembatan ke ViewModel
struct Provider: TimelineProvider {
    private let viewModel: WidgetViewModel
    
    init() {
        self.viewModel = WidgetViewModel()
    }
    
    func placeholder(in context: Context) -> TimerEntry {
        TimerEntry(date: Date(), timerRunning: false, timeRemaining: 1500, timerLabel: "Work", isDone: false)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TimerEntry) -> ()) {
        completion(viewModel.getSnapshotEntry())
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TimerEntry>) -> ()) {
        let (entries, refreshDate) = viewModel.getTimelineEntries()
        let timeline = Timeline(entries: entries, policy: .after(refreshDate))
        completion(timeline)
    }
}

struct GTUpWidget: Widget {
    let kind: String = "GTUpWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            GTUpWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("GTUp Timer")
        .description("Keep track of your work and break timers.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

#Preview(as: .accessoryCircular) {
    GTUpWidget()
} timeline: {
    TimerEntry(date: Date(), timerRunning: false, timeRemaining: 1500, timerLabel: "Work", isDone: false)
    TimerEntry(date: Date(), timerRunning: true, timeRemaining: 300, timerLabel: "Break", isDone: false)
    TimerEntry(date: Date(), timerRunning: false, timeRemaining: 0, timerLabel: "Work", isDone: true)
}

@main
struct GTUpWidgets: WidgetBundle {
    var body: some Widget {
        GTUpWidget()
    }
}
