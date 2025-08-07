//
//  AlarmModel.swift
//  CalendarAlarmApp
//
//  Created by Parth Chandak on 8/4/25.
//

import ActivityKit
import AlarmKit
import Combine
import EventKit
import Foundation
import SwiftUI

// MARK: - Alarm Data Model (Using AlarmKit schedule-based alarms for future dates)

struct AlarmData: Identifiable, Codable {
    let id: UUID
    var title: String
    var isEnabled: Bool
    var alarmDate: Date // Specific date and time for the alarm
    var soundName: String
    var snoozeEnabled: Bool
    var preAlertMinutes: Int // Minutes before final alert (like 10 min warning)
    var postAlertMinutes: Int // Minutes to keep alert active after countdown ends
    var isFromCalendar: Bool = false // Flag to identify calendar-imported alarms
    var calendarEventId: String? = nil // Original calendar event ID for tracking
    var calendarTitle: String? = nil // Name of the source calendar

    init(id: UUID = UUID(),
         title: String = "Alarm",
         isEnabled: Bool = true,
         alarmDate: Date = Date().addingTimeInterval(3600), // Default 1 hour from now
         soundName: String = "Chime",
         snoozeEnabled: Bool = true,
         preAlertMinutes: Int = 10, // 10 min warning before alarm
         postAlertMinutes: Int = 5, // 5 min alert duration after alarm fires
         isFromCalendar: Bool = false,
         calendarEventId: String? = nil,
         calendarTitle: String? = nil) {
        self.id = id
        self.title = title
        self.isEnabled = isEnabled
        self.alarmDate = alarmDate
        self.soundName = soundName
        self.snoozeEnabled = snoozeEnabled
        self.preAlertMinutes = preAlertMinutes
        self.postAlertMinutes = postAlertMinutes
        self.isFromCalendar = isFromCalendar
        self.calendarEventId = calendarEventId
        self.calendarTitle = calendarTitle
    }

    var durationString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none

