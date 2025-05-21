import SwiftUI

struct ProfileView: View {
    @State private var name: String
    @State private var age: String
    @State private var workingHoursStart: Date
    @State private var workingHoursEnd: Date
    @State private var restHoursStart: Date
    @State private var restHoursEnd: Date
    
    @State private var showingNotifications = false
    @State private var showingResearchStudies = false
    @State private var showingDevices = false
    @State private var showingApps = false
    
    // State untuk melacak apakah keyboard aktif
    @FocusState private var isNameFieldFocused: Bool
    @FocusState private var isAgeFieldFocused: Bool
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    init() {
        let calendar = Calendar.current
        
        let savedName = UserDefaults.standard.string(forKey: "name") ?? "Carlo"
        let savedAge = UserDefaults.standard.string(forKey: "age") ?? "25"
        
        let savedWorkingStart = UserDefaults.standard.object(forKey: "workingHoursStart") as? Date
        let savedWorkingEnd = UserDefaults.standard.object(forKey: "workingHoursEnd") as? Date
        let savedRestStart = UserDefaults.standard.object(forKey: "restHoursStart") as? Date
        let savedRestEnd = UserDefaults.standard.object(forKey: "restHoursEnd") as? Date
        
        let startComponents = DateComponents(hour: 9, minute: 0)
        let endComponents = DateComponents(hour: 17, minute: 0)
        let restStartComponents = DateComponents(hour: 12, minute: 0)
        let restEndComponents = DateComponents(hour: 13, minute: 0)
        
        _name = State(initialValue: savedName)
        _age = State(initialValue: savedAge)
        _workingHoursStart = State(initialValue: savedWorkingStart ?? calendar.date(from: startComponents) ?? Date())
        _workingHoursEnd = State(initialValue: savedWorkingEnd ?? calendar.date(from: endComponents) ?? Date())
        _restHoursStart = State(initialValue: savedRestStart ?? calendar.date(from: restStartComponents) ?? Date())
        _restHoursEnd = State(initialValue: savedRestEnd ?? calendar.date(from: restEndComponents) ?? Date())
    }
    
    private func saveValues() {
        UserDefaults.standard.set(name, forKey: "name")
        UserDefaults.standard.set(age, forKey: "age")
        UserDefaults.standard.set(workingHoursStart, forKey: "workingHoursStart")
        UserDefaults.standard.set(workingHoursEnd, forKey: "workingHoursEnd")
        UserDefaults.standard.set(restHoursStart, forKey: "restHoursStart")
        UserDefaults.standard.set(restHoursEnd, forKey: "restHoursEnd")
    }
    
    // Fungsi untuk dismiss keyboard
    private func dismissKeyboard() {
        isNameFieldFocused = false
        isAgeFieldFocused = false
    }
    
    var body: some View {
        ZStack {
            Color.primaryApp
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("Profile")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.leading, 15)
                
                Rectangle()
                    .frame(width: 320, height: 1.5)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 5)
                    .padding(.top)
                
                List {
                    Section {
                        HStack {
                            Text("Name")
                                .foregroundColor(.white)
                            Spacer()
                            TextField("Name", text: $name, onCommit: {
                                saveValues()
                            })
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.trailing)
                            .focused($isNameFieldFocused)
                        }
                        .listRowBackground(Color.gray.opacity(0.2))
                        .overlay(
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(.white.opacity(0.3))
                                .offset(y: 22)
                        )
                        
                        HStack {
                            Text("Age")
                                .foregroundColor(.white)
                            Spacer()
                            TextField("Age", text: $age, onCommit: {
                                saveValues()
                            })
                            .foregroundColor(.white.opacity(0.7))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .focused($isAgeFieldFocused)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button(action: {
                                        dismissKeyboard()
                                    }) {
                                        Text("Done")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                }
                            }
                        }
                        .listRowBackground(Color.gray.opacity(0.2))
                        .overlay(
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(.white.opacity(0.3))
                                .offset(y: 22)
                        )
                        
