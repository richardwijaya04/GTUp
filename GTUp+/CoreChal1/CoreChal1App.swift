//
//  CoreChal1App.swift
//  CoreChal1
//
//  Created by Hendrik Nicolas Carlo on 20/03/25.
//

import SwiftUI
import SwiftData

@main
struct CoreChal1App: App {
    @StateObject var manager = HealthKitManager()
    var body: some Scene {
        WindowGroup {
//            SplashScreenView() // Atur SplashScreenView sebagai view awal
            ContentView()
                .environmentObject(manager)
                .modelContainer(for: Break.self)
        }
    }
}
