//
//  AlarmWidgetExtensionBundle.swift
//  AlarmWidgetExtension
//
//  Created by Parth Chandak on 8/5/25.
//

import SwiftUI
import WidgetKit

@main
struct AlarmWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        AlarmWidgetExtension()
        AlarmWidgetExtensionControl()
        AlarmWidgetExtensionLiveActivity()
    }
}