                        HStack {
                            Text("Working Hours")
                                .foregroundColor(.white)
                            Spacer()
                            HStack(spacing: 5) {
                                DatePicker("", selection: $workingHoursStart, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .accentColor(.blue)
                                    .foregroundColor(.white)
                                    .environment(\.colorScheme, .dark)
                                    .frame(width: 70)
                                    .onChange(of: workingHoursStart) { _ in
                                        saveValues()
                                    }
                                Text("-")
                                    .foregroundColor(.white.opacity(0.7))
                                DatePicker("", selection: $workingHoursEnd, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .accentColor(.blue)
                                    .foregroundColor(.white)
                                    .environment(\.colorScheme, .dark)
                                    .frame(width: 70)
                                    .onChange(of: workingHoursEnd) { _ in
                                        saveValues()
                                    }
                            }
                        }
                        .listRowBackground(Color.gray.opacity(0.2))
                        .overlay(
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(.white.opacity(0.3))
                                .offset(y: 22)
                        )
                        
                        HStack(alignment: .center, spacing: 5) {
                            Text("Lunch Break")
                                .foregroundColor(.white)
                                .fixedSize(horizontal: true, vertical: false)
                            Spacer()
                            HStack(spacing: 5) {
                                DatePicker("", selection: $restHoursStart, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .accentColor(.blue)
                                    .foregroundColor(.white)
                                    .environment(\.colorScheme, .dark)
                                    .frame(width: 70)
                                    .onChange(of: restHoursStart) { _ in
                                        saveValues()
                                    }
                                Text("-")
                                    .foregroundColor(.white.opacity(0.7))
                                DatePicker("", selection: $restHoursEnd, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .accentColor(.blue)
                                    .foregroundColor(.white)
                                    .environment(\.colorScheme, .dark)
                                    .frame(width: 70)
                                    .onChange(of: restHoursEnd) { _ in
                                        saveValues()
                                    }
                            }
                            .fixedSize(horizontal: true, vertical: false)
                        }
                        .listRowBackground(Color.gray.opacity(0.2))
                        .overlay(
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(.white.opacity(0.3))
                                .offset(y: 22)
                        )
                        
                        Button(action: {
                            showingNotifications = true
                        }) {
                            HStack {
                                Text("Notifications")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                            }
                        }
                        .buttonStyle(PlainButtonStyle()) // Pastikan List tidak menelan interaksi tombol
                        .contentShape(Rectangle()) // Pastikan area tap tombol dikenali
                        .listRowBackground(Color.gray.opacity(0.2))
                    }
                    
                    Section(header: Text("Privacy")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(.white)
                        .textCase(nil)
                    ) {
                        Button(action: {
                            showingApps = true
                        }) {
                            HStack {
                                Text("Apps")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                            }
                        }
                        .buttonStyle(PlainButtonStyle()) // Pastikan List tidak menelan interaksi tombol
                        .contentShape(Rectangle()) // Pastikan area tap tombol dikenali
                        .listRowBackground(Color.gray.opacity(0.2))
                        .overlay(
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(.white.opacity(0.3))
                                .offset(y: 22)
                        )
                        
                        Button(action: {
                            showingResearchStudies = true
                        }) {
                            HStack {
                                Text("Research Studies")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                            }
                        }
                        .buttonStyle(PlainButtonStyle()) // Pastikan List tidak menelan interaksi tombol
                        .contentShape(Rectangle()) // Pastikan area tap tombol dikenali
                        .listRowBackground(Color.gray.opacity(0.2))
                        .overlay(
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(.white.opacity(0.3))
                                .offset(y: 22)
                        )
                        
                        Button(action: {
                            showingDevices = true
                        }) {
                            HStack {
                                Text("Devices")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                            }
                        }
                        .buttonStyle(PlainButtonStyle()) // Pastikan List tidak menelan interaksi tombol
                        .contentShape(Rectangle()) // Pastikan area tap tombol dikenali
                        .listRowBackground(Color.gray.opacity(0.2))
                        .overlay(
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(.white.opacity(0.3))
                                .offset(y: 22)
                        )
                        
                        // Added the text here as a row without any button functionality
                        HStack {
                            Text("Your data is encrypted on your device and can only be shared with your permission.")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 8)
                        }
                        .listRowBackground(Color.primaryApp)
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
                .scrollDisabled(true) // Dipertahankan sesuai permintaan
                // Deteksi scroll untuk dismiss keyboard (dipertahankan meskipun scroll disabled)
                .onScrollPhaseChange { oldPhase, newPhase in
                    if newPhase == .interacting {
                        dismissKeyboard()
                    }
                }
                
                // Sheet with iOS-style navigation bar for Notifications
                .sheet(isPresented: $showingNotifications) {
                    ModalView(title: "Notifications", isPresented: $showingNotifications) {
                        VStack(alignment: .leading, spacing: 15) {
                            Spacer()
                                .frame(height: 20)
                            
                            List {
                                NotificationSettingRow(title: "Activity Reminders", isOn: true)
                                    .listRowBackground(Color.gray.opacity(0.2))
                                    .overlay(
                                        Rectangle()
                                            .frame(height: 0.5)
                                            .foregroundColor(.white.opacity(0.3))
                                            .offset(y: 22)
                                    )
                                
                                NotificationSettingRow(title: "Weekly Reports", isOn: true)
                                    .listRowBackground(Color.gray.opacity(0.2))
                                    .overlay(
                                        Rectangle()
                                            .frame(height: 0.5)
                                            .foregroundColor(.white.opacity(0.3))
                                            .offset(y: 22)
                                    )
                                
                                NotificationSettingRow(title: "Goal Achievements", isOn: true)
                                    .listRowBackground(Color.gray.opacity(0.2))
                                    .overlay(
                                        Rectangle()
                                            .frame(height: 0.5)
                                            .foregroundColor(.white.opacity(0.3))
                                            .offset(y: 22)
                                    )
                                
                                NotificationSettingRow(title: "Break Reminders", isOn: false)
                                    .listRowBackground(Color.gray.opacity(0.2))
                                    .overlay(
                                        Rectangle()
                                            .frame(height: 0.5)
                                            .foregroundColor(.white.opacity(0.3))
                                            .offset(y: 22)
                                    )
                                
                                NotificationSettingRow(title: "App Updates", isOn: false)
                                    .listRowBackground(Color.gray.opacity(0.2))
                            }
                            .listStyle(PlainListStyle())
                            .scrollContentBackground(.hidden)
                            
                            Text("You'll receive notifications according to these settings during your specified working hours.")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                        }
                    }
                }
                
                // Sheet with iOS-style navigation bar for Research Studies
                .sheet(isPresented: $showingResearchStudies) {
                    ModalView(title: "Research Studies", isPresented: $showingResearchStudies) {
                        NavigationStack {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Active Research Studies")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .padding(.top)
                                
                                List {
                                    NavigationLink {
                                        DetailView(
                                            title: "Effects of Active Microbreak",
                                            content: "Risk factors associated with sedentary work and prolonged sitting time can be detrimental to office workers’ health and productivity. Recent literature introduced the concept of active microbreaks and their benefits to sedentary workers. The purpose of this study was to better define active microbreaks and to determine the evidence behind utilizing active microbreaks at work, through a qualitative synthesis of the literature in a systematic review. A comprehensive systematic search was conducted using primarily ergonomics, medicine and allied health databases, in addition to grey literature (CINAHL, Google Scholar, PubMed, and ScienceDirect) and respective ergonomics journals. Six interventional controlled trials (232 total participants) met the inclusion criteria and qualified for the inclusion in this review. The quality of the reviewed articles was deemed to be moderate to high according to the utilized assessment scales. The results of this review may support the use of short active microbreaks (2–3 minutes of light intensity exercises every 30 minutes) due to the observed physical and mental health benefits without negative impact on productivity in the workplace.",
                                            sourceLink: "https://www.tandfonline.com/doi/pdf/10.1080/23311916.2022.2026206"
                                        )
                                    } label: {
                                        ResearchStudyRow(
                                            title: "Effects of Active Microbreak",
                                            description: "How active microbreaks can positively impact the physical and mental well-being of office workers."
                                        )
                                    }
                                    .listRowBackground(Color.gray.opacity(0.2))
                                    .overlay(
                                        Rectangle()
                                            .frame(height: 0.5)
                                            .foregroundColor(.white.opacity(0.3))
                                            .padding(.horizontal, 5)
                                            .offset(y: 10),
                                        alignment: .bottom
                                    )
                                    
                                    NavigationLink {
                                        DetailView(
                                            title: "Workstation Setup Effects on Discomfort and Productivity",
                                            content: "Compare musculoskeletal discomfort, productivity, postural risks, and perceived fatigue for a sit-stand-walk intervention between two workstation configurations – one, individually customized for office workers according to ergonomic guidelines (Ergo-Fit); another, self-adjusted by office workers according to their preference (Self-Adjusted).",
                                            sourceLink: "https://www.sciencedirect.com/science/article/abs/pii/S0003687018307221"
                                        )
                                    } label: {
                                        ResearchStudyRow(
                                            title: "Workstation Setup Effects on Discomfort and Productivity",
                                            description: "This study compares two workstation setups—ergonomically-fitted (Ergo-Fit) and self-adjusted—during a 60-minute sit-stand-walk computer task."
                                        )
                                    }
                                    .listRowBackground(Color.gray.opacity(0.2))
                                    .overlay(
                                        Rectangle()
                                            .frame(height: 0.5)
                                            .foregroundColor(.white.opacity(0.3))
                                            .padding(.horizontal, 5)
                                            .offset(y: 10),
                                        alignment: .bottom
                                    )
                                    
                                    NavigationLink {
                                        DetailView(
                                            title: "Computer Terminal Work and The Benefit of Microbreaks",
                                            content: "Microbreaks are scheduled rest breaks taken to prevent the onset or progression of cumulative trauma disorders in the computerized workstation environment. The authors examined the benefit of microbreaks by investigating myoelectric signal (MES) behavior, perceived discomfort, and worker productivity while individuals performed their usual keying work. Participants were randomly assigned to one of three experimental groups. Each participant provided data from working sessions where they took no breaks, and from working sessions where they took breaks according to their group assignment: microbreaks at their own discretion (control), microbreaks at 20 min intervals, and microbreaks at 40 min intervals. Four main muscle areas were studied: the cervical extensors, the lumbar erector spinae, the upper trapezius/supraspinatus, and the wrist and finger extensors. The authors have previously shown that when computer workers remained seated at their workstation, the muscles performing sustained postural contractions displayed a cyclic trend in the mean frequency (MNF) of the MES (McLean et al., J. Electrophysiol. Kinesiol. 10 (1) (2000) 33). The data provided evidence (p < 0.05) that all microbreak protocols were associated with a higher frequency of MNF cycling at the wrist extensors, at the neck when microbreaks were taken by the control and 40 min protocol groups, and at the back when breaks were taken by the 20 and 40 min protocol groups. No significant change in the frequency of MNF cycling was noted at the shoulder. It was determined (p < 0.05) that microbreaks had a positive effect on reducing discomfort in all areas studied during computer terminal work, particularly when breaks were taken at 20 min intervals. Finally, microbreaks showed no evidence of a detrimental effect on worker productivity. The underlying cause of MNF cycling, and its relationship to the development of discomfort or cumulative trauma disorders remains to be determined.",
                                            sourceLink: "https://www.researchgate.net/publication/11945902_Computer_terminal_work_and_the_benefit_of_microbreaks"
                                        )
                                    } label: {
                                        ResearchStudyRow(
                                            title: "Computer Terminal Work and The Benefit of Microbreaks",
                                            description: "The efect of `microbreak protocols on muscle activation behavior"
                                        )
                                    }
                                    .listRowBackground(Color.gray.opacity(0.2))
                                }
                                .listStyle(PlainListStyle())
                                .scrollContentBackground(.hidden)
                                
                                Spacer()
                            }
                            .background(Color.black)
                            .navigationBarHidden(true)
                        }
                    }
                }
                
                // Sheet with iOS-style navigation bar for Devices
                .sheet(isPresented: $showingDevices) {
                    ModalView(title: "Devices", isPresented: $showingDevices) {
                        VStack(alignment: .leading, spacing: 15) {
                            Spacer()
                                .frame(height: 20)
                            
                            List {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("iPhone 15")
                                            .foregroundColor(.white)
                                        Text("Last synced: Today, 14:30")
                                            .font(.footnote)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    Spacer()
                                    Text("Connected")
                                        .foregroundColor(.green)
                                }
                                .listRowBackground(Color.gray.opacity(0.2))
                                .listRowSeparator(.visible)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 0.5)
                                        .foregroundColor(.white.opacity(0.3))
                                        .padding(.horizontal, 5)
                                        .offset(y: 10),
                                    alignment: .bottom
                                )
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Apple Watch Series 10")
                                            .foregroundColor(.white)
                                        Text("Last synced: Today, 14:25")
                                            .font(.footnote)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    Spacer()
                                    Text("Connected")
                                        .foregroundColor(.green)
                                }
                                .listRowBackground(Color.gray.opacity(0.2))
                                .listRowSeparator(.visible)
                            }
                            .listStyle(PlainListStyle())
                            .scrollContentBackground(.hidden)
                            
                            Text("These devices are currently linked to your account.")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                        }
                    }
                }
                
                // Sheet with iOS-style navigation bar for Apps
                .sheet(isPresented: $showingApps) {
                    AppsView(isPresented: $showingApps)
                }
                
                Spacer()
                Spacer()
            }
        }
        .navigationBarHidden(true)
        // Ubah onTapGesture agar tidak mengganggu tombol
        .background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissKeyboard()
                }
        )
    }
}

