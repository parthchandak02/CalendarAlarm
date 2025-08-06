# AlarmKit Framework - Comprehensive Guide (iOS 26.0+)

## Overview
AlarmKit is a new framework introduced in iOS 26.0 that allows apps to create custom alarms and timers with prominent notifications, Live Activities, and Dynamic Island integration. This guide consolidates information from multiple Apple documentation sources, including official Apple developer documentation, WWDC 2025 materials, and technical references.

---

## Key Concepts Simplified

### What AlarmKit Does
- **Creates prominent alarms** that break through silent mode and Focus
- **Schedules notifications** at specific times or countdown intervals
- **Provides Live Activities** for countdown timers on Lock Screen and Dynamic Island
- **Supports custom sounds** and alert presentations
- **Manages alarm lifecycle** (create, pause, resume, cancel, snooze)

### When to Use AlarmKit
✅ **Good for**: Cooking timers, wake-up alarms, workout timers, medication reminders
❌ **Not for**: General notifications, non-time-critical alerts, background processing

---

## Core Architecture Components

Based on official Apple documentation, AlarmKit has these key components:

### 1. AlarmManager (Main Controller)
```swift
// Singleton pattern - always use shared instance
let manager = AlarmManager.shared

// Check authorization
let authStatus = await manager.authorizationState
if authStatus == .notDetermined {
    await manager.requestAuthorization()
}

// Schedule an alarm
try await manager.schedule(
    id: "unique-alarm-id", 
    configuration: AlarmManager.AlarmConfiguration(...)
)
```

**Source**: Apple AlarmKit Documentation - AlarmManager class

### 2. Alarm Object Structure
```swift
struct Alarm {
    let id: String                    // Unique identifier
    let schedule: Alarm.Schedule      // When it fires
    let state: Alarm.State           // Current state
    let countdownDuration: Alarm.CountdownDuration? // For timers
}
```

**Source**: Apple AlarmKit Documentation - Alarm struct

### 3. AlarmMetadata Protocol
**Critical**: This protocol requires specific conformances for compilation.

```swift
// Correct implementation based on official docs
struct MyAlarmMetadata: AlarmMetadata, @unchecked Sendable, Codable {
    let title: String
    
    init(title: String = "Alarm") {
        self.title = title
    }
}
```

**Key Requirements**:
- Must conform to `AlarmMetadata` protocol
- Must implement `@unchecked Sendable` for concurrency safety
- Must implement `Codable` for serialization
- Used to pass custom data between alarm scheduling and Live Activity presentation

**Source**: Apple AlarmKit Documentation - AlarmMetadata protocol

---

## Authorization & Info.plist Requirements

### Required Info.plist Keys
```xml
<key>NSAlarmKitUsageDescription</key>
<string>This app uses alarms to notify you of important events.</string>

<key>UIBackgroundModes</key>
<array>
    <string>background-processing</string>
</array>

<key>NSSupportsLiveActivities</key>
<true/>
```

**Source**: WWDC 2025 - Wake up to the AlarmKit API

### Authorization Flow
```swift
// Request permission (typically on app launch)
await AlarmManager.shared.requestAuthorization()

// Authorization states: .notDetermined, .authorized, .denied
let status = await AlarmManager.shared.authorizationState
```

---

## Scheduling Patterns

### 1. Fixed Time Alarms
```swift
let configuration = AlarmManager.AlarmConfiguration(
    schedule: .fixed(date: specificDate),
    presentation: AlarmPresentation(
        alert: .init(title: "Wake Up!", buttons: [...])
    ),
    metadata: MyAlarmMetadata(title: "Morning Alarm")
)
```

### 2. Countdown Timers
```swift
let configuration = AlarmManager.AlarmConfiguration(
    schedule: .countdown(duration: 300), // 5 minutes
    presentation: AlarmPresentation(
        countdown: .init(title: "Timer", buttons: [...]),
        alert: .init(title: "Time's Up!", buttons: [...])
    ),
    metadata: MyAlarmMetadata(title: "Cooking Timer")
)
```

**Source**: Apple AlarmKit Documentation - AlarmManager.AlarmConfiguration

---

## Live Activities Integration

### Requirements for Countdown Alarms
When creating countdown alarms, you **MUST** implement a Live Activity widget extension:

```swift
import WidgetKit
import SwiftUI
import AlarmKit

struct AlarmLiveActivity: Widget {
    var body: some WidgetConfiguration {
        AlarmActivityConfiguration<EmptyAlarmMetadata>(
            for: AlarmAttributes<EmptyAlarmMetadata>.self
        ) { context in
            // Lock Screen view
            VStack {
                Text(context.attributes.metadata.title)
                Text(timerInterval: context.state.countdownEndDate, countsDown: true)
            }
        } dynamicIsland: { context in
            // Dynamic Island view
            DynamicIsland {
                // Expanded view
            } compactLeading: {
                // Compact leading view
            } compactTrailing: {
                // Compact trailing view
            } minimal: {
                // Minimal view
            }
        }
    }
}
```

**Source**: WWDC 2025 - AlarmKit Live Activities Integration

---

## Common Issues & Solutions

### 1. Compilation Error: "Type 'EmptyAlarmMetadata' does not conform to protocol 'AlarmMetadata'"

**Problem**: Missing required protocol conformances

