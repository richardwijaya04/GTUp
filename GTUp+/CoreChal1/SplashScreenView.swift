//
//  SplashScreenView.swift
//  CoreChal1
//
//  Created by Richard WIjaya Harianto on 05/04/25.
//

import SwiftUI

struct SplashScreenView: View {
    // State untuk mengatur animasi
    @State private var isStanding = false
    @State private var fadeIn = false
    @State private var scale: CGFloat = 1.0
    @State private var textOpacity: Double = 0.0
    @State private var navigateToMain = false // Untuk navigasi ke view berikutnya
    @State private var hasCompletedOnboarding: Bool = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @State private var destinationIsTimerView: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Latar belakang hitam
                Color.black
                    .ignoresSafeArea()

                // Gambar dengan transisi smooth
                VStack {
                    Spacer()

                    ZStack {
                        // Gambar posisi duduk (SF Symbol)
                        Image("Work")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300) // Sesuaikan ukuran gambar
                            .foregroundColor(.white) // Atur warna agar terlihat di latar belakang hitam
                            .opacity(isStanding ? 0 : 1)
                            .scaleEffect(scale)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isStanding)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: scale)

                        // Gambar posisi berdiri
                        Image("Break")
                            .renderingMode(.original) // Pastikan gambar ditampilkan dengan warna asli
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300) // Sesuaikan ukuran gambar
                            .opacity(isStanding ? 1 : 0)
                            .scaleEffect(scale)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isStanding)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: scale)
                    }

                    Spacer()

                    // Teks "GTUP!"
                    Text("GTUP!")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(textOpacity)
                        .animation(.easeInOut(duration: 1.0), value: textOpacity)
                        .padding(.bottom, 50) // Jarak dari bawah
                }
            }
            .onAppear {
                print("SplashScreenView muncul")
                print("isStanding awal: \(isStanding)") // Debugging state awal
                print("Has completed onboarding: \(hasCompletedOnboarding)") // Debugging status onboarding

                // Animasi saat muncul
                withAnimation(.easeInOut(duration: 1.0)) {
                    fadeIn = true
                    scale = 1.05 // Sedikit zoom untuk efek hidup
                    textOpacity = 1.0 // Teks muncul
                }

                // Delay sebelum transisi dari duduk ke berdiri
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    print("Transisi ke posisi berdiri")
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        isStanding = true // Transisi ke posisi berdiri
                    }
                }

                // Navigasi ke view berikutnya setelah animasi selesai
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    print("Navigasi ke view berikutnya")
                    destinationIsTimerView = hasCompletedOnboarding
                    navigateToMain = true
                }
            }
            // Navigasi ke view berikutnya berdasarkan status onboarding
            .navigationDestination(isPresented: $navigateToMain) {
                if destinationIsTimerView {
                    OnboardingView() //sementara untuk debug dulu harusnya dia langsung ke contentview
                        .navigationBarBackButtonHidden(true)
                } else {
                    OnboardingView()
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
