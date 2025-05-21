//
//  TimerView.swift
//  CoreChal1
//
//  Created by Richard WIjaya Harianto on 15/05/25.
//

import WidgetKit

struct TimerEntry: TimelineEntry {
    let date: Date
    let timerRunning: Bool
    let timeRemaining: Int
    let timerLabel: String
    let isDone: Bool
}
