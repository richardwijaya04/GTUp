//
//  DataView.swift
//  CoreChal1
//
//  Created by Hendrik Nicolas Carlo on 24/03/25.
//
import SwiftUI
import Charts

struct DataView: View {
    let selectedBreak: Break? // Receive a single Break or nil
    @Binding var selectedDate: String
    
    var body: some View {
        ZStack {
            Color(uiColor: .primaryApp)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                VStack {
                    Text("Health Data")
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .foregroundColor(.fontApp)
                    CalendarView(selectedDate: $selectedDate)
                    Color.secondaryApp.frame(height: 5)
                }
                .ignoresSafeArea(edges: .top)
                .padding()
                
                VStack(spacing: 16) {
                    // Verify the break matches selectedDate
                    if let breakDate = selectedBreak?.date, breakDate == selectedDate {
                        CountView(type: "Work", count: Int(selectedBreak?.getWorkDuration() ?? 0))
                        CountView(type: "Break", count: (selectedBreak?.getBreakTotal()) ?? 0)
                    } else {
                        VStack(alignment: .center) {
                            Text("No data for \(selectedDate)")
                                .foregroundColor(.fontApp)
                                .font(.system(size: 18, weight: .bold, design: .default))
                        }.frame(width: 360, height: 100)
                            .background(.secondaryApp)
                            .cornerRadius(20)
                    }
                    DataSummaryView(selectedBreak: selectedBreak)
                }
                Spacer()
            }
        }
        .onAppear {
            // Optional: Log for debugging
            if let breakDate = selectedBreak?.date {
                print("DataView received break for date: \(breakDate), selectedDate: \(selectedDate)")
            } else {
                print("DataView received no break for selectedDate: \(selectedDate)")
            }
        }
    }
}
