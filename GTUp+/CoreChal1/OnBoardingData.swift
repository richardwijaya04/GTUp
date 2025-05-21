//
//  OnBoardingData.swift
//  CoreChal1
//
//  Created by Richard WIjaya Harianto on 05/04/25.
//


import Foundation

struct OnboardingData {
    let imageName: String
    let title: String
    let description: String
}

let onboardingPages: [OnboardingData] = [
    OnboardingData(
        imageName: "Work",
        title: "Work",
        description: "Working in a desk may be tiring and makes you forget when to rest. Taking short breaks throughout the day can enhance your productivity and well-being. Let's get started!"
    ),
    OnboardingData(
        imageName: "Work",
        title: "Rest",
        description: "GT↑UP provides custom break frequency and duration based on your activities, such as stretching, breathing, or eye relaxation."
    ),
    OnboardingData(
        imageName: "Work",
        title: "Be reminded",
        description: "A customizable break reminder that rings for vibrant every 30 minutes, with a recommended duration of 2-5 minutes."
    ),
    OnboardingData(
        imageName: "Work",
        title: "See your progress",
        description: "See your steps and progress through the week, month, and year and get your personalized recommendation!"
    )
]