// Reusable modal view with iOS-style navigation bar
struct ModalView<Content: View>: View {
    let title: String
    @Binding var isPresented: Bool
    let content: Content
    
    init(title: String, isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.title = title
        self._isPresented = isPresented
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // iOS-style navigation bar
                ZStack {
                    Color(UIColor.darkGray).opacity(0.6)
                        .frame(height: 60)
                    
                    HStack {
                        Spacer()
                        Text(title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("Done")
                                .foregroundColor(.blue)
                                .padding(.trailing)
                        }
                    }
                }
                
                content
            }
        }
    }
}

// Helper components for notifications settings
struct NotificationSettingRow: View {
    let title: String
    @State var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
    }
}

// Helper component for research studies
struct ResearchStudyRow: View {
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.blue)
        }
        .padding(.vertical, 5)
    }
}

// Detail view for a research study
struct DetailView: View {
    let title: String
    let content: String
    let sourceLink: String
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                Text("Content")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                Text(content)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal)
                
                Text("Source")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                Link("Read more at the source", destination: URL(string: sourceLink)!)
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                    .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(title)
    }
}

// Apps view with swipe-to-delete and alert
struct AppsView: View {
    @Binding var isPresented: Bool
    
    @State private var apps: [(name: String, icon: String, access: String)] = [
        (name: "Health", icon: "heart.fill", access: "Heart Rate, Steps, Stand Hours"),
        (name: "Fitness", icon: "figure.walk", access: "Workouts, Activity Rings"),
        (name: "Calendar", icon: "calendar", access: "Events, Reminders")
    ]
    
