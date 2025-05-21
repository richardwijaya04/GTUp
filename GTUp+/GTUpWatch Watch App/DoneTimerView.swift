import SwiftUI

struct DoneTimerView: View {
    @ObservedObject var viewModel: TimerViewModel
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: 1.0)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: viewModel.progress())
                
                Text("Done\n\(viewModel.formatTime(viewModel.currentTimeRemaining))")
                    .font(.system(.title2, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentTimeRemaining)
            }
            .padding(.vertical, 10)
            .accessibilityLabel("Timer done: \(viewModel.formatTime(viewModel.currentTimeRemaining))")
            
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
        .background(Color.gray.opacity(0.3).edgesIgnoringSafeArea(.all))
    }
}

struct DoneTimerView_Previews: PreviewProvider {
    static var previews: some View {
        DoneTimerView(viewModel: TimerViewModel())
    }
}
