//
//  TimerSetView.swift
//  CoreChal1
//
//  Created by Hendrik Nicolas Carlo on 24/03/25.
//

import SwiftUI

struct TimerSetView: View {
    @State private var hours: Int
    @State private var minutes: Int
    @State private var seconds: Int
    @State private var breakMinutes: Int
    @State private var tempHours: Int = 0
    @State private var tempMinutes: Int = 5
    @State private var tempSeconds: Int = 0
    @State private var tempBreakMinutes: Int = 5
    @State private var showTimePicker: Bool = false
    @State private var showBreakPicker: Bool = false
    
    // Ganti dua state alert dengan satu state menggunakan enum
    enum AlertType {
        case error
        case none
    }
    @State private var alertType: AlertType = .none
    @State private var showSuccessNotification: Bool = false // State untuk notifikasi sukses
    
    @State private var selectedLabel: String = "None"
    @State private var labels: [String] = ["None", "Work", "Study", "Exercise"]
    @State private var showLabelPicker: Bool = false
    @State private var showAddLabelModal: Bool = false
    @State private var newLabel: String = ""
    
    @State private var selectedTimerEndOption: String
    @State private var showTimerEndPicker: Bool = false
    private let timerEndOptions = ["Vibrate", "Notification Only", "Ringing"]
    
    @State private var vibrateOn: Bool = true
    
    init() {
        // Ambil nilai dari UserDefaults
        let savedHours = UserDefaults.standard.integer(forKey: "timerHours")
        let savedMinutes = UserDefaults.standard.integer(forKey: "timerMinutes")
        let savedSeconds = UserDefaults.standard.integer(forKey: "timerSeconds")
        let savedBreakMinutes = UserDefaults.standard.integer(forKey: "breakMinutes")
        
        // Jika UserDefaults belum memiliki nilai (aplikasi baru diunduh), set default work time ke 5 menit
        if savedHours == 0 && savedMinutes == 0 && savedSeconds == 0 {
            _hours = State(initialValue: 0)
            _minutes = State(initialValue: 5) // Default 5 menit
            _seconds = State(initialValue: 0)
            // Simpan default ke UserDefaults
            UserDefaults.standard.set(0, forKey: "timerHours")
            UserDefaults.standard.set(5, forKey: "timerMinutes")
            UserDefaults.standard.set(0, forKey: "timerSeconds")
        } else {
            _hours = State(initialValue: savedHours)
            _minutes = State(initialValue: savedMinutes)
            _seconds = State(initialValue: savedSeconds)
        }
        
        // Set default break ke 5 menit kalau belum ada
        if savedBreakMinutes == 0 {
            _breakMinutes = State(initialValue: 5)
            UserDefaults.standard.set(5, forKey: "breakMinutes")
        } else {
            _breakMinutes = State(initialValue: savedBreakMinutes)
        }
        
        if let savedLabels = UserDefaults.standard.array(forKey: "labels") as? [String] {
            _labels = State(initialValue: savedLabels)
        }
        
        let savedTimerEndOption = UserDefaults.standard.string(forKey: "timerEndOption") ?? "Vibrate"
        _selectedTimerEndOption = State(initialValue: savedTimerEndOption)
    }
    
