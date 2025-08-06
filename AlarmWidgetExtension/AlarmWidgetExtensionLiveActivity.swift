import ActivityKit
import AlarmKit
import SwiftUI
import WidgetKit

// MARK: - Metadata Types (shared with main app)

nonisolated(unsafe) struct EmptyAlarmMetadata: AlarmMetadata, Sendable, Codable {
    let title: String
    
    nonisolated init(title: String = "Alarm") {
        self.title = title
    }
}

typealias AlarmAppMetadata = EmptyAlarmMetadata

struct AlarmWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlarmAttributes<AlarmAppMetadata>.self) { context in
            // Lock screen/banner UI for AlarmKit
            AlarmLockScreenView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island presentation
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    AlarmExpandedLeadingView(context: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    AlarmExpandedTrailingView(context: context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    AlarmExpandedBottomView(context: context)
                }
            } compactLeading: {
                AlarmCompactLeading(context: context)
            } compactTrailing: {
                AlarmCompactTrailing(context: context)
            } minimal: {
                AlarmMinimal(context: context)
            }
        }
    }
}

// MARK: - Lock Screen Views

struct AlarmLockScreenView: View {
    let context: ActivityViewContext<AlarmAttributes<AlarmAppMetadata>>

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(.red)
                Text(context.attributes.metadata?.title ?? "Alarm")
                    .font(.headline)
                Spacer()
            }

            switch context.state.mode {
            case .countdown:
                CountdownView(context: context)
            case .paused:
                PausedView(context: context)
            case .alert:
                AlertView(context: context)
            @unknown default:
                Text("Unknown state")
            }
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Dynamic Island Views

struct AlarmExpandedLeadingView: View {
    let context: ActivityViewContext<AlarmAttributes<AlarmAppMetadata>>

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: "timer")
                .foregroundColor(.orange)
            Text(context.attributes.metadata?.title ?? "Alarm")
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct AlarmExpandedTrailingView: View {
    let context: ActivityViewContext<AlarmAttributes<AlarmAppMetadata>>

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // AlarmKit manages the countdown timer display internally
            // We show a placeholder since remainingTime isn't directly accessible
            Text("Countdown")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.orange)
        }
    }
}

struct AlarmExpandedBottomView: View {
    let context: ActivityViewContext<AlarmAttributes<AlarmAppMetadata>>

    var body: some View {
        HStack {
            switch context.state.mode {
            case .countdown:
                Button("Pause") {
                    // Pause action will be handled by AlarmKit
                }
                .buttonStyle(.bordered)
                .tint(.orange)
            case .paused:
                Button("Resume") {
                    // Resume action will be handled by AlarmKit
                }
                .buttonStyle(.bordered)
                .tint(.green)
            case .alert:
                HStack(spacing: 12) {
                    Button("Stop") {
                        // Stop action will be handled by AlarmKit
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)

                    Button("Snooze") {
                        // Snooze action will be handled by AlarmKit
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                }
            @unknown default:
                EmptyView()
            }
        }
    }
}

struct AlarmCompactLeading: View {
    let context: ActivityViewContext<AlarmAttributes<AlarmAppMetadata>>

    var body: some View {
        Image(systemName: "timer")
            .foregroundColor(.red)
    }
}

struct AlarmCompactTrailing: View {
    let context: ActivityViewContext<AlarmAttributes<AlarmAppMetadata>>

    var body: some View {
        // Show actual countdown time in Dynamic Island
        if case .countdown(let countdown) = context.state.mode {
            let fireDate = countdown.startDate.addingTimeInterval(countdown.totalCountdownDuration - countdown.previouslyElapsedDuration)
            Text(timerInterval: Date()...fireDate, countsDown: true)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.red)
                .monospacedDigit()
        } else {
            Text("⏱")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.red)
        }
    }
}

struct AlarmMinimal: View {
    let context: ActivityViewContext<AlarmAttributes<AlarmAppMetadata>>

    var body: some View {
        // Check alarm state mode for appropriate icon
        let isAlerting = {
            switch context.state.mode {
            case .alert:
                return true
            default:
                return false
            }
        }()

        Image(systemName: isAlerting ? "bell.fill" : "timer")
            .foregroundColor(isAlerting ? .red : .orange)
    }
}

// MARK: - State-specific Views

struct CountdownView: View {
    let context: ActivityViewContext<AlarmAttributes<AlarmAppMetadata>>

    var body: some View {
        VStack(spacing: 8) {
            // AlarmKit manages the countdown timer display
            Image(systemName: "timer")
                .font(.title)
                .foregroundColor(.red)

            Text("Countdown Active")
                .font(.headline)
                .foregroundColor(.red)

            // Show actual countdown timer using proper SwiftUI Text countdown
            if case .countdown(let countdown) = context.state.mode {
                let fireDate = countdown.startDate.addingTimeInterval(countdown.totalCountdownDuration - countdown.previouslyElapsedDuration)
                Text(timerInterval: Date()...fireDate, countsDown: true)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                    .monospacedDigit()
            } else {
                Text("Time remaining")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct PausedView: View {
    let context: ActivityViewContext<AlarmAttributes<AlarmAppMetadata>>

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "pause.circle.fill")
                .font(.title)
                .foregroundColor(.yellow)

            Text("Paused")
                .font(.headline)
                .foregroundColor(.yellow)
        }
    }
}

struct AlertView: View {
    let context: ActivityViewContext<AlarmAttributes<AlarmAppMetadata>>

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "bell.fill")
                .font(.title)
                .foregroundColor(.red)

            Text("Time's Up!")
                .font(.headline)
                .foregroundColor(.red)

            Text(context.attributes.metadata?.title ?? "Alarm")
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}
