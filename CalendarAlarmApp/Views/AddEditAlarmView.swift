//
//  AddEditAlarmView.swift
//  CalendarAlarmApp
//
//  Created by Parth Chandak on 8/4/25.
//

import SwiftUI

struct AddEditAlarmView: View {
    @ObservedObject var alarmStore: AlarmStore
    @Environment(\.dismiss) private var dismiss

    // Editing state
    let editingAlarm: AlarmData?

    // Form state (following AlarmKit countdown pattern)
    @State private var title = "Title"
    @State private var countdownMinutes = 60
    @State private var preAlertMinutes = 10
    @State private var postAlertMinutes = 5
    @State private var soundName = "Chime"
    @State private var snoozeEnabled = true

    // UI state
    @State private var showingSoundPicker = false

    init(alarmStore: AlarmStore, editingAlarm: AlarmData? = nil) {
        self.alarmStore = alarmStore
        self.editingAlarm = editingAlarm

        if let alarm = editingAlarm {
            _title = State(initialValue: alarm.title)
            _countdownMinutes = State(initialValue: alarm.countdownMinutes)
            _preAlertMinutes = State(initialValue: alarm.preAlertMinutes)
            _postAlertMinutes = State(initialValue: alarm.postAlertMinutes)
            _soundName = State(initialValue: alarm.soundName)
            _snoozeEnabled = State(initialValue: alarm.snoozeEnabled)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Countdown Duration Picker
                    countdownPickerSection

                    // Settings List
                    settingsList
                }
            }
            .navigationTitle(editingAlarm == nil ? "Add Alarm" : "Edit Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAlarm()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .sheet(isPresented: $showingSoundPicker) {
            SoundPickerView(selectedSound: $soundName)
        }
    }

    // MARK: - Countdown Duration Picker Section

    private var countdownPickerSection: some View {
        VStack(spacing: 20) {
            Text("Countdown Duration")
                .font(.headline)
                .foregroundColor(.white)

            HStack {
                // Hours picker
                Picker("Hours", selection: Binding(
                    get: { countdownMinutes / 60 },
                    set: { countdownMinutes = $0 * 60 + (countdownMinutes % 60) }
                )) {
                    ForEach(0 ..< 24) { hour in
                        Text("\(hour)").tag(hour)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 80)
                .clipped()

                Text("h")
                    .foregroundColor(.white)

                // Minutes picker
                Picker("Minutes", selection: Binding(
                    get: { countdownMinutes % 60 },
                    set: { countdownMinutes = (countdownMinutes / 60) * 60 + $0 }
                )) {
                    ForEach(0 ..< 60) { minute in
                        Text("\(minute)").tag(minute)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 80)
                .clipped()

                Text("m")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }

    // MARK: - Settings List (Following AlarmKit countdown pattern)

    private var settingsList: some View {
        List {
            // Title Section
            Section {
                HStack {
                    Text("Title")
                        .foregroundColor(.white)
                    Spacer()
                    TextField("Title", text: $title)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.gray)
                }
            }
            .listRowBackground(Color.gray.opacity(0.1))

            // Sound Section
            Section {
                Button(action: {
                    showingSoundPicker = true
                }) {
                    HStack {
                        Text("Sound")
                            .foregroundColor(.white)
                        Spacer()
                        Text(soundName)
                            .foregroundColor(.gray)
                    }
                }
            }
            .listRowBackground(Color.gray.opacity(0.1))

            // Snooze Section
            Section {
                Toggle("Snooze", isOn: $snoozeEnabled)
                    .foregroundColor(.white)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
            }
            .listRowBackground(Color.gray.opacity(0.1))

            // Alert Settings Section (Compact 2-row layout)
            Section(header: Text("Alert Settings").foregroundColor(.gray)) {
                // Pre-Alert Row
                HStack {
                    Text("Pre-Alert")
                        .foregroundColor(.white)
                    Spacer()
                    Picker("", selection: $preAlertMinutes) {
                        ForEach([5, 10, 15, 30], id: \.self) { minutes in
                            Text("\(minutes) min").tag(minutes)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Alert Duration Row
                HStack {
                    Text("Duration")
                        .foregroundColor(.white)
                    Spacer()
                    Picker("", selection: $postAlertMinutes) {
                        ForEach([1, 5, 10, 15], id: \.self) { minutes in
                            Text("\(minutes) min").tag(minutes)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            .listRowBackground(Color.gray.opacity(0.1))
        }
        .listStyle(InsetGroupedListStyle())
        .scrollContentBackground(.hidden)
    }

    // MARK: - Actions

    private func saveAlarm() {
        let alarm = AlarmData(
            title: title.isEmpty ? "Title" : title,
            isEnabled: true,
            countdownMinutes: max(1, countdownMinutes), // Ensure at least 1 minute
            soundName: soundName,
            snoozeEnabled: snoozeEnabled,
            preAlertMinutes: preAlertMinutes,
            postAlertMinutes: postAlertMinutes
        )

        if let editingAlarm {
            var updatedAlarm = alarm
            // Preserve the existing enabled state and ID
            updatedAlarm = AlarmData(
                title: title.isEmpty ? "Title" : title,
                isEnabled: editingAlarm.isEnabled,
                countdownMinutes: max(1, countdownMinutes),
                soundName: soundName,
                snoozeEnabled: snoozeEnabled,
                preAlertMinutes: preAlertMinutes,
                postAlertMinutes: postAlertMinutes
            )
            alarmStore.updateAlarm(editingAlarm)
        } else {
            alarmStore.addAlarm(alarm)
        }

        dismiss()
    }
}

// MARK: - Duration Quick Selection View

struct DurationQuickSelectView: View {
    @Binding var countdownMinutes: Int
    @Environment(\.dismiss) private var dismiss

    private let presetDurations = [
        (title: "5 minutes", minutes: 5),
        (title: "10 minutes", minutes: 10),
        (title: "15 minutes", minutes: 15),
        (title: "30 minutes", minutes: 30),
        (title: "1 hour", minutes: 60),
        (title: "2 hours", minutes: 120),
        (title: "4 hours", minutes: 240),
        (title: "8 hours", minutes: 480)
    ]

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            List {
                ForEach(presetDurations, id: \.minutes) { preset in
                    Button(action: {
                        countdownMinutes = preset.minutes
                        dismiss()
                    }) {
                        HStack {
                            Text(preset.title)
                                .foregroundColor(.white)
                            Spacer()
                            if countdownMinutes == preset.minutes {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.1))
                }
            }
            .listStyle(InsetGroupedListStyle())
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Duration Presets")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Sound Picker View

struct SoundPickerView: View {
    @Binding var selectedSound: String
    @Environment(\.dismiss) private var dismiss

    private let availableSounds = [
        "Chime", "Bell", "Alarm", "Horn", "Digital", "Classic", "Radar", "Sci-Fi", "Signal"
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                List {
                    ForEach(availableSounds, id: \.self) { sound in
                        Button(action: {
                            selectedSound = sound
                            dismiss()
                        }) {
                            HStack {
                                Text(sound)
                                    .foregroundColor(.white)
                                Spacer()
                                if selectedSound == sound {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        .listRowBackground(Color.gray.opacity(0.1))
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Sound")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AddEditAlarmView(alarmStore: AlarmStore())
}