**Solution**:
```swift
// ❌ Wrong
struct EmptyAlarmMetadata: AlarmMetadata {
    let title: String = "Alarm"
}

// ✅ Correct
struct EmptyAlarmMetadata: AlarmMetadata, @unchecked Sendable, Codable {
    let title: String
    
    init(title: String = "Alarm") {
        self.title = title
    }
}
```

### 2. Alarms Not Firing

**Common Causes**:
- Missing authorization request
- Incorrect Info.plist keys
- Background modes not configured
- Live Activity not implemented for countdown timers

**Debugging Steps**:
1. Check authorization status: `AlarmManager.shared.authorizationState`
2. Verify Info.plist has `NSAlarmKitUsageDescription`
3. Test on physical device (not simulator)
4. Check system notification settings

### 3. Widget Extension Issues

**Problem**: Template widget code conflicts with AlarmKit

**Solution**: Remove sample widgets, keep only Live Activity implementation for AlarmKit

---

## Best Practices from Apple Documentation

### 1. User Experience
- Use clear, descriptive alarm titles
- Implement proper pause/resume controls for countdown timers
- Test across device states (locked, unlocked, different Focus modes)

### 2. Technical Implementation
- Always use `AlarmManager.shared` singleton
- Handle authorization states gracefully
- Use unique IDs for each alarm
- Implement proper error handling for scheduling failures

### 3. Performance
- Limit number of active alarms
- Use appropriate scheduling patterns (fixed vs. countdown)
- Test Live Activities on physical devices

**Source**: WWDC 2025 - AlarmKit Best Practices

---

## Quick Reference

### Essential API Methods
```swift
// Core operations
AlarmManager.shared.requestAuthorization()
AlarmManager.shared.schedule(id:configuration:)
AlarmManager.shared.cancel(id:)
AlarmManager.shared.pause(id:)
AlarmManager.shared.resume(id:)

// Monitoring
AlarmManager.shared.alarms         // Get all alarms
AlarmManager.shared.alarmUpdates   // Listen for changes
```

### Required Conformances
- `AlarmMetadata`: `@unchecked Sendable, Codable`
- Live Activity: Must implement for countdown alarms
- Authorization: Required before scheduling

---

## Documentation Sources

1. **Apple AlarmKit Official Documentation** - Core API reference
2. **WWDC 2025 - Wake up to the AlarmKit API** - Comprehensive framework overview
3. **Apple Developer Documentation** - Platform requirements and best practices
4. **Swift Evolution Proposals** - Protocol conformance patterns (@unchecked Sendable)

---

## Recent Implementation Learnings (Real-World Testing)

### Live Activity Countdown Display

**Key Discovery**: Use SwiftUI's `Text(timerInterval:countsDown:)` for real-time countdown display:

```swift
// ✅ This creates a live, auto-updating countdown
if case .countdown(let countdown) = context.state.mode {
    let fireDate = countdown.startDate.addingTimeInterval(
        countdown.totalCountdownDuration - countdown.previouslyElapsedDuration
    )
    Text(timerInterval: Date()...fireDate, countsDown: true)
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(.red)
        .monospacedDigit()
}
```

**Source**: Testing revealed static text doesn't update; this pattern provides automatic countdown updates.

### AlarmMetadata Protocol Conformance

**Critical Fix**: Use `nonisolated(unsafe)` for proper Swift 6/iOS 26 compatibility:

```swift
nonisolated(unsafe) struct EmptyAlarmMetadata: AlarmMetadata, Sendable, Codable {
    let title: String
    
    nonisolated init(title: String = "Alarm") {
        self.title = title
    }
}
```

**Source**: Compilation testing showed this resolves actor isolation issues in iOS 26 beta.

### Snooze Button Configuration

**Working Pattern**: Secondary button with countdown behavior:

```swift
let alertPresentation = AlarmPresentation.Alert(
    title: LocalizedStringResource(stringLiteral: alarm.title),
    stopButton: stopButton,
    secondaryButton: snoozeButton,
    secondaryButtonBehavior: alarm.snoozeEnabled ? .countdown : nil
)
```

**Source**: Testing confirmed snooze appears with proper secondary button configuration.

### Dynamic Island Countdown

**Success Pattern**: Live countdown text in compact trailing view:

```swift
// Shows actual countdown numbers in Dynamic Island
if case .countdown(let countdown) = context.state.mode {
    let fireDate = countdown.startDate.addingTimeInterval(
        countdown.totalCountdownDuration - countdown.previouslyElapsedDuration
    )
    Text(timerInterval: Date()...fireDate, countsDown: true)
        .font(.caption)
        .fontWeight(.bold)
        .foregroundColor(.red)
        .monospacedDigit()
}
```

**Source**: Real device testing confirmed this displays live countdown in Dynamic Island.

---

## Documentation Sources

1. **Apple AlarmKit Official Documentation** - Core API reference
2. **WWDC 2025 - Wake up to the AlarmKit API** - Comprehensive framework overview  
3. **Apple Developer Documentation** - Platform requirements and best practices
4. **Swift Evolution Proposals** - Protocol conformance patterns (@unchecked Sendable)
5. **Real-World Implementation Testing** - Live Activity patterns and UI optimization

This guide provides the essential information needed to successfully implement AlarmKit in your iOS 26+ applications while avoiding common pitfalls and compilation errors.