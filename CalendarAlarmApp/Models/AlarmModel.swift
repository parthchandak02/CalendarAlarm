//
//  AlarmModel.swift
//  CalendarAlarmApp
//
//  Created by Parth Chandak on 8/4/25.
//

import ActivityKit
import AlarmKit
import Combine
import Foundation
import SwiftUI

// MARK: - Alarm Data Model (Following AlarmKit countdown pattern exactly)

struct AlarmData: Identifiable, Codable {
    let id: UUID
    var title: String
    var isEnabled: Bool
    var countdownMinutes: Int // Total countdown duration in minutes
    var soundName: String
    var snoozeEnabled: Bool
    var preAlertMinutes: Int // Minutes before final alert (like 10 min warning)
    var postAlertMinutes: Int // Minutes to keep alert active after countdown ends

    init(id: UUID = UUID(),
         title: String = "Timer Alarm",
         isEnabled: Bool = true,
         countdownMinutes: Int = 60, // Default 1 hour countdown
         soundName: String = "Chime",
         snoozeEnabled: Bool = true,
         preAlertMinutes: Int = 10, // 10 min warning before countdown ends
         postAlertMinutes: Int = 5) { // 5 min alert duration after countdown ends
        self.id = id
        self.title = title
        self.isEnabled = isEnabled
        self.countdownMinutes = countdownMinutes
        self.soundName = soundName
        self.snoozeEnabled = snoozeEnabled
        self.preAlertMinutes = preAlertMinutes
        self.postAlertMinutes = postAlertMinutes
    }

    var durationString: String {
        if countdownMinutes < 60 {
            return "\(countdownMinutes) min"
        } else {
            let hours = countdownMinutes / 60
            let minutes = countdownMinutes % 60
            if minutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(minutes)m"
            }
        }
    }

    // Calculate countdown duration for AlarmKit (following docs exactly)
    var alarmKitCountdownDuration: TimeInterval {
        TimeInterval(countdownMinutes * 60)
    }
}

// MARK: - Weekday Enum

enum Weekday: Int, CaseIterable, Codable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var name: String {
        switch self {
        case .sunday: "Sunday"
        case .monday: "Monday"
        case .tuesday: "Tuesday"
        case .wednesday: "Wednesday"
        case .thursday: "Thursday"
        case .friday: "Friday"
        case .saturday: "Saturday"
        }
    }

    var shortName: String {
        switch self {
        case .sunday: "Sun"
        case .monday: "Mon"
        case .tuesday: "Tue"
        case .wednesday: "Wed"
        case .thursday: "Thu"
        case .friday: "Fri"
        case .saturday: "Sat"
        }
    }
}

// MARK: - AlarmKit Metadata (iOS 26 Beta Compatible)
// iOS 26 AlarmKit requires specific concurrency patterns for Swift 6

// Empty AlarmMetadata implementation for iOS 26 beta
struct EmptyAlarmMetadata: Sendable {
    // Completely empty for iOS 26 beta compatibility
    init() {}
}

// Separate extension to handle AlarmMetadata conformance with @preconcurrency
extension EmptyAlarmMetadata: @preconcurrency AlarmMetadata {}

// Use empty metadata to avoid iOS 26 beta protocol conformance issues
typealias AlarmAppMetadata = EmptyAlarmMetadata

// MARK: - ActivityKit Live Activities Support (iOS 26)
// ActivityAttributes for Live Activities integration following successful examples
struct AlarmCountdownAttributes: ActivityAttributes {
    public typealias AlarmCountdownStatus = ContentState

    public struct ContentState: Codable, Hashable {
        var alarmTitle: String
        var remainingTime: ClosedRange<Date>
        var isPaused: Bool
    }

    var alarmId: String
    var originalDuration: Int // Duration in minutes
}

// MARK: - Alarm Store Manager

@MainActor
class AlarmStore: ObservableObject {
    @Published var alarms: [AlarmData] = []

    private let userDefaults = UserDefaults.standard
    private let alarmsKey = "SavedAlarms"

    init() {
        loadAlarms()
    }

    // MARK: - CRUD Operations

    func addAlarm(_ alarm: AlarmData) {
        alarms.append(alarm)
        saveAlarms()

        if alarm.isEnabled {
            Task {
                await scheduleAlarmWithAlarmKit(alarm)
            }
        }
    }

