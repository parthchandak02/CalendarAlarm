//
//  CalendarService.swift
//  CalendarAlarmApp
//
//  Created by Parth Chandak on 8/4/25.
//

import EventKit
import Foundation
import Combine

// MARK: - Calendar Service

@MainActor
class CalendarService: ObservableObject {
    @Published var calendarEvents: [CalendarAlarmEvent] = []
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var isLoading = false
    
    private let eventStore = EKEventStore()
    private var cancellables = Set<AnyCancellable>()
    
    // Regex pattern to match alarm text like "alarm2", "alarm15", etc.
    private let alarmPattern: NSRegularExpression = {
        do {
            return try NSRegularExpression(pattern: "alarm(\\d+)", options: .caseInsensitive)
        } catch {
            fatalError("Invalid regex pattern: \(error)")
        }
    }()
    
    init() {
        setupCalendarChangeMonitoring()
        checkAuthorizationStatus()
        // Load events initially if we already have authorization
        if authorizationStatus == .fullAccess {
            Task {
                await loadCalendarEvents()
            }
        }
    }
    
    // MARK: - Authorization
    
    func checkAuthorizationStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }
    
    func requestCalendarAccess() async {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            await MainActor.run {
                authorizationStatus = granted ? .fullAccess : .denied
                if granted {
                    Task {
                        await loadCalendarEvents()
                    }
                }
            }
        } catch {
            print("❌ Failed to request calendar access: \(error)")
            await MainActor.run {
                authorizationStatus = .denied
            }
        }
    }
    
    // MARK: - Calendar Monitoring
    
    private func setupCalendarChangeMonitoring() {
        // Monitor calendar changes using NotificationCenter
        print("🔧 Setting up calendar change monitoring...")
        NotificationCenter.default.publisher(for: .EKEventStoreChanged)
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main) // Debounce rapid changes
            .sink { [weak self] notification in
                print("📅🔄 Calendar database changed! Notification: \(notification)")
                Task {
                    await self?.loadCalendarEvents()
                }
            }
            .store(in: &cancellables)
        
        print("✅ Calendar change monitoring setup complete")
    }
    
    // MARK: - Event Loading
    
    func loadCalendarEvents() async {
        guard authorizationStatus == .fullAccess else {
            print("❌ Calendar access not granted")
            return
        }
        
        await MainActor.run {
            isLoading = true
        }
        
        // Fetch events for the next 7 days
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate) ?? startDate
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)
        
        var calendarAlarmEvents: [CalendarAlarmEvent] = []
        
        print("📅 Checking \(events.count) events for alarm patterns...")
        
        for event in events {
            print("📅🔍 Event: '\(event.title ?? "Untitled")' at \(event.startDate)")
            
            if let alarmMinutes = extractAlarmMinutes(from: event) {
                let alarmDate = event.startDate.addingTimeInterval(-TimeInterval(alarmMinutes * 60))
                
                // Only include future alarms
                if alarmDate > Date() {
                    let calendarEvent = CalendarAlarmEvent(
                        id: UUID().uuidString, // Generate new ID for our alarm
                        title: event.title ?? "Untitled Event",
                        startDate: event.startDate,
                        endDate: event.endDate,
                        location: event.location,
                        notes: event.notes,
                        alarmMinutes: alarmMinutes,
                        calendarTitle: event.calendar.title,
                        originalEventId: event.eventIdentifier
                    )
                    calendarAlarmEvents.append(calendarEvent)
                    
                    print("📅✅ Added alarm: '\(event.title ?? "")' - \(alarmMinutes) min before (\(alarmDate))")
                } else {
                    print("📅⏰ Skipped past alarm: '\(event.title ?? "")' - alarm was at \(alarmDate)")
                }
            } else {
                print("📅⚪ No alarm pattern in: '\(event.title ?? "Untitled")'")
            }
        }
        
        await MainActor.run {
            let previousCount = self.calendarEvents.count
            self.calendarEvents = calendarAlarmEvents
            self.isLoading = false
            
            print("📅📊 Calendar events updated: \(previousCount) → \(calendarAlarmEvents.count) alarm events")
            if previousCount != calendarAlarmEvents.count {
                print("📅🔔 Calendar alarm count changed, this should trigger alarm sync...")
            }
        }
    }
    
    // MARK: - Alarm Pattern Parsing
    
    private func extractAlarmMinutes(from event: EKEvent) -> Int? {
        // Check title for alarm pattern
        if let title = event.title {
            if let minutes = extractMinutesFromText(title) {
                return minutes
            }
        }
        
        // Check notes for alarm pattern
        if let notes = event.notes {
            if let minutes = extractMinutesFromText(notes) {
                return minutes
            }
        }
        
        return nil
    }
    
    private func extractMinutesFromText(_ text: String) -> Int? {
        let range = NSRange(location: 0, length: text.utf16.count)
        let matches = alarmPattern.matches(in: text, options: [], range: range)
        
        for match in matches {
            if match.numberOfRanges > 1 {
                let captureGroupRange = match.range(at: 1)
                if let range = Range(captureGroupRange, in: text) {
                    let minutesString = String(text[range])
                    if let minutes = Int(minutesString) {
                        return minutes
                    }
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Helper Methods
    
    func getCalendarEventById(_ id: String) -> CalendarAlarmEvent? {
        return calendarEvents.first { $0.id == id }
    }
    
    func getEventsByDateRange(start: Date, end: Date) -> [CalendarAlarmEvent] {
        return calendarEvents.filter { event in
            event.alarmDate >= start && event.alarmDate <= end
        }
    }
}