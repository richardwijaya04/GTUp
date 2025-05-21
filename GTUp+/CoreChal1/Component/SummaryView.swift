//
//  DataSummaryView.swift
//  CoreChal1
//
//  Created by Hendrik Nicolas Carlo on 26/03/25.
//

import SwiftUI

struct DataSummaryView: View {
    let selectedBreak: Break?
    
    var body: some View {
        let breaks: Int = selectedBreak?.getBreakCounter() ?? 0
        let totalBreaks: Int = selectedBreak?.getBreakTotal() ?? 0
        
        ZStack {
            Color(uiColor: .secondaryApp)
            VStack(alignment: .leading) {
                Text("Summary")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.fontApp)
                    .padding(.bottom, 3)
                Spacer()
                if breaks == 0 {
                    Text("Looks like you haven't taken any breaks yet today. Try starting with a short 5-minute walk to get moving and reduce sitting time!")
                        .font(.system(size: 14))
                        .foregroundColor(Color(uiColor: .fontApp))
                } else if breaks <= 2 {
                    Text("Good start! You took \(breaks) micro break\(breaks == 1 ? "" : "s") today, which took \(totalBreaks) minutes and totaling \(breaks * 100) steps. Add a couple more breaks to keep the energy flowing!")
                        .font(.system(size: 14))
                        .foregroundColor(Color(uiColor: .fontApp))
                } else if breaks <= 4 {
                    Text("Nice work! You took \(breaks) micro breaks today summing up to \(totalBreaks) minutes, walking \(breaks * 100) steps in total. You're doing great—maybe sneak in one more for extra credit?")
                        .font(.system(size: 14))
                        .foregroundColor(Color(uiColor: .fontApp))
                } else {
                    Text("Great job staying active today! You took \(breaks) micro breaks, totaling \(totalBreaks) minutes, and walked \(breaks * 100) steps total—an excellent way to reduce prolonged sitting. Keep up the momentum!")
                        .font(.system(size: 14))
                        .foregroundColor(Color(uiColor: .fontApp))
                }
                Spacer()
            }.padding()
        }
        .frame(width: 360, height: 180)
        .cornerRadius(20)
    }
}

//#Preview {
//    DataSummaryView()
//}