    var body: some View {
        ZStack {
            Color.primaryApp
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Timer")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.leading, 15)
                
                Spacer()
                
                VStack(spacing: 5) {
                    Button(action: {
                        tempHours = hours
                        tempMinutes = minutes
                        tempSeconds = seconds
                        showTimePicker.toggle()
                    }) {
                        Text(String(format: "%02d:%02d:%02d", hours, minutes, seconds))
                            .font(.system(size: 60, weight: .light, design: .default))
                            .foregroundColor(.white)
                    }
                    
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                    
                    Button(action: {
                        tempBreakMinutes = breakMinutes
                        showBreakPicker.toggle()
                    }) {
                        HStack {
                            Text("\(breakMinutes)m break")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.top, 30)
                .padding(.bottom, 13)
                .padding(.horizontal)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                
                Button(action: {
                    // Hitung total waktu dalam detik
                    let totalSeconds = (hours * 3600) + (minutes * 60) + seconds
                    print("Total seconds: \(totalSeconds)") // Debugging
                    
                    // Validasi: Pastikan total waktu minimal 1 detik
                    if totalSeconds < 1 {
                        print("Timer invalid, setting alertType to error") // Debugging
                        alertType = .error // Set tipe alert ke error
                    } else {
                        print("Timer valid, saving to UserDefaults") // Debugging
                        // Simpan ke UserDefaults
                        UserDefaults.standard.set(hours, forKey: "timerHours")
                        UserDefaults.standard.set(minutes, forKey: "timerMinutes")
                        UserDefaults.standard.set(seconds, forKey: "timerSeconds")
                        UserDefaults.standard.set(breakMinutes, forKey: "breakMinutes")
                        UserDefaults.standard.set(selectedLabel, forKey: "timerLabel")
                        UserDefaults.standard.set(selectedTimerEndOption, forKey: "timerEndOption")
                        
                        print("Timer set: \(hours)h \(minutes)m \(seconds)s, Break: \(breakMinutes)m, Label: \(selectedLabel), When Timer Ends: \(selectedTimerEndOption)")
                        
                        // Kirim notifikasi ke TimerView
                        NotificationCenter.default.post(name: NSNotification.Name("TimerSetNotification"), object: nil)
                        
                        print("Showing success notification") // Debugging
                        withAnimation {
                            showSuccessNotification = true // Tampilkan notifikasi sukses
                        }
                        // Sembunyikan notifikasi setelah 2 detik
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSuccessNotification = false
                            }
                        }
                    }
                }) {
                    Text("Set")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal)
                .alert(isPresented: Binding<Bool>(
                    get: { alertType != .none },
                    set: { _ in alertType = .none }
                )) {
                    print("Showing alert, type: \(alertType)") // Debugging
                    switch alertType {
                    case .error:
                        return Alert(
                            title: Text("Invalid Timer"),
                            message: Text("Please set the timer to at least 1 second."),
                            dismissButton: .default(Text("OK"))
                        )
                    case .none:
                        return Alert(title: Text("")) // Tidak akan dipanggil
                    }
                }
                
                VStack(spacing: 0) {
                    Button(action: {
                        showLabelPicker.toggle()
                    }) {
                        HStack {
                            Text("Label")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Text(selectedLabel)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.2))
                    }
                    
                    Button(action: {
                        showTimerEndPicker.toggle()
                    }) {
                        HStack {
                            Text("When Timer Ends")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Text(selectedTimerEndOption)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.2))
                    }
                    
                    HStack {
                        Text("Add as widget")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Toggle("", isOn: $vibrateOn)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.2))
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                
                Spacer()
            }
            
            // Success Notification
            if showSuccessNotification {
                VStack {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                        Text("Timer Set Successfully!")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.green.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                    .transition(.opacity)
                }
                .position(x: UIScreen.main.bounds.width / 2, y: 100) // Posisi di atas layar
            }
            
            // Time Picker
            if showTimePicker {
                Color.primaryApp.opacity(0.7)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .environment(\.colorScheme, .dark)
                
                VStack {
                    HStack {
                        Button("Cancel") {
                            showTimePicker = false
                        }
                        .foregroundColor(.red)
                        
                        Spacer()
                        
                        Button("Done") {
                            hours = tempHours
                            minutes = tempMinutes
                            seconds = tempSeconds
                            showTimePicker = false
                        }
                        .foregroundColor(.blue.opacity(0.8))
                    }
                    .padding()
                    
                    HStack(spacing: 0) {
                        Picker("Hours", selection: $tempHours) {
                            ForEach(0..<9) { hour in
                                Text("\(hour)h")
                                    .tag(hour)
                                    .foregroundColor(.white)
                            }
                        }
                        .pickerStyle(.wheel)
                        
                        Picker("Minutes", selection: $tempMinutes) {
                            ForEach(0..<60) { minute in
                                Text("\(minute)m")
                                    .tag(minute)
                                    .foregroundColor(.white)
                            }
                        }
                        .pickerStyle(.wheel)
                        
                        Picker("Seconds", selection: $tempSeconds) {
                            ForEach(0..<60) { second in
                                Text("\(second)s")
                                    .tag(second)
                                    .foregroundColor(.white)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding()
                .environment(\.colorScheme, .dark)
            }
            
            // Break Picker
            if showBreakPicker {
                Color.primaryApp.opacity(0.7)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .environment(\.colorScheme, .dark)
                
                VStack {
                    HStack {
                        Button("Cancel") {
                            showBreakPicker = false
                        }
                        .foregroundColor(.red)
                        
                        Spacer()
                        
                        Button("Done") {
                            breakMinutes = tempBreakMinutes
                            showBreakPicker = false
                        }
                        .foregroundColor(.blue.opacity(0.8))
                    }
                    .padding()
                    
                    Picker("Break Duration", selection: $tempBreakMinutes) {
                        ForEach(1..<16) { minute in
                            Text("\(minute)m")
                                .tag(minute)
                                .foregroundColor(.white)
                        }
                    }
                    .pickerStyle(.wheel)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding()
                .environment(\.colorScheme, .dark)
            }
            
            // Label Picker
            if showLabelPicker {
                Color.primaryApp.opacity(0.7)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .environment(\.colorScheme, .dark)
                
                VStack {
                    HStack {
                        Button("Cancel") {
                            showLabelPicker = false
                        }
                        .foregroundColor(.red)
                        
                        Spacer()
                        
                        Button("Done") {
                            showLabelPicker = false
                        }
                        .foregroundColor(.blue.opacity(0.8))
                    }
                    .padding()
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(labels, id: \.self) { label in
                                HStack {
                                    Text(label)
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .onTapGesture {
                                            selectedLabel = label
                                            showLabelPicker = false
                                        }
                                    
                                    Spacer()
                                    
                                    if label != "None" {
                                        Button(action: {
                                            if let index = labels.firstIndex(of: label) {
                                                labels.remove(at: index)
                                                if selectedLabel == label {
                                                    selectedLabel = "None"
                                                }
                                                UserDefaults.standard.set(labels, forKey: "labels")
                                            }
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .background(selectedLabel == label ? Color.gray.opacity(0.3) : Color.clear)
                            }
                        }
                    }
                    .frame(height: 200)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Button(action: {
                        showLabelPicker = false
                        showAddLabelModal = true
                    }) {
                        Text("Add New Label")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.blue.opacity(0.8))
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding()
                .environment(\.colorScheme, .dark)
            }
            
            // Add Label Modal
            if showAddLabelModal {
                Color.primaryApp.opacity(0.7)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .environment(\.colorScheme, .dark)
                
                VStack {
                    HStack {
                        Button("Cancel") {
                            newLabel = ""
                            showAddLabelModal = false
                        }
                        .foregroundColor(.red)
                        
                        Spacer()
                        
                        Button("Done") {
                            if !newLabel.isEmpty && !labels.contains(newLabel) {
                                labels.append(newLabel)
                                selectedLabel = newLabel
                                UserDefaults.standard.set(labels, forKey: "labels")
                            }
                            newLabel = ""
                            showAddLabelModal = false
                        }
                        .foregroundColor(.blue.opacity(0.8))
                    }
                    .padding()
                    
                    TextField("Enter new label", text: $newLabel)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding()
                .environment(\.colorScheme, .dark)
            }
            
            // When Timer Ends Picker Modal
            if showTimerEndPicker {
                Color.primaryApp.opacity(0.7)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .environment(\.colorScheme, .dark)
                
                VStack {
                    HStack {
                        Button("Cancel") {
                            showTimerEndPicker = false
                        }
                        .foregroundColor(.red)
                        
                        Spacer()
                        
                        Button("Done") {
                            showTimerEndPicker = false
                        }
                        .foregroundColor(.blue.opacity(0.8))
                    }
                    .padding()
                    
                    Picker("When Timer Ends", selection: $selectedTimerEndOption) {
                        ForEach(timerEndOptions, id: \.self) { option in
                            Text(option)
                                .tag(option)
                                .foregroundColor(.white)
                        }
                    }
                    .pickerStyle(.wheel)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding()
                .environment(\.colorScheme, .dark)
            }
        }
    }
}

#Preview {
    TimerSetView()
}
