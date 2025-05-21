//
//  TimerModel.swift
//  CoreChal1
//
//  Created by Richard WIjaya Harianto on 09/05/25.
//

import Foundation
import SwiftUI

struct TimerModel {
    var labels: [String]
    var workTime: Int
    var breakTime: Int
    var test: Int
    
    init(labels: [String] = ["Work", "Break", "Test"], workTime: Int = 1500, breakTime: Int = 300, test: Int = 10) {
        self.labels = labels
        self.workTime = workTime
        self.breakTime = breakTime
        self.test = test
    }
}