    @State private var showDeleteAlert = false
    @State private var appToDelete: (name: String, icon: String, access: String)? = nil
    
    var body: some View {
        ModalView(title: "Apps", isPresented: $isPresented) {
            VStack(alignment: .leading, spacing: 15) {
                Text("Manage your connected applications here.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal)
                    .padding(.top)
                
                List {
                    ForEach(apps, id: \.name) { app in
                        HStack {
                            Image(systemName: app.icon)
                                .foregroundColor(.red)
                                .frame(width: 30, height: 30)
                            VStack(alignment: .leading) {
                                Text(app.name)
                                    .foregroundColor(.white)
                                Text("Access: \(app.access)")
                                    .font(.footnote)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .listRowBackground(Color.gray.opacity(0.2))
                        .overlay(
                            Rectangle()
                                .frame(width: 900.0, height: 0.5)
                                .foregroundColor(.white.opacity(0.3))
                                .offset(y: 30)
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                appToDelete = app
                                showDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                
                Text("You can view, add, or remove apps that have access to your data.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
            }
            .background(Color.black)
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Remove App"),
                    message: Text("Are you sure you want to remove \(appToDelete?.name ?? "this app") from your connected apps?"),
                    primaryButton: .destructive(Text("Remove")) {
                        if let app = appToDelete {
                            apps.removeAll { $0.name == app.name }
                        }
                        appToDelete = nil
                    },
                    secondaryButton: .cancel() {
                        appToDelete = nil
                    }
                )
            }
        }
    }
}

#Preview {
    ProfileView()
}
