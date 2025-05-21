//
//  MainTimerView.swift
//  CoreChal1
//
//  Created by Richard WIjaya Harianto on 07/05/25.
//

import SwiftUI

struct MainTimerView: View {
    @ObservedObject var viewModel: TimerViewModel
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        VStack (spacing: 10){
            Text("GTUp!")
            List {
                ForEach(viewModel.labels, id: \.self) {label in
                    HStack{
                        VStack {
                            Text(label)
                                .font(.system(.title3, design: .rounded, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.leading, 10)
                            
                            Text(viewModel.formatTime(label == "Work" ? viewModel.workTime : viewModel.breakTime))
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button(action: {
                            viewModel.selectedLabel = label
                            viewModel.currentTimeRemaining = label == "Work" ? viewModel.workTime : viewModel.breakTime
                            viewModel.isTimerRunning = true
                            viewModel.startTimer()
                        }) {
                            Image(systemName: "play.fill")
                                .foregroundColor(.black)
                                .frame(width: 40, height: 40)
                                .background(Color.white)
                                .cornerRadius(50)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, -5)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                // App became active - check if timer state needs updating
                print("App became active")
            case .background:
                // App went to background - ensure state is saved
                print("App went to background")
            case .inactive:
                // App is inactive but visible
                print("App became inactive")
            @unknown default:
                break
            }
        }
    }
}

struct MainTimerView_Previews: PreviewProvider {
    static var previews: some View {
        MainTimerView(viewModel: TimerViewModel())
    }
}
