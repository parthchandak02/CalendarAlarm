//
//  AlarmLiveActivity.swift
//  CalendarAlarmApp
//
//  Created by Parth Chandak on 8/4/25.
//

// AlarmKit handles Live Activities automatically in iOS 26
// Manual ActivityKit Live Activity widget commented out to prevent conflicts
// with AlarmKit's built-in Live Activity management

/*
import ActivityKit
import AlarmKit
import SwiftUI
import WidgetKit

// MARK: - Live Activity Widget (Following AlarmKit docs)

struct AlarmLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlarmCountdownAttributes.self) { context in
            // Lock Screen/Banner UI
            lockScreenView(context)
        } dynamicIsland: { context in
            // Dynamic Island UI following iOS 26 pattern
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    leadingView(context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    trailingView(context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    bottomView(context)
                }
            } compactLeading: {
                compactLeadingView(context)
            } compactTrailing: {
                compactTrailingView(context)
            } minimal: {
                minimalView(context)
            }
            .keylineTint(.orange)
        }
    }

    // MARK: - Lock Screen View

    @ViewBuilder
    func lockScreenView(_ context: ActivityViewContext<AlarmCountdownAttributes>) -> some View {
        if context.state.isPaused {
            pausedView(context)
        } else {
            countdownView(context)
        }
    }

    // MARK: - Countdown View

    @ViewBuilder
    func countdownView(_ context: ActivityViewContext<AlarmCountdownAttributes>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    alarmIcon(context)
                    Text("Alarm")
                        .font(.headline)
                        .foregroundColor(.white)
                }

                Text("Countdown Active")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack {
                Text(timerInterval: context.state.remainingTime, countsDown: true)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .monospacedDigit()

                Text(context.state.isPaused ? "Paused" : "Active")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.black)
    }

    // MARK: - Paused View

    @ViewBuilder
    func pausedView(_ context: ActivityViewContext<AlarmCountdownAttributes>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    alarmIcon(context)
                    Text("Alarm")
                        .font(.headline)
                        .foregroundColor(.white)
                }

                Text("Paused")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }

            Spacer()

            VStack {
                Image(systemName: "pause.circle.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)

                Text("Tap to resume")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.black)
    }

    // MARK: - Alert View

    @ViewBuilder
    func alertView(_ context: ActivityViewContext<AlarmCountdownAttributes>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    alarmIcon(context)
                    Text("Alarm")
                        .font(.headline)
                        .foregroundColor(.white)
                }

                Text("ALARM!")
                    .font(.caption)
                    .foregroundColor(.red)
                    .fontWeight(.bold)
            }

            Spacer()

            VStack {
                Image(systemName: "alarm.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                    .symbolEffect(.bounce, options: .repeating)

                Text("Active")
                    .font(.caption2)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.black)
    }

    // MARK: - Dynamic Island Views

    @ViewBuilder
    func leadingView(_ context: ActivityViewContext<AlarmCountdownAttributes>) -> some View {
        HStack {
            alarmIcon(context)
            Text(context.state.alarmTitle)
                .font(.caption)
                .foregroundColor(.white)
        }
    }

    @ViewBuilder
    func trailingView(_ context: ActivityViewContext<AlarmCountdownAttributes>) -> some View {
        if context.state.isPaused {
            Image(systemName: "pause.circle.fill")
                .foregroundColor(.yellow)
        } else {
            Image(systemName: "timer")
                .foregroundColor(.orange)
        }
    }

    @ViewBuilder
    func bottomView(_ context: ActivityViewContext<AlarmCountdownAttributes>) -> some View {
        if context.state.isPaused {
            Text("Alarm countdown paused")
                .font(.caption)
                .foregroundColor(.yellow)
        } else {
            Text("Alarm countdown in progress")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    @ViewBuilder
    func compactLeadingView(_ context: ActivityViewContext<AlarmCountdownAttributes>) -> some View {
        alarmIcon(context)
    }

    @ViewBuilder
    func compactTrailingView(_ context: ActivityViewContext<AlarmCountdownAttributes>) -> some View {
        if context.state.isPaused {
            Image(systemName: "pause")
                .font(.caption2)
                .foregroundColor(.yellow)
        } else {
            Image(systemName: "timer")
                .font(.caption2)
                .foregroundColor(.orange)
        }
    }

    @ViewBuilder
    func minimalView(_ context: ActivityViewContext<AlarmCountdownAttributes>) -> some View {
        if context.state.isPaused {
            Image(systemName: "pause")
                .foregroundColor(.yellow)
        } else {
            Image(systemName: "timer")
                .foregroundColor(.orange)
        }
    }

    // MARK: - Helper Views

    func alarmIcon(_ context: ActivityViewContext<AlarmCountdownAttributes>) -> some View {
        // Use static alarm icon for iOS 26 beta compatibility  
        Image(systemName: "alarm")
            .foregroundColor(.orange)
    }
}
*/
