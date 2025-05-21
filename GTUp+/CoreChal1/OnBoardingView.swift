// OnboardingView.swift

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var workingHours: String = ""
    @State private var mandatoryRestHours: String = ""
    @State private var navigateToTimerView: Bool = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            TabView(selection: $currentPage) {
                // Halaman 1-5 menggunakan ForEach
                ForEach(0..<onboardingPages.count, id: \.self) { index in
                    VStack(spacing: 20) {
                        Spacer()

                        Image(onboardingPages[index].imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .foregroundColor(.white)

                        Text(onboardingPages[index].title)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text(onboardingPages[index].description)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 40)

                        Spacer()
                    }
                    .tag(index)
                }

                // Halaman 6 (Form Input)
                VStack(spacing: 20) {
                    Spacer()

                    Text("First,")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    VStack(spacing: 15) {
                        // TextField untuk Name dengan placeholder kustom
                        ZStack(alignment: .leading) {
                            if name.isEmpty {
                                Text("Tell us your name")
                                    .foregroundColor(.white) // Warna placeholder putih
                                    .padding(.leading, 35)
                                    .font(.system(size: 17))
                            }
                            TextField("", text: $name)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                        }

                        // TextField untuk Age dengan placeholder kustom
                        ZStack(alignment: .leading) {
                            if age.isEmpty {
                                Text("How old are you?")
                                    .foregroundColor(.white) // Warna placeholder putih
                                    .padding(.leading, 35)
                                    .font(.system(size: 17))
                            }
                            TextField("", text: $age)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .keyboardType(.numberPad)
                        }

                        // TextField untuk Working Hours dengan placeholder kustom
                        ZStack(alignment: .leading) {
                            if workingHours.isEmpty {
                                Text("Working hours?")
                                    .foregroundColor(.white) // Warna placeholder putih
                                    .padding(.leading, 35)
                                    .font(.system(size: 17))
                            }
                            TextField("", text: $workingHours)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .keyboardType(.numberPad)
                        }

                        // TextField untuk Mandatory Rest Hours dengan placeholder kustom
                        ZStack(alignment: .leading) {
                            if mandatoryRestHours.isEmpty {
                                Text("Mandatory Rest Hours?")
                                    .foregroundColor(.white) // Warna placeholder putih
                                    .padding(.leading, 35)
                                    .font(.system(size: 17))
                            }
                            TextField("", text: $mandatoryRestHours)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .keyboardType(.numberPad)
                        }
                    }

                    Spacer()

                    Button(action: {
                        // Simpan data ke UserDefaults
                        UserDefaults.standard.set(name, forKey: "userName")
                        UserDefaults.standard.set(Int(age) ?? 0, forKey: "userAge")
                        UserDefaults.standard.set(Int(workingHours) ?? 0, forKey: "workingHours")
                        UserDefaults.standard.set(Int(mandatoryRestHours) ?? 0, forKey: "mandatoryRestHours")
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        
                        // Navigasi ke TimerView
                        navigateToTimerView = true
                    }) {
                        Text("Next")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                    .padding(.bottom, 40)

                    // Navigasi ke TimerView
                    NavigationLink(
                        destination: ContentView(),
                        isActive: $navigateToTimerView,
                        label: { EmptyView() }
                    )
                }
                .tag(onboardingPages.count)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
    }
}

#Preview {
    OnboardingView()
}
