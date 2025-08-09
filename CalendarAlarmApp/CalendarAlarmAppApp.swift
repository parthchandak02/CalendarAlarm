//
//  CalendarAlarmAppApp.swift
//  CalendarAlarmApp
//
//  Created by Parth Chandak on 8/4/25.
//

import AlarmKit
import SwiftUI
import BackgroundTasks
import UserNotifications

@main
struct CalendarAlarmAppApp: App {
    @StateObject private var alarmStore = AlarmStore()
    
    var body: some Scene {
        WindowGroup {
            MainAlarmView()
                .environmentObject(alarmStore)
                .onAppear {
                    Task {
                        await requestAlarmAuthorization()
                        await setupBackgroundTasks()
                        await setupNotificationHandling()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    // When app becomes active, immediately check for calendar changes and process Live Activities
                    print("📱 App became active - checking for calendar changes...")
                    Task {
                        // First, force refresh calendar data to detect external changes
                        await alarmStore.forceRefreshCalendarData()
                        
                        // Then process any pending Live Activities
                        await alarmStore.processPendingLiveActivitiesOnForeground()
                    }
                }

        }
    }

    private func requestAlarmAuthorization() async {
        switch AlarmManager.shared.authorizationState {
        case .notDetermined:
            // Request authorization
            do {
                let result = try await AlarmManager.shared.requestAuthorization()
                print("AlarmKit authorization result: \(result)")
            } catch {
                print("Failed to request AlarmKit authorization: \(error)")
            }
        case .authorized:
            print("AlarmKit authorization granted")
        case .denied:
            print("AlarmKit authorization denied")
        @unknown default:
            break
        }
    }
    
    private func setupBackgroundTasks() async {
        print("🔧 Setting up initial background task scheduling...")
        
        // Register background task handlers
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "pchandak.CalendarAlarmApp.liveActivityTrigger", using: nil) { task in
            self.handleLiveActivityTriggerTask(task as! BGAppRefreshTask)
        }
        
        // Schedule initial background refresh
        let refreshRequest = BGAppRefreshTaskRequest(identifier: "pchandak.CalendarAlarms.calendarRefresh")
        refreshRequest.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes from now
        
        do {
            try BGTaskScheduler.shared.submit(refreshRequest)
            print("✅ Initial background refresh scheduled")
        } catch {
            print("❌ Failed to schedule initial background refresh: \(error)")
        }
    }
    
    private func setupNotificationHandling() async {
        // Set notification delegate to handle user interactions
        UNUserNotificationCenter.current().delegate = NotificationDelegate(alarmStore: alarmStore)
    }
    
    private func handleLiveActivityTriggerTask(_ task: BGAppRefreshTask) {
        print("📱 Handling Live Activity trigger background task...")
        
        task.expirationHandler = {
            print("⏰ Live Activity trigger task expired")
            task.setTaskCompleted(success: false)
        }
        
        Task {
            // Process pending Live Activities
            await alarmStore.processPendingLiveActivitiesOnForeground()
            
            print("✅ Live Activity trigger task completed")
            task.setTaskCompleted(success: true)
        }
    }
    
    // MARK: - URL Scheme Handling
    
    private func handleURLScheme(_ url: URL) {
        print("🔗 Received URL scheme: \(url)")
        
        guard url.scheme == "calendaralarms" else {
            print("⚠️ Unknown URL scheme: \(url.scheme ?? "nil")")
            return
        }
        
        switch url.host {
        case "refresh":
            print("🔄 URL scheme triggered calendar refresh")
            Task {
                await alarmStore.forceRefreshCalendarData()
                await alarmStore.processPendingLiveActivitiesOnForeground()
            }
            
        case "open":
            print("📱 URL scheme triggered app open (default behavior)")
            // App opening already triggers refresh via didBecomeActive
            
        default:
            print("⚠️ Unknown URL host: \(url.host ?? "nil")")
            // Default: still refresh calendar data
            Task {
                await alarmStore.forceRefreshCalendarData()
            }
        }
    }
}

// MARK: - Notification Delegate

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    let alarmStore: AlarmStore
    
    init(alarmStore: AlarmStore) {
        self.alarmStore = alarmStore
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // For automatic calendar notifications, show them silently
        if notification.request.content.categoryIdentifier == "CALENDAR_UPDATE" {
            completionHandler([.badge]) // Only show badge, no alert or sound
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    // Handle notification actions and taps
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        Task {
            if response.notification.request.content.categoryIdentifier == "CALENDAR_UPDATE" {
                print("📱 Processing calendar update notification action")
                
                // This brings the app to foreground and triggers Live Activity processing
                await alarmStore.processPendingLiveActivitiesOnForeground()
            }
            
            completionHandler()
        }
    }
}
