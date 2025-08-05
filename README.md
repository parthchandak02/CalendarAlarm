# CalendarAlarmApp - iOS 26 AlarmKit Demo

A comprehensive iOS app demonstrating the **iOS 26 AlarmKit framework** for countdown-based alarms with Live Activities and Dynamic Island integration.

## ✨ Features

### 🎯 **AlarmKit Integration (iOS 26)**
- **Countdown-based alarms** using `Alarm.CountdownDuration` 
- **Live Activities** with Dynamic Island support
- **Custom alarm presentations** (Alert, Countdown, Paused states)
- **App Intents** for Live Activity interactions
- **Custom sounds** and alarm metadata

### 📱 **iOS Clock-Style UI**
- Dark theme with orange accents
- Large countdown duration display (e.g., "1h 30m")
- Duration picker with hours/minutes wheels
- Professional iOS styling and typography

### ⏰ **AlarmKit-Specific Features**
- **Pre-alert warnings** (10 minutes before countdown ends)
- **Post-alert duration** (keeps alert active for 5 minutes)
- **Pause/Resume functionality** during countdown
- **Repeat options** when alarms complete
- **Custom metadata** with sound icons

## 🚀 Quick Start

### Prerequisites
- Xcode 16.3+ 
- iOS 26.0+ (Simulator or Physical Device)
- Apple Developer Account (for device testing)

### Installation

1. **Clone and build:**
   ```bash
   cd CalendarAlarmApp
   ./deploy.sh
   ```

2. **The script will automatically:**
   - Detect iOS 26.0 simulators or physical devices
   - Build the app with proper AlarmKit configuration
   - Install and launch the app
   - Boot simulators if needed

## 📋 Project Structure

```
CalendarAlarmApp/
├── 📱 CalendarAlarmAppApp.swift      # App entry point with AlarmKit authorization
├── 📁 Models/
│   └── AlarmModel.swift              # Countdown-based data models + AlarmKit integration
├── 📁 Views/
│   ├── MainAlarmView.swift           # iOS Clock-style main interface
│   └── AddEditAlarmView.swift        # Countdown duration picker interface
├── 📁 Widgets/
│   ├── AlarmLiveActivity.swift       # Dynamic Island Live Activity
│   └── AlarmWidgetBundle.swift       # Widget bundle configuration
├── 📁 Intents/
│   └── AlarmAppIntents.swift         # App Intents for alarm actions
├── 📄 Info.plist                     # AlarmKit and Live Activity configurations
├── 📄 CalendarAlarmApp.entitlements  # Required permissions and capabilities
└── 📄 deploy.sh                      # Smart deployment script
```

## 🔧 AlarmKit Implementation

### Core Pattern (Following iOS 26 Docs)
```swift
typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<AlarmAppMetadata>

let duration = Alarm.CountdownDuration(preAlert: (10 * 60), postAlert: (5 * 60))
let alarmConfiguration = AlarmConfiguration(
    countdownDuration: duration,
    attributes: attributes,
    sound: sound)

try await AlarmManager.shared.schedule(id: alarm.id, configuration: alarmConfiguration)
```

### Live Activity States
- **📊 Countdown**: Shows remaining time with pause button
- **⏸️ Paused**: Shows paused state with resume button  
- **🚨 Alert**: Shows active alarm with dismiss/repeat options

### Dynamic Island Integration
- **Compact**: Shows timer icon and remaining time
- **Expanded**: Shows full alarm details and controls
- **Minimal**: Shows appropriate status icon

## 📱 Testing

### Simulator Testing (Recommended)
```bash
# The deploy script automatically detects iOS 26.0 simulators
./deploy.sh  # Will use booted iPhone 16 Pro (iOS 26.0) simulator
```

### Physical Device Testing
```bash
# Connect iPhone 16 Pro with iOS 26.0+
./deploy.sh  # Will detect and deploy to physical device
```

### AlarmKit Features to Test
- ✅ Create countdown timer alarms (30 min, 1 hour, etc.)
- ✅ Live Activity appears in Dynamic Island
- ✅ Pause/Resume during countdown
- ✅ Pre-alert notifications (10 min warning)
- ✅ Custom sounds and alert presentations
- ✅ App Intents from Live Activity buttons

## 🔔 AlarmKit vs Traditional Notifications

**iOS 26 AlarmKit provides:**
- ✅ **System-level countdown timers** (not just notifications)
- ✅ **Live Activities** with Dynamic Island integration
- ✅ **Rich alarm presentations** (Alert, Countdown, Paused)
- ✅ **Reliable alarm delivery** (works in Do Not Disturb)
- ✅ **Advanced alarm controls** (pause, resume, repeat)

**Traditional notifications:**
- ❌ Limited to 30-second duration
- ❌ Affected by Do Not Disturb settings
- ❌ No Live Activity integration
- ❌ Basic alert presentations only

## 🛠️ Configuration Files

### Info.plist Configuration
```xml
<key>NSSupportsLiveActivities</key>
<true/>
<key>NSAlarmKitUsageDescription</key>
<string>This app uses AlarmKit to create countdown timer alarms with Live Activities.</string>
```

### Entitlements Required
```xml
<key>com.apple.developer.alarmkit</key>
<true/>
<key>com.apple.developer.usernotifications.live-activities</key>
<true/>
```

## 📚 AlarmKit Documentation Reference

This implementation follows the **WWDC 2025 AlarmKit presentation** patterns exactly:
- ✅ `Alarm.CountdownDuration` for timer-based alarms
- ✅ `AlarmAttributes<CustomMetadata>` with proper metadata
- ✅ `AlarmPresentation.Alert/Countdown/Paused` states
- ✅ `AlarmManager.shared.schedule()` for alarm creation
- ✅ Live Activity widget for Dynamic Island
- ✅ App Intents for custom alarm actions

## 🐛 Troubleshooting

### Common Issues
1. **"AlarmKit authorization denied"**
   - Ensure Developer Mode is enabled on device
   - Check entitlements file is properly configured

2. **"Live Activities not showing"**
   - Verify iOS 26.0+ is being used
   - Check Live Activity permissions in Settings

3. **"Build failed"**
   - Ensure Xcode 16.3+ is installed
   - Verify Apple Developer account is active
   - Check project signing configuration

### Device Requirements
- 📱 iOS 26.0+
- 🔋 iPhone with Dynamic Island (for full experience)
- 🔓 Developer Mode enabled
- ✅ AlarmKit entitlements granted

## 📖 Learn More

- [WWDC 2025 AlarmKit Session](https://developer.apple.com/videos/play/wwdc2025/230/)
- [iOS 26 AlarmKit Documentation](https://developer.apple.com/documentation/alarmkit)
- [Live Activities Programming Guide](https://developer.apple.com/documentation/activitykit)

---

**Built with iOS 26 AlarmKit for countdown-based alarms with Live Activities! 🚀**