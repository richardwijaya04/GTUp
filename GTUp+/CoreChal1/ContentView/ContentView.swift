import SwiftUI
import SwiftData

enum Screen {
    case home
    case profile
    case data
    case timer
}

struct ContentView: View {
    @EnvironmentObject var manager: HealthKitManager
    @Environment(\.modelContext) private var modelContext
    
    @State private var breaks: [Break] = []
    
    @State private var selectedDate: String
    
    @State private var currentScreen: Screen = .home
    @State private var tabIndex: Int = 1
    @State private var isProfileVisible: Bool = false
    @State private var profileDragOffset: CGFloat = UIScreen.main.bounds.height
    @GestureState private var dragState: CGFloat = 0
    @State private var isTimerRunning: Bool = false
    @State private var dragOffset: CGFloat = 0
    @State private var profileOpacity: Double = 0.0
    
    // State untuk mengontrol visibilitas pemberitahuan swipe up
    @State private var showSwipeUpHint: Bool = true
    @State private var hintOpacity: Double = 0.0
    @State private var arrowOffset: CGFloat = 0.0
    
    // State untuk mengontrol visibilitas pemberitahuan swipe kiri/kanan
    @State private var showSwipeSideHint: Bool = true
    @State private var sideHintOpacity: Double = 0.0
    @State private var leftArrowOffset: CGFloat = 0.0
    @State private var rightArrowOffset: CGFloat = 0.0
    @State private var hasShownSwipeSideHint: Bool = false // State untuk melacak apakah swipe side hint sudah ditampilkan selama sesi ini
    @State private var stopArrowAnimation: Bool = false // State untuk menghentikan animasi panah
    
    private let tabScreens: [Screen] = [.timer, .home, .data]
    
    init() {
        let today = Calendar.current.startOfDay(for: Date())
        let todayString = today.formattedAsQueryDate
        _selectedDate = State(initialValue: todayString)
        UserDefaults.standard.set(todayString, forKey: "todayDate")
        
        // Reset state untuk swipe side hint setiap kali aplikasi dibuka
        _hasShownSwipeSideHint = State(initialValue: false)
        _showSwipeSideHint = State(initialValue: true)
    }
    
