import SwiftUI

struct RunningTimerView: View {
    @ObservedObject var viewModel: TimerViewModel
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: viewModel.progress())
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: viewModel.progress())
                
                Text(viewModel.formatTime(viewModel.currentTimeRemaining))
                    .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentTimeRemaining)
            }
            .padding(.vertical, 10)
            .accessibilityLabel("Running timer: \(viewModel.formatTime(viewModel.currentTimeRemaining))")
            
            HStack(spacing: 20) {
                Button(action: { viewModel.resetTimerToInitial() }) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .foregroundStyle(.white)
                        .frame(width: 110, height: 20)
                        .font(.system(size: 30))
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Reset Timer")
                
                Button(action: { viewModel.stopTimer() }) {
                    Image(systemName: "stop.circle.fill")
                        .foregroundStyle(.white)
                        .frame(width: 110, height: 20)
                        .font(.system(size: 30))
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Stop Timer")
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct RunningTimerView_Previews: PreviewProvider {
    static var previews: some View {
        RunningTimerView(viewModel: TimerViewModel())
    }
}