    func updateAlarm(_ alarm: AlarmData) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index] = alarm
            saveAlarms()

            Task {
                cancelAlarmWithAlarmKit(alarm.id)
                if alarm.isEnabled {
                    await scheduleAlarmWithAlarmKit(alarm)
                }
            }
        }
    }

    func deleteAlarm(_ alarm: AlarmData) {
        alarms.removeAll { $0.id == alarm.id }
        saveAlarms()

        cancelAlarmWithAlarmKit(alarm.id)
    }

    func toggleAlarm(_ alarm: AlarmData) {
        var updatedAlarm = alarm
        updatedAlarm.isEnabled.toggle()
        updateAlarm(updatedAlarm)
    }

    // MARK: - Persistence

    private func saveAlarms() {
        if let encoded = try? JSONEncoder().encode(alarms) {
            userDefaults.set(encoded, forKey: alarmsKey)
        }
    }

    private func loadAlarms() {
        if let data = userDefaults.data(forKey: alarmsKey),
           let decoded = try? JSONDecoder().decode([AlarmData].self, from: data) {
            alarms = decoded
        }
    }

    // MARK: - AlarmKit Integration (Following docs pattern exactly)

    private func scheduleAlarmWithAlarmKit(_ alarm: AlarmData) async {
        do {
            // For iOS 26 beta, use metadata type parameter
            typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<AlarmAppMetadata>

            // Create buttons exactly as shown in docs
            let stopButton = AlarmButton(
                text: "Dismiss",
                textColor: .white,
                systemImageName: "stop.circle"
            )

            let repeatButton = AlarmButton(
                text: "Repeat",
                textColor: .white,
                systemImageName: "repeat.circle"
            )

            // Create alert presentation (following docs pattern)
            let alertPresentation = AlarmPresentation.Alert(
                title: LocalizedStringResource(stringLiteral: alarm.title),
                stopButton: stopButton,
                secondaryButton: alarm.snoozeEnabled ? repeatButton : nil,
                secondaryButtonBehavior: .countdown
            )

            // Create pause button for countdown
            let pauseButton = AlarmButton(
                text: "Pause",
                textColor: .green,
                systemImageName: "pause"
            )

            // Create countdown presentation
            let countdownPresentation = AlarmPresentation.Countdown(
                title: LocalizedStringResource(stringLiteral: alarm.title),
                pauseButton: pauseButton
            )

            // Create resume button for paused state
            let resumeButton = AlarmButton(
                text: "Resume",
                textColor: .green,
                systemImageName: "play"
            )

            // Create paused presentation
            let pausedPresentation = AlarmPresentation.Paused(
                title: LocalizedStringResource("Paused"),
                resumeButton: resumeButton
            )

            // Create alarm attributes with all presentations (following docs)
            let metadata = AlarmAppMetadata() // Empty metadata for iOS 26 beta
            let attributes = AlarmAttributes<AlarmAppMetadata>(
                presentation: AlarmPresentation(
                    alert: alertPresentation,
                    countdown: countdownPresentation,
                    paused: pausedPresentation
                ),
                metadata: metadata,
                tintColor: Color.orange
            )

            // Create sound configuration (following official Apple docs)
            // Note: Sound will be configured in AlarmConfiguration.init

            // Create alarm configuration with countdown duration (following official Apple AlarmKit docs)
            let alarmConfiguration = AlarmManager.AlarmConfiguration.timer(
                duration: alarm.alarmKitCountdownDuration,
                attributes: attributes,
                stopIntent: nil, // Optional app intent for stop action
                secondaryIntent: nil, // Optional app intent for secondary action  
                sound: .default // Using default system alarm sound
            )

            _ = try await AlarmManager.shared.schedule(id: alarm.id, configuration: alarmConfiguration)

            print("✅ Scheduled AlarmKit countdown: '\(alarm.title)' - \(alarm.durationString)")
            
            // START LIVE ACTIVITY for countdown (following successful examples)
            await startLiveActivity(for: alarm)

        } catch {
            print("❌ Failed to schedule AlarmKit countdown: \(error)")
        }
    }

    private func getSoundIcon(for soundName: String) -> String {
        switch soundName.lowercased() {
        case "bell": "bell"
        case "alarm": "alarm"
        case "horn": "horn.blast"
        case "chime": "bell.circle"
        default: "clock"
        }
    }

    private func cancelAlarmWithAlarmKit(_ alarmId: UUID) {
        Task {
            try? AlarmManager.shared.cancel(id: alarmId)
        }
    }
    
    // MARK: - Live Activity Management (ActivityKit)
    // Following successful examples from web search
    
    private func startLiveActivity(for alarm: AlarmData) async {
        do {
            // Create countdown attributes (following web examples pattern)
            let attributes = AlarmCountdownAttributes(
                alarmId: alarm.id.uuidString,
                originalDuration: alarm.countdownMinutes
            )
            
            // Create initial content state with countdown time range
            let endTime = Date().addingTimeInterval(TimeInterval(alarm.countdownMinutes * 60))
            let contentState = AlarmCountdownAttributes.ContentState(
                alarmTitle: alarm.title,
                remainingTime: Date()...endTime,
                isPaused: false
            )
            
            // Request Live Activity (following ActivityKit examples)
            let activity = try Activity<AlarmCountdownAttributes>.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
            
            print("🎯 Started Live Activity for alarm: \(activity.id)")
            
        } catch {
            print("❌ Failed to start Live Activity: \(error)")
        }
    }
}