    private var latestBreak: Break {
        let today = Calendar.current.startOfDay(for: Date()).formattedAsQueryDate
        let predicate = #Predicate<Break> { data in
            data.date == today
        }
        do {
            let descriptor = FetchDescriptor<Break>(predicate: predicate, sortBy: [SortDescriptor(\.date, order: .reverse)])
            let todayBreaks = try modelContext.fetch(descriptor)
            if let existingBreak = todayBreaks.last {
                print("Using existing Break for today: \(existingBreak.date)")
                return existingBreak
            } else {
                let newBreak = Break(date: Date())
                modelContext.insert(newBreak)
                try modelContext.save()
                print("Created new Break for today: \(newBreak.date)")
                return newBreak
            }
        } catch {
            print("Failed to fetch or save Break: \(error)")
            let newBreak = Break(date: Date())
            modelContext.insert(newBreak)
            return newBreak
        }
    }
    
    private var selectedBreak: Break? {
        breaks.first { $0.date == selectedDate }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ZStack {
                    TimerSetView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .offset(x: offsetForIndex(0))
                        .opacity(opacityForIndex(0))
                        .allowsHitTesting(tabIndex == 0 && !isTimerRunning)
                        .animation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0), value: tabIndex)
                        .animation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0), value: dragOffset)
                    
                    TimerView(
                        breakRecord: latestBreak,
                        onBreakRecorded: {
                            updateQuery()
                        },
                        isTimerRunning: $isTimerRunning
                    )
                    .environmentObject(manager)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(x: offsetForIndex(1))
                    .opacity(opacityForIndex(1))
                    .allowsHitTesting(tabIndex == 1)
                    .animation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0), value: tabIndex)
                    .animation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0), value: dragOffset)
                    
                    DataView(selectedBreak: selectedBreak, selectedDate: $selectedDate)
                        .environmentObject(manager)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .offset(x: offsetForIndex(2))
                        .opacity(opacityForIndex(2))
                        .allowsHitTesting(tabIndex == 2 && !isTimerRunning)
                        .animation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0), value: tabIndex)
                        .animation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0), value: dragOffset)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(backgroundColor)
                .gesture(
                    isTimerRunning ? nil : DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            let horizontalTranslation = value.translation.width
                            if horizontalTranslation > 50 && tabIndex > 0 {
                                tabIndex -= 1
                                currentScreen = tabScreens[tabIndex]
                                showSwipeSideHint = false // Sembunyikan hint saat swipe
                            } else if horizontalTranslation < -50 && tabIndex < tabScreens.count - 1 {
                                tabIndex += 1
                                currentScreen = tabScreens[tabIndex]
                                showSwipeSideHint = false // Sembunyikan hint saat swipe
                            }
                            let verticalTranslation = value.translation.height
                            if verticalTranslation < -100 && currentScreen == .home {
                                withAnimation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0)) {
                                    isProfileVisible = true
                                    currentScreen = .profile
                                    profileDragOffset = 0
                                    profileOpacity = 1.0
                                    showSwipeUpHint = false
                                }
                            }
                            withAnimation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0)) {
                                dragOffset = 0
                            }
                        }
                )
                
                ProfileView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(backgroundColor)
                    .offset(y: isProfileVisible ? profileDragOffset + dragState : UIScreen.main.bounds.height + dragState)
                    .opacity(profileOpacity)
                    .animation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0), value: profileDragOffset)
                    .animation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0), value: profileOpacity)
                    .gesture(
                        isTimerRunning ? nil : DragGesture()
                            .updating($dragState) { value, state, _ in
                                if isProfileVisible {
                                    state = max(0, value.translation.height)
                                }
                            }
                            .onChanged { value in
                                if isProfileVisible {
                                    profileDragOffset = max(0, value.translation.height)
                                    let screenHeight = UIScreen.main.bounds.height
                                    profileOpacity = 1.0 - min(1.0, profileDragOffset / screenHeight)
                                }
                            }
                            .onEnded { value in
                                if value.translation.height > 100 {
                                    withAnimation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0)) {
                                        isProfileVisible = false
                                        currentScreen = tabScreens[tabIndex]
                                        profileDragOffset = UIScreen.main.bounds.height
                                        profileOpacity = 0.0
                                        showSwipeUpHint = true
                                        startHintAnimation()
                                    }
                                } else {
                                    withAnimation(.interpolatingSpring(stiffness: 200, damping: 25, initialVelocity: 0)) {
                                        profileDragOffset = 0
                                        profileOpacity = 1.0
                                    }
                                }
                            }
                    )
                    .allowsHitTesting(!isTimerRunning)
                
                // Pemberitahuan swipe kiri/kanan (muncul setiap kali aplikasi dibuka)
                if tabIndex == 1 && showSwipeSideHint && !isTimerRunning {
                    HStack {
                        // Swipe kiri
                        VStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .offset(x: stopArrowAnimation ? 0 : leftArrowOffset) // Hentikan animasi panah jika stopArrowAnimation = true
                                .animation(
                                    stopArrowAnimation ? nil : Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                                    value: leftArrowOffset
                                )
                            
                            Text("Swipe left to set timer")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        }
                        .opacity(sideHintOpacity)
                        .padding(.leading, 5)
                        
                        Spacer()
                        
                        // Swipe kanan
                        VStack(spacing: 5) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .offset(x: stopArrowAnimation ? 0 : rightArrowOffset) // Hentikan animasi panah jika stopArrowAnimation = true
                                .animation(
                                    stopArrowAnimation ? nil : Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                                    value: rightArrowOffset
                                )
                            
                            Text("Swipe right to see data")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                        }
                        .opacity(sideHintOpacity)
                        .padding(.trailing, 5)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    // Hapus modifier .animation untuk menghindari konflik
                    .onAppear {
                        startSideHintAnimation()
                    }
                }
                
                // Navigation dots dan pemberitahuan swipe up
                VStack {
                    Spacer()
                    
                    if tabIndex == 1 && showSwipeUpHint && !isTimerRunning {
                        VStack(spacing: 5) {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .offset(y: arrowOffset)
                                .animation(
                                    Animation.easeInOut(duration: 0.8)
                                        .repeatForever(autoreverses: true),
                                    value: arrowOffset
                                )
                            
                            Text("Swipe up to see profile")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .opacity(hintOpacity)
                        .animation(.easeInOut(duration: 0.5), value: hintOpacity)
                        .padding(.bottom, 10)
                        .onAppear {
                            startHintAnimation()
                        }
                    }
                    
                    NavigationDotsView(currentScreen: $currentScreen)
                        .padding(.bottom, 30)
                        .allowsHitTesting(!isTimerRunning)
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            updateQuery()
        }
        .onChange(of: selectedDate) { oldValue, newValue in
            updateQuery()
        }
    }
    
    private func startHintAnimation() {
        hintOpacity = 0.0
        arrowOffset = 0.0
        
        withAnimation(.easeInOut(duration: 0.5)) {
            hintOpacity = 0.8
        }
        
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            arrowOffset = -10
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                hintOpacity = 0.0
                showSwipeUpHint = false
            }
        }
    }
    
    private func startSideHintAnimation() {
        sideHintOpacity = 0.0
        leftArrowOffset = 0.0
        rightArrowOffset = 0.0
        stopArrowAnimation = false
        
        withAnimation(.easeInOut(duration: 0.5)) {
            sideHintOpacity = 0.8
        }
        
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            leftArrowOffset = -10
            rightArrowOffset = 10
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            // Hentikan animasi panah sebelum opacity menjadi 0
            withAnimation(.easeInOut(duration: 0.3)) {
                self.stopArrowAnimation = true
                self.leftArrowOffset = 0
                self.rightArrowOffset = 0
            }
            
            // Tunggu hingga animasi panah selesai, lalu mulai animasi opacity
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.7)) { // Durasi lebih lama untuk transisi lebih halus
                    print("Side hint opacity before fade out: \(self.sideHintOpacity)")
                    self.sideHintOpacity = 0.0
                }
                
                // Tunggu hingga animasi opacity selesai, lalu hapus view
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    print("Side hint opacity after fade out: \(self.sideHintOpacity)")
                    self.showSwipeSideHint = false
                    self.hasShownSwipeSideHint = true
                }
            }
        }
    }
    
    private func offsetForIndex(_ index: Int) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let position = CGFloat(index - tabIndex) * screenWidth
        return position + dragOffset
    }
    
    private func opacityForIndex(_ index: Int) -> Double {
        let screenWidth = UIScreen.main.bounds.width
        let position = abs(CGFloat(index - tabIndex) * screenWidth + dragOffset)
        let opacity = 1.0 - (position / screenWidth) * 0.3
        return max(0.7, min(1.0, opacity))
    }
    
    private var backgroundColor: Color {
        switch currentScreen {
        case .home: return Color.primaryApp
        case .profile: return Color.primaryApp
        case .data: return Color.primaryApp
        case .timer: return Color.primaryApp
        }
    }
    
    private func updateQuery() {
        let predicate = #Predicate<Break> { data in
            data.date == selectedDate
        }
        do {
            let descriptor = FetchDescriptor<Break>(predicate: predicate)
            breaks = try modelContext.fetch(descriptor)
            print("Fetched breaks for \(selectedDate): \(breaks.count)")
        } catch {
            print("Fetch failed: \(error)")
        }
    }
}

struct NavigationDotsView: View {
    @Binding var currentScreen: Screen
    
    private let screens: [Screen] = [.timer, .home, .data]
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(screens.indices, id: \.self) { index in
                if index == 1 {
                    Image(systemName: currentScreen == .profile ? "chevron.down" : "chevron.up")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(currentScreen == screens[index] ? .white : .gray.opacity(0.7))
                        .frame(width: 10, height: 25)
                        .animation(.easeInOut(duration: 0.3), value: currentScreen)
                } else {
                    Circle()
                        .frame(width: 10, height: 25)
                        .foregroundColor(currentScreen == screens[index] ? .white : .gray.opacity(0.7))
                        .animation(.spring(), value: currentScreen)
                }
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 12)
        .background(
            Capsule()
                .fill(Color.gray.opacity(0.3))
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(HealthKitManager())
}
