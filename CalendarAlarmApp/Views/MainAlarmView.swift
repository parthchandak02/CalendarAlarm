//
//  MainAlarmView.swift
//  CalendarAlarmApp
//
//  Created by Parth Chandak on 8/4/25.
//

import AlarmKit
import SwiftUI

struct MainAlarmView: View {
    @StateObject private var alarmStore = AlarmStore()
    @State private var isAddingAlarm = false
    @State private var editingAlarm: AlarmData?

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    if alarmStore.alarms.isEmpty {
                        emptyStateView
                    } else {
                        alarmListView
                    }
                }
            }
            .navigationTitle("Alarms")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isAddingAlarm = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }

                if !alarmStore.alarms.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingAlarm) {
            AddEditAlarmView(alarmStore: alarmStore)
        }
        .sheet(item: $editingAlarm) { alarm in
            AddEditAlarmView(alarmStore: alarmStore, editingAlarm: alarm)
        }
    }

    // MARK: - Empty State View

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "alarm")
                .font(.system(size: 80))
                .foregroundColor(.gray)

            Text("No Alarms")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.white)

            Text("Add an alarm to get started")
                .font(.body)
                .foregroundColor(.gray)

            Spacer()
        }
    }

    // MARK: - Alarm List View

    private var alarmListView: some View {
        List {
            ForEach(alarmStore.alarms) { alarm in
                AlarmRowView(
                    alarm: alarm,
                    onToggle: {
                        alarmStore.toggleAlarm(alarm)
                    },
                    onEdit: {
                        editingAlarm = alarm
                    }
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .onDelete(perform: deleteAlarms)
        }
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
    }

    // MARK: - Helper Methods

    private func deleteAlarms(offsets: IndexSet) {
        for index in offsets {
            alarmStore.deleteAlarm(alarmStore.alarms[index])
        }
    }
}

// MARK: - Alarm Row View

struct AlarmRowView: View {
    let alarm: AlarmData
    let onToggle: () -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                // Duration display (following AlarmKit countdown pattern)
                Text(alarm.durationString)
                    .font(.system(size: 50, weight: .thin, design: .default))
                    .foregroundColor(alarm.isEnabled ? .white : .gray)
                    .minimumScaleFactor(0.5) // Allow text to scale down to 50% if needed
                    .lineLimit(1) // Keep it on one line
                    .scaledToFit() // Scale to fit available space

                // Title and countdown info
                HStack(spacing: 8) {
                    Text(alarm.title)
                        .font(.body)
                        .foregroundColor(alarm.isEnabled ? .white : .gray)

                    Text("•")
                        .foregroundColor(.gray)

                    Text("Alarm")
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
            .layoutPriority(1) // Give the text section higher priority

            Spacer()

            // Toggle switch
            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { _ in onToggle() }
            ))
            .toggleStyle(SwitchToggleStyle(tint: .orange))
            .fixedSize() // Prevent the toggle from being compressed
        }
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
    }
}

// MARK: - Preview

#Preview {
    MainAlarmView()
}
