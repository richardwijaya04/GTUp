//
//  WatchTimerView.swift
//  CoreChal1
//
//  Created by Richard WIjaya Harianto on 07/05/25.
//

import SwiftUI

struct WatchTimerView: View {
    @EnvironmentObject private var viewModel: TimerViewModel
    
    var body: some View {
        Group {
            if viewModel.isTimerDone {
                DoneTimerView(viewModel: viewModel)
                    .transition(.scaleAndFade)
                    .accessibilityLabel("Timer Done View")
            } else if viewModel.isTimerRunning {
                RunningTimerView(viewModel: viewModel)
                    .transition(.scaleAndFade)
                    .accessibilityLabel("Running Timer View")
            } else {
                MainTimerView(viewModel: viewModel)
                    .transition(.scaleAndFade)
                    .accessibilityLabel("Main Timer View")
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.isTimerDone)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isTimerRunning)
    }
}

extension AnyTransition {
    static var scaleAndFade: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity),
            removal: .scale(scale: 1.2).combined(with: .opacity)
        )
    }
}

struct WatchTimerView_Previews: PreviewProvider {
    static var previews: some View {
        WatchTimerView()
            .environmentObject(TimerViewModel())
    }
}
