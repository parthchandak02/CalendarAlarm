//
//  AlarmWidgetBundle.swift
//  CalendarAlarmApp
//
//  Created by Parth Chandak on 8/4/25.
//

import SwiftUI
import WidgetKit

// MARK: - Widget Bundle for AlarmKit Live Activities

// Note: This will be moved to a separate Widget Extension target in production
struct AlarmWidgetBundle: WidgetBundle {
    var body: some Widget {
        AlarmLiveActivity()
    }
}
