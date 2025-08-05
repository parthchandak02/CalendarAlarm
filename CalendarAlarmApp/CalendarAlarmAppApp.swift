//
//  CalendarAlarmAppApp.swift
//  CalendarAlarmApp
//
//  Created by Parth Chandak on 8/4/25.
//

import AlarmKit
import SwiftUI

@main
struct CalendarAlarmAppApp: App {
    var body: some Scene {
        WindowGroup {
            MainAlarmView()
                .onAppear {
                    Task {
                        await requestAlarmAuthorization()
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
}
