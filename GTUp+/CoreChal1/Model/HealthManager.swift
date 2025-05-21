//
//  HealthManager.swift
//  CoreChal1
//
//  Created by Hendrik Nicolas Carlo on 05/04/25.
//

import Foundation
import HealthKit

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }

    static var startOfWeek: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2
        return calendar.date(from: components)!
    }
}

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    @Published var activity: Int = 0
    @Published var isAuthorized = false
    
    init() {
        requestAuthorization()
        
    }
    
    func requestAuthorization() {
        let steps = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let healthTypes: Set = [steps]

        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                DispatchQueue.main.async {
                    self.isAuthorized = true
                }
            } catch {
                print("HealthKit authorization failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isAuthorized = false
                }
            }
        }
    }

    func fetchTodayStepCount(completion: @escaping (Int) -> Void) {
        let steps = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())

        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, result, error in
            var stepsCount = 0
            if let quantity = result?.sumQuantity(), error == nil {
                stepsCount = Int(quantity.doubleValue(for: .count()))
                print("Today steps: \(stepsCount)")
            } else {
                print("Error fetching steps: \(String(describing: error))")
            }
            completion(stepsCount)
        }
        healthStore.execute(query)
    }
    func getTodayStep(){
        fetchTodayStepCount { stepCount in
            DispatchQueue.main.async {
                self.activity = stepCount
            }
        }
    }
}