        // If alarm is today, show just time
        if Calendar.current.isDate(alarmDate, inSameDayAs: Date()) {
            return formatter.string(from: alarmDate)
        } else {
            // If alarm is future date, show date + time
            formatter.dateStyle = .short
            return formatter.string(from: alarmDate)
        }
    }

    // Check if alarm is in the past
    var isPastDue: Bool {
        alarmDate < Date()
    }
    
    // Convenience initializer for calendar events
    init(from calendarEvent: CalendarAlarmEvent) {
        self.id = UUID(uuidString: calendarEvent.id) ?? UUID()
        self.title = calendarEvent.title
        self.isEnabled = true
        self.alarmDate = calendarEvent.alarmDate
        self.soundName = "Chime"
        self.snoozeEnabled = true
        self.preAlertMinutes = 2 // Short pre-alert for calendar events
        self.postAlertMinutes = 5
        self.isFromCalendar = true
        self.calendarEventId = calendarEvent.originalEventId
        self.calendarTitle = calendarEvent.calendarTitle
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

// AlarmMetadata implementation following official Apple documentation pattern
// Using nonisolated to avoid actor isolation issues with Sendable conformance
nonisolated struct EmptyAlarmMetadata: AlarmMetadata, Sendable, Codable {
    // Following exact pattern from Apple's CookingData example
    // Simple title property to satisfy AlarmMetadata requirements
    let title: String

    nonisolated init(title: String = "Alarm") {
        self.title = title
    }
}

// Use empty metadata to avoid iOS 26 beta protocol conformance issues
typealias AlarmAppMetadata = EmptyAlarmMetadata

// MARK: - AlarmKit Live Activities (iOS 26)

// AlarmKit handles Live Activities automatically - no manual ActivityAttributes needed
// Manual ActivityKit integration commented out to prevent conflicts with AlarmKit system Live Activities

/*
 // Legacy manual ActivityKit code - replaced by AlarmKit automatic Live Activities
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
 */

// MARK: - Alarm Store Manager

@MainActor
class AlarmStore: ObservableObject {
    @Published var alarms: [AlarmData] = []
    @Published var calendarService = CalendarService()

    private let userDefaults = UserDefaults.standard
    private let alarmsKey = "SavedAlarms"
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadAlarms()
        setupCalendarIntegration()
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

            // Create snooze button for schedule-based alarms
            let snoozeButton = alarm.snoozeEnabled ? AlarmButton(
                text: "Snooze",
                textColor: .white,
                systemImageName: "clock.badge.questionmark"
            ) : nil

            // Create alert presentation for schedule-based alarms (following official docs)
            let alertPresentation = AlarmPresentation.Alert(
                title: LocalizedStringResource(stringLiteral: alarm.title),
                stopButton: stopButton,
                secondaryButton: snoozeButton,
                secondaryButtonBehavior: alarm.snoozeEnabled ? .countdown : nil
            )

            // Create countdown presentation (required for countdown-based alarms)
            let pauseButton = AlarmButton(
                text: "Pause",
                textColor: .red,
                systemImageName: "pause"
            )

            let countdownPresentation = AlarmPresentation.Countdown(
                title: LocalizedStringResource(stringLiteral: alarm.title),
                pauseButton: pauseButton
            )

            // Create paused presentation
            let resumeButton = AlarmButton(
                text: "Resume",
                textColor: .red,
                systemImageName: "play"
            )

            let pausedPresentation = AlarmPresentation.Paused(
                title: LocalizedStringResource(stringLiteral: "Paused"),
                resumeButton: resumeButton
            )

            // Create alarm attributes with all presentations (countdown-based alarms)
            let metadata = AlarmAppMetadata(title: alarm.title) // Pass actual alarm title
            let attributes = AlarmAttributes<AlarmAppMetadata>(
                presentation: AlarmPresentation(
                    alert: alertPresentation,
                    countdown: countdownPresentation,
                    paused: pausedPresentation
                ),
                metadata: metadata,
                tintColor: Color.red
            )

            // Create sound configuration (following official Apple docs)
            // Note: Sound will be configured in AlarmConfiguration.init

            // Calculate countdown duration from current time to alarm time (proper AlarmKit pattern)
            let countdownSeconds = max(30, alarm.alarmDate.timeIntervalSinceNow) // Ensure at least 30 seconds

            // Create countdown duration with preAlert and postAlert (following official Apple AlarmKit docs)
            let countdownDuration = Alarm.CountdownDuration(
                preAlert: countdownSeconds,
                postAlert: TimeInterval(alarm.postAlertMinutes * 60) // Convert minutes to seconds
            )

            // Create alarm configuration with countdown duration (following official Apple AlarmKit docs)
            let alarmConfiguration = AlarmConfiguration(
                countdownDuration: countdownDuration,
                attributes: attributes
            )

            _ = try await AlarmManager.shared.schedule(id: alarm.id, configuration: alarmConfiguration)

            print("✅ Scheduled AlarmKit countdown alarm: '\(alarm.title)' - \(alarm.durationString)")
            print("🎯 Countdown alarm will fire in: \(countdownSeconds) seconds at \(alarm.alarmDate.formatted())")

        } catch {
            print("❌ Failed to schedule AlarmKit alarm: \(error)")
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

    // MARK: - Calendar Integration
    
    private func setupCalendarIntegration() {
        // Monitor calendar events and automatically sync with alarms
        calendarService.$calendarEvents
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] calendarEvents in
                Task {
                    await self?.syncCalendarAlarms(calendarEvents)
                }
            }
            .store(in: &cancellables)
    }
    
    func requestCalendarAccess() async {
        await calendarService.requestCalendarAccess()
    }
    
    private func syncCalendarAlarms(_ calendarEvents: [CalendarAlarmEvent]) async {
        // Remove outdated calendar alarms
        let existingCalendarAlarms = alarms.filter { $0.isFromCalendar }
        let calendarEventIds = Set(calendarEvents.map { $0.originalEventId })
        
        for existingAlarm in existingCalendarAlarms {
            if let eventId = existingAlarm.calendarEventId,
               !calendarEventIds.contains(eventId) {
                // Calendar event was deleted or modified, remove the alarm
                deleteAlarm(existingAlarm)
                print("🗑️ Removed outdated calendar alarm: \(existingAlarm.title)")
            }
        }
        
        // Add new calendar alarms
        for calendarEvent in calendarEvents {
            let eventId = calendarEvent.originalEventId
            
            // Check if we already have an alarm for this calendar event
            let existingAlarm = alarms.first { alarm in
                alarm.isFromCalendar && alarm.calendarEventId == eventId
            }
            
            if existingAlarm == nil {
                // Create new alarm from calendar event
                let newAlarm = AlarmData(from: calendarEvent)
                addAlarm(newAlarm)
                print("📅➕ Added calendar alarm: \(newAlarm.title) - \(newAlarm.durationString)")
            }
        }
    }
    
    func refreshCalendarEvents() async {
        await calendarService.loadCalendarEvents()
    }
    
    // Get calendar vs manual alarms separately
    var calendarAlarms: [AlarmData] {
        alarms.filter { $0.isFromCalendar }
    }
    
    var manualAlarms: [AlarmData] {
        alarms.filter { !$0.isFromCalendar }
    }

    // MARK: - Live Activity Management (AlarmKit)

    // AlarmKit in iOS 26 handles Live Activities automatically when scheduling alarms
    // Manual ActivityKit integration removed to prevent conflicts with system Live Activities
}
