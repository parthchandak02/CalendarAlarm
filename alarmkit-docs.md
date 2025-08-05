

View in English

* [Global Nav Open Menu](#ac-gn-menustate)
  Global Nav Close Menu
* [Apple Developer](/)

[Search

Cancel](/search/)

* [Apple Developer](/)
* [News](/news/)
* [Discover](/discover/)
* [Design](/design/)
* [Develop](/develop/)
* [Distribute](/distribute/)
* [Support](/support/)
* [Account](/account/)

Cancel

Only search within “”
### Quick Links

5 Quick Links

## [Videos](/videos/)

[Open Menu](#localnav-menustate)
Close Menu

* [Collections](/videos/)
* [Topics](/videos/topics/)
* [All Videos](/videos/all-videos/)
* [About](/videos/about/)

[More Videos](/videos/)

![](/assets/elements/icons/symbols/gobackward5.svg)
![](/assets/elements/icons/symbols/goforward5.svg)

![](https://devimages-cdn.apple.com/wwdc-services/images/3055294D-836B-4513-B7B0-0BC5666246B0/9928/9928_wide_900x506_2x.jpg)

* About
* Summary
* Transcript
* Code

* # Wake up to the AlarmKit API

  Rrrr-rrrrr-innng! From countdown timers in your recipe app to wake-up alarms in your travel planning app, the AlarmKit framework in iOS and iPadOS 26 brings timers and alarms to the Lock Screen, Dynamic Island, and more. Learn how to create and manage your app's alarms, customize their Live Activities, and offer custom alert actions using the App Intents framework. To get the most from this video, we recommend first watching “Meet ActivityKit” from WWDC23.

  ## Chapters

  + 0:00 - [Welcome](/videos/play/wwdc2025/230/?time=0)
  + 0:32 - [Overview](/videos/play/wwdc2025/230/?time=32)
  + 1:39 - [Authorization](/videos/play/wwdc2025/230/?time=99)
  + 3:06 - [Creation](/videos/play/wwdc2025/230/?time=186)
  + 16:32 - [Life cycle](/videos/play/wwdc2025/230/?time=992)
  ## Resources

  + [ActivityKit](https://developer.apple.com/documentation/ActivityKit)
  + [AlarmKit](https://developer.apple.com/documentation/AlarmKit)
  + [App Intents](https://developer.apple.com/documentation/AppIntents)
  + [Creating your first app intent](https://developer.apple.com/documentation/AppIntents/Creating-your-first-app-intent)
  + [Human Interface Guidelines: Live Activities](https://developer.apple.com/design/human-interface-guidelines/live-activities)
  + [Scheduling an alarm with AlarmKit](https://developer.apple.com/documentation/AlarmKit/scheduling-an-alarm-with-alarmkit)
  + - [HD Video](https://devstreaming-cdn.apple.com/videos/wwdc/2025/230/4/d60bc47c-1b62-4fa0-a1d1-d046cf20f1de/downloads/wwdc2025-230_hd.mp4?dl=1)
    - [SD Video](https://devstreaming-cdn.apple.com/videos/wwdc/2025/230/4/d60bc47c-1b62-4fa0-a1d1-d046cf20f1de/downloads/wwdc2025-230_sd.mp4?dl=1)
  ## Related Videos

  #### WWDC25

  + [Get to know App Intents](/videos/play/wwdc2025/244)
  #### WWDC23

  + [Meet ActivityKit](/videos/play/wwdc2023/10184)
* Search this video…

  Hey, I’m Anton, an engineer on the system experience team. In this session, you’ll meet AlarmKit, a framework that allows you to create alarms in your app. In this video, I will first walk you through the experience you can build with AlarmKit then I’ll discuss how you can get your app authorization for using this framework, how to create an alarm, and how you can manage its lifecycle. I’ll start with the experience. An alarm is a prominent alert for things that occur at a fixed, pre-determined time. It’s based on a schedule or a countdown. When it fires, the alert breaks through the silent mode and the current focus.

  In the alert, people are presented with the custom alarm title, as well as the name of your app People have the option of stopping the alert or snoozing it with an optional snooze button.

  Alternatively, an alarm can have a custom button whose action is defined by an app intent.

  Alarms are also supported in other system experiences, such as in StandBy and right on Apple Watch, if it’s paired to iPhone when the alarm fires.

  Alarms support a custom countdown interface using Live Activities that your app provides. This can be viewed on the Lock Screen as well as in the dynamic island and in StandBy.

  People opt in to enable alarm functionality for each app on their device.

  Now that you know what an alarm is, let’s talk about what you need to do to allow people to authorize your app to schedule alarms.

  Before your app can schedule alarms, people will need to consent by providing authorization.

  You can request authorization manually, or it will be requested automatically when you create your first alarm. At any time, people can change their authorization status in the Settings app.

  Setting up authorization is simple, you just need to add NSAlarmKitUsageDescription to your app’s info plist explaining the use case for presenting alarms.

  Provide a short and descriptive explanation of how your app will be using alarms, to help people make the best decision. To request authorization manually, you can use the AlarmManager requestAuthorization API If a choice has not previously been made, a prompt will be shown containing the usage description.

  You can check authorization status before scheduling an alarm by querying the authorizationState in the AlarmManager class.

  In this case, if it’s not determined, I can request authorization manually. If authorized, I can proceed with scheduling the alarm. If denied, it’s important to make it clear in your app’s interface that the alarm will not be scheduled. Now that you are familiar with authorization setup for alarms, let’s talk about how to create an alarm. The main parts required for creating an alarm are countdown duration, A schedule with a specific date or recurrence pattern Appearance configuration, handling of custom actions And associated sound.

  Let’s start with countdown duration. An alarm can have a pre-alert and post-alert countdown interval. When an alarm is first scheduled it will display the countdown UI which will appear for the pre-alert countdown duration.

  When the pre-alert duration elapses, the alarm fires and displays the alert UI, customized with your configuration.

  If the alarm is snoozed the countdown UI will appear again for the duration of the post-alert interval.

  Once this interval elapses, the alarm will fire again and can be snoozed or dismissed.

  In this example, I'm setting up a timer with a pre alert duration of 10 minutes. Once it fires and is repeated it will count down the 5 minute post alert duration and fire again. When creating an alarm you can also provide a schedule, which can be either fixed or relative.

  A fixed schedule specifies a single future date at which the alarm will alert. This schedule is absolute and does not change when device timezone changes. In this example, I set up an alarm to go off for the WWDC Keynote. I create the date components for June 9th at 9:41 am. I then use those components to create the date.

  Next, I pass the date to my alarm schedule using its fixed initializer.

  I can also specify a relative schedule for my alarm. This includes the time of day and optional weekly recurrence pattern. Relative schedule accounts for timezone changes.

  In this example, I’m setting the alarm to go off at 7 am every Monday, Wednesday, and Friday. I set the hour and the minute for the time portion and specify the daily occurrence.

  Now that you’re familiar with how to schedule an alarm, let’s move onto customizing alarm appearance. There are a number of elements you can customize.

  I want to create a cooking timer in my app, and I want to customize how the alert appears when it goes off. I start off by creating the alert button, which is done using the AlarmButton struct. It allows me to specify the text, textColor, and the systemImage of the button.

  I use it to define the stop button, which will be titled “Dismiss”, and have a white text color.

  It will also include an SF Symbol, which will be used when the alert is shown in the dynamic island.

  I can now create the alert presentation and set the alarm title, stating that food is done. I also include the stop button I just created.

  Next, I will create the alarm attributes. Think of this as the information required to render the presentations of your alarm. I will pass the alert presentation I just created in the presentation parameter.

  Lastly, I will create alarm configuration. Think of this as all the pieces required to schedule an alarm, including a countdown duration, a schedule, and the attributes.

  I will pass the attributes to the alarm configuration.

  I have now set up my alarm alert presentation with a dismiss button.

  If your alarm just needs to show an alert, this is all you need to do to set up its appearance.

  But if you would like your alarm to show a countdown interface, there are a few more steps you need to take. I’ll go through those for my cooking alarm next.

  I will first add a repeat button to my alert to trigger a countdown.

  I create the repeat button using the AlarmButton struct and set its title to repeat. I will also specify a white text color, and a repeat icon, which will appear when the alarm alerts in the Dynami Island.

  When I create the alert presentation I now also include my repeat button.

  The secondaryButton behavior parameter, specifies whether the secondary button transitions the alarm to the countdown state, like repeating a timer or snoozing an alarm, or whether it executes a custom action. When my repeat button is tapped, I want the alert to transition to a countdown in this case. I specify this by setting secondaryButtonBehavior to countdown.

  Just like before, I will create the alarm attributes with the alert presentation, and then the AlarmConfiguration including those attributes.

  I have now added a repeat button to my alert that will start a countdown. Next, I need to implement a Live Activity to show the UI for my countdown. If your alarm supports countdown functionality, your app is required to implement it using a Live Activity. I will do that next. I will create a countdown to inform me when the food is done cooking. It will appear on the Lock Screen, in the Dynamic Island, and in StandBy.

  If you know how to build a Live Activity, you already know how to create a custom interface for your countdown. You will need to add your countdown Live Activity to your app’s widget extension.

  If you don’t have one, do not get alarmed! You can get started by watching the WWDC23 video called “Meet ActivityKit”. You will then set up an ActivityConfiguration, and specify AlarmAttributes with your metadata type.

  In this case, I can set up an ActivityConfiguration and specify that it will use alarm attributes and my CookingData metadata. I will first focus on the Lock Screen.

  My alarm countdown can be in a countdown or paused state. I’ll provide a corresponding view for each of these states.

  To do that, I check the current mode of the alarm in the context object and render the appropriate view.

  I first handle the countdown state and provide my countdown view.

  Next, I handle the paused state and provide my paused view.

  I will now set up the expanded regions of the Dynamic Island appearance. They contain my alarm title, countdown, and buttons. I then set up the compact and minimal Dynamic Island views. These will contain my alarm countdown and an icon. Now that I’ve set up my basic Live Activity countdown, I’d like to add an icon to indicate how the food is being cooked. I can provide this additional information in my alarm metadata.

  My CookingData is a struct that conforms to the AlarmMetadata protocol. I define a string enum to specify the method of cooking and include frying and grilling as options. I then create a property to store my method of cooking.

  I am now ready to use my cooking data metadata. When scheduling the alarm in my app, I create the cooking data object and specify frying as the method of cooking.

  I then include this custom metadata when creating the alarm attributes.

  In my Live Activity, I will access the method of cooking in my custom metadata using the context attributes.

  I can then use the method of cooking to create an icon. Now, when my countdown is rendered, it has the frying icon I generated using the method of cooking in my cooking metadata. I use it both on the Lock Screen and in the Dynamic Island.

  I have now successfully set up my alarm countdown using a Live Activity. I also created a custom icon for my alarm countdown using alarm metadata.

  If your alarm supports countdown functionality, the system will guarantee that a countdown interface will be shown. In some cases, your Live Activity cannot be shown, for example, after device restarts and before it’s first unlocked. In that case, you can still customize the system's presentation of your countdown.

  I will now set up the system presentation for my cooking alarm countdown. I will start by defining the paused button using the AlarmButton struct. And set it to have a pause system icon.

  Next, I’ll create the countdown presentation and set the title to say that the food is cooking, and include my pause button.

  Now that I have defined the countdown presentation, I will include it as part of my alarm attributes. Because my alarm supports pause functionality, I will also set up the paused system presentation for my cooking countdown.

  When my countdown is paused, I want people to be able to resume it. I start by defining a resume button using the AlarmButton struct. And setting it to have a play icon.

  I then create the paused presentation and set the title to cooking being paused.

  I also pass in my resume button.

  I can now add my paused presentation to my alarm attributes.

  I have now handled the alert, countdown, and paused system presentations. Let’s take a moment to talk about the tint color. It is used throughout these presentations and helps people associate your alarm to your app. I pass it as part of my alarm attributes. In the alert presentation, it is used to set the fill color of the secondary button.

  On the lock screen, it is used to tint the symbol in the secondary button as well as the alarm title and the countdown.

  Similarly, it is used in the Dynamic Island. Now that you are familiar with setting up the alarm appearance, let’s move onto customizing its actions. AlarmKit gives you the ability to run your own code when someone taps an alarm button. You can do this using an app intent. You can provide a custom app intent for the stop button or for the secondary button.

  Let’s create a custom secondary button that will execute an app intent to open my app when tapped. To accomplish that, I will need to modify the alert appearance. I start off by creating an open button using the AlarmButton struct. It will be titled “Open”, have a white text color and an arrow icon in the Dynamic Island.

  When I create the alert presentation, I will include the open button as the secondary button.

  Because I want this button to execute a custom action, I will change the secondary button behavior to custom.

  My custom secondary button is now ready.

  Let’s set up an action using an app intent to open my app when the button is tapped.

  This is the open app intent I’d like to use. It includes the alarm identifier for which the button was tapped. It also sets the openAppWhenRun flag to true to indicate that I want my app to be opened when the intent is executed.

  Once my app is opened, I can do additional tasks like show a more detailed view for the alarm with that identifier.

  Let’s use the intent I just created.

  When scheduling the alarm, I create a unique identifier that allows me to track that alarm after creation.

  I create an instance of the OpenInApp intent, and pass in the unique identifier of the alarm.

  When I create my alarm configuration, I now include the secondary intent to indicate to the system that this is the intent I would like it to run when secondary button is tapped.

  I have now added a custom open button to my alert, defined an app intent to open my app, and indicated to the system to run that intent when the open button is tapped. Let’s now take a moment to talk about how to configure the sound of your alarm. If you don’t specify a sound parameter, your alarm will use a default system sound. You can also provide a custom sound for your alarm.

  Because AlarmKit uses ActivityKit for alarm presentation, you can define a custom sound by using its AlertSound struct.

  You will need to specify the name of the sound file, which should be either in your app’s main bundle or Library/Sounds folder of your app’s data container. Once you have finished setting up your alarm, you are now ready to manage it in the system. You can do so using the AlarmManager class. After I’ve configured my alarm, I can schedule it with the system. I can do so by using the alarm's unique identifier and the configuration I created earlier. This identifier should be used to track the alarm through its lifecycle.

  You have full control over the lifecycle of the alarm. You can transition it to a countdown state, as well as cancel, stop, pause, or resume it.

  I'd like to leave you with a few best practices when using AlarmKit. Alarms are a great fit for countdowns with a specific interval, like a cooking timer, or recurring alerts with a schedule, like a wake-up alarm. They are not a replacement for other prominent notifications, like critical alerts or time-sensitive notifications.

  Aim for clarity with your alert presentation. Alerts are prominently displayed, and you'll want to make it easy for someone to understand what the alarm is, and what actions they can take.

  If your alarm supports a countdown, consider including the key elements of the countdown in your Live Activity. This includes the remaining duration, a dismiss button, and a pause or resume button. Today, you learned how to use AlarmKit to create alarms and manage their lifecycle in the system. You are now ready to try it in your app. Use AlarmKit to configure alarms for your app’s use cases. Create custom countdown experiences on the Lock Screen and in the Dynamic Island with Live Activities. Add custom actions to your alarms using App Intents.

  That’s all there is time for. Thanks for joining!
* + Copy Code

    2:41 - [Check authorization status](/videos/play/wwdc2025/230/?time=161)

    ```
    // Check authorization status

    import AlarmKit

    func checkAuthorization() {

      switch AlarmManager.shared.authorizationState {
        case .notDetermined:
          // Manually request authorization
        case .authorized:
          // Proceed with scheduling
        case .denied:
          // Inform status is not authorized
      }

    }
    ```
  + Copy Code

    4:08 - [Set up the countdown duration](/videos/play/wwdc2025/230/?time=248)

    ```
    // Set up the countdown duration

    import AlarmKit

    func scheduleAlarm() {

      /* ... */

      let countdownDuration = Alarm.CountdownDuration(preAlert: (10 * 60), postAlert: (5 * 60))

      /* ... */
    }
    ```
  + Copy Code

    4:40 - [Set a fixed schedule](/videos/play/wwdc2025/230/?time=280)

    ```
    // Set a fixed schedule

    import AlarmKit

    func scheduleAlarm() {

      /* ... */

      let keynoteDateComponents = DateComponents(
        calendar: .current,
        year: 2025,
        month: 6,
        day: 9,
        hour: 9,
        minute: 41)
      let keynoteDate = Calendar.current.date(from: keynoteDateComponents)!
      let scheduleFixed = Alarm.Schedule.fixed(keynoteDate)

      /* ... */

    }
    ```
  + Copy Code

    5:13 - [Set a relative schedule](/videos/play/wwdc2025/230/?time=313)

    ```
    // Set a relative schedule

    import AlarmKit

    func scheduleAlarm() {

      /* ... */

      let time = Alarm.Schedule.Relative.Time(hour: 7, minute: 0)
      let recurrence = Alarm.Schedule.Relative.Recurrence.weekly([
        .monday,
        .wednesday,
        .friday
      ])

      let schedule = Alarm.Schedule.Relative(time: time, repeats: recurrence)

      /* ... */

    }
    ```
  + Copy Code

    5:43 - [Set up alert appearance with dismiss button](/videos/play/wwdc2025/230/?time=343)

    ```
    // Set up alert appearance with dismiss button

    import AlarmKit

    func scheduleAlarm() async throws {
        typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<CookingData>

        let id = UUID()
        let duration = Alarm.CountdownDuration(preAlert: (10 * 60), postAlert: (5 * 60))

        let stopButton = AlarmButton(
            text: "Dismiss",
            textColor: .white,
            systemImageName: "stop.circle")

        let alertPresentation = AlarmPresentation.Alert(
            title: "Food Ready!",
            stopButton: stopButton)

        let attributes = AlarmAttributes<CookingData>(
            presentation: AlarmPresentation(
                alert: alertPresentation),
            tintColor: Color.green)

        let alarmConfiguration = AlarmConfiguration(
            countdownDuration: duration,
            attributes: attributes)

        try await AlarmManager.shared.schedule(id: id, configuration: alarmConfiguration)
    }
    ```
  + Copy Code

    7:17 - [Set up alert appearance with repeat button](/videos/play/wwdc2025/230/?time=437)

    ```
    // Set up alert appearance with repeat button

    import AlarmKit

    func scheduleAlarm() async throws {
        typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<CookingData>

        let id = UUID()
        let duration = Alarm.CountdownDuration(preAlert: (10 * 60), postAlert: (5 * 60))

        let stopButton = AlarmButton(
            text: "Dismiss",
            textColor: .white,
            systemImageName: "stop.circle")

        let repeatButton = AlarmButton(
            text: "Repeat",
            textColor: .white,
            systemImageName: "repeat.circle")

        let alertPresentation = AlarmPresentation.Alert(
            title: "Food Ready!",
            stopButton: stopButton,
            secondaryButton: repeatButton,
            secondaryButtonBehavior: .countdown)

        let attributes = AlarmAttributes<CookingData>(
            presentation: AlarmPresentation(alert: alertPresentation),
            tintColor: Color.green)

        let alarmConfiguration = AlarmConfiguration(
            countdownDuration: duration,
            attributes: attributes)

        try await AlarmManager.shared.schedule(id: id, configuration: alarmConfiguration)
    }
    ```
  + Copy Code

    9:15 - [Create a Live Activity for a countdown](/videos/play/wwdc2025/230/?time=555)

    ```
    // Create a Live Activity for a countdown

    import AlarmKit
    import ActivityKit
    import WidgetKit

    struct AlarmLiveActivity: Widget {

      var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlarmAttributes<CookingData>.self) { context in

          switch context.state.mode {
          case .countdown:
            countdownView(context)
          case .paused:
            pausedView(context)
          case .alert:
            alertView(context)
          }

        } dynamicIsland: { context in

          DynamicIsland {
            DynamicIslandExpandedRegion(.leading) {
              leadingView(context)
            }
            DynamicIslandExpandedRegion(.trailing) {
              trailingView(context)
            }
          } compactLeading: {
            compactLeadingView(context)
          } compactTrailing: {
            compactTrailingView(context)
          } minimal: {
            minimalView(context)
          }

        }
      }
    }
    ```
  + Copy Code

    10:26 - [Create custom metadata for the Live Activity](/videos/play/wwdc2025/230/?time=626)

    ```
    // Create custom metadata for the Live Activity

    import AlarmKit

    struct CookingData: AlarmMetadata {
      let method: Method

      init(method: Method) {
        self.method = method
      }

      enum Method: String, Codable {
        case frying = "frying.pan"
        case grilling = "flame"
      }
    }
    ```
  + Copy Code

    10:43 - [Provide custom metadata to the Live Activity](/videos/play/wwdc2025/230/?time=643)

    ```
    // Provide custom metadata to the Live Activity

    import AlarmKit

    func scheduleAlarm() async throws {
        typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<CookingData>

        let id = UUID()
        let duration = Alarm.CountdownDuration(preAlert: (10 * 60), postAlert: (5 * 60))
        let customMetadata = CookingData(method: .frying)

        let stopButton = AlarmButton(
            text: "Dismiss",
            textColor: .white,
            systemImageName: "stop.circle")

        let repeatButton = AlarmButton(
            text: "Repeat",
            textColor: .white,
            systemImageName: "repeat.circle")

        let alertPresentation = AlarmPresentation.Alert(
            title: "Food Ready!",
            stopButton: stopButton,
            secondaryButton: repeatButton,
            secondaryButtonBehavior: .countdown)

        let attributes = AlarmAttributes<CookingData>(
            presentation: AlarmPresentation(alert: alertPresentation),
            metadata: customMetadata,
            tintColor: Color.green)

        let alarmConfiguration = AlarmConfiguration(
            countdownDuration: duration,
            attributes: attributes)

        try await AlarmManager.shared.schedule(id: id, configuration: alarmConfiguration)
    }
    ```
  + Copy Code

    11:01 - [Use custom metadata in the Live Activity](/videos/play/wwdc2025/230/?time=661)

    ```
    // Use custom metadata in the Live Activity

    import AlarmKit
    import ActivityKit
    import WidgetKit

    struct AlarmLiveActivity: Widget {

      var body: some WidgetConfiguration { /* ... */ }

      func alarmIcon(context: ActivityViewContext<AlarmAttributes<CookingData>>) -> some View {
        let method = context.attributes.metadata?.method ?? .grilling
        return Image(systemName: method.rawValue)
      }

    }
    ```
  + Copy Code

    12:03 - [Set up the system countdown appearance](/videos/play/wwdc2025/230/?time=723)

    ```
    // Set up the system countdown appearance

    import AlarmKit

    func scheduleAlarm() async throws {
      typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<CookingData>

      let id = UUID()
      let duration = Alarm.CountdownDuration(preAlert: (10 * 60), postAlert: (5 * 60))
      let customMetadata = CookingData(method: .frying)

      let stopButton = AlarmButton(
        text: "Dismiss",
        textColor: .white,
        systemImageName: "stop.circle")

      let repeatButton = AlarmButton(
        text: "Repeat",
        textColor: .white,
        systemImageName: "repeat.circle")

      let alertPresentation = AlarmPresentation.Alert(
        title: "Food Ready!",
        stopButton: stopButton,
        secondaryButton: repeatButton,
        secondaryButtonBehavior: .countdown)

      let pauseButton = AlarmButton(
        text: "Pause",
        textColor: .green,
        systemImageName: "pause")

      let countdownPresentation = AlarmPresentation.Countdown(
        title: "Cooking",
        pauseButton: pauseButton)

      let attributes = AlarmAttributes<CookingData>(
        presentation: AlarmPresentation(
          alert: alertPresentation,
          countdown: countdownPresentation),
        metadata: customMetadata,
        tintColor: Color.green)

      let alarmConfiguration = AlarmConfiguration(
        countdownDuration: duration,
        attributes: attributes)

      try await AlarmManager.shared.schedule(id: id, configuration: alarmConfiguration)

    }
    ```
  + Copy Code

    12:43 - [Set up the system paused appearance](/videos/play/wwdc2025/230/?time=763)

    ```
    // Set up the system paused appearance

    import AlarmKit

    func scheduleAlarm() async throws {
      typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<CookingData>

      let id = UUID()
      let duration = Alarm.CountdownDuration(preAlert: (10 * 60), postAlert: (5 * 60))
      let customMetadata = CookingData(method: .frying)

      let stopButton = AlarmButton(
        text: "Dismiss",
        textColor: .white,
        systemImageName: "stop.circle")

      let repeatButton = AlarmButton(
        text: "Repeat",
        textColor: .white,
        systemImageName: "repeat.circle")

      let alertPresentation = AlarmPresentation.Alert(
        title: "Food Ready!",
        stopButton: stopButton,
        secondaryButton: repeatButton,
        secondaryButtonBehavior: .countdown)

      let pauseButton = AlarmButton(
        text: "Pause",
        textColor: .green,
        systemImageName: "pause")

      let countdownPresentation = AlarmPresentation.Countdown(
        title: "Cooking",
        pauseButton: pauseButton)

      let resumeButton = AlarmButton(
        text: "Resume",
        textColor: .green,
        systemImageName: "play")

      let pausedPresentation = AlarmPresentation.Paused(
        title: "Paused",
        resumeButton: resumeButton)

      let attributes = AlarmAttributes<CookingData>(
        presentation: AlarmPresentation(
          alert: alertPresentation,
          countdown: countdownPresentation,
          paused: pausedPresentation),
        metadata: customMetadata,
        tintColor: Color.green)

      let alarmConfiguration = AlarmConfiguration(
        countdownDuration: duration,
        attributes: attributes)

      try await AlarmManager.shared.schedule(id: id, configuration: alarmConfiguration)

    }
    ```
  + Copy Code

    14:09 - [Add a custom button](/videos/play/wwdc2025/230/?time=849)

    ```
    // Add a custom button

    import AlarmKit
    import AppIntents

    func scheduleAlarm() async throws {
      typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<CookingData>

      let id = UUID()
      let duration = Alarm.CountdownDuration(preAlert: (10 * 60), postAlert: (5 * 60))
      let customMetadata = CookingData(method: .frying)
      let secondaryIntent = OpenInApp(alarmID: id.uuidString)

      let stopButton = AlarmButton(
        text: "Dismiss",
        textColor: .white,
        systemImageName: "stop.circle")

      let openButton = AlarmButton(
        text: "Open",
        textColor: .white,
        systemImageName: "arrow.right.circle.fill")

      let alertPresentation = AlarmPresentation.Alert(
        title: "Food Ready!",
        stopButton: stopButton,
        secondaryButton: openButton,
        secondaryButtonBehavior: .custom)

      let pauseButton = AlarmButton(
        text: "Pause",
        textColor: .green,
        systemImageName: "pause")

      let countdownPresentation = AlarmPresentation.Countdown(
        title: "Cooking",
        pauseButton: pauseButton)

      let resumeButton = AlarmButton(
        text: "Resume",
        textColor: .green,
        systemImageName: "play")

      let pausedPresentation = AlarmPresentation.Paused(
        title: "Paused",
        resumeButton: resumeButton)

      let attributes = AlarmAttributes<CookingData>(
        presentation: AlarmPresentation(
          alert: alertPresentation,
          countdown: countdownPresentation,
          paused: pausedPresentation),
        metadata: customMetadata,
        tintColor: Color.green)

      let alarmConfiguration = AlarmConfiguration(
        countdownDuration: duration,
        attributes: attributes,
        secondaryIntent: secondaryIntent)

      try await AlarmManager.shared.schedule(id: id, configuration: alarmConfiguration)

    }

    public struct OpenInApp: LiveActivityIntent {
        public func perform() async throws -> some IntentResult { .result() }

        public static var title: LocalizedStringResource = "Open App"
        public static var description = IntentDescription("Opens the Sample app")
        public static var openAppWhenRun = true

        @Parameter(title: "alarmID")
        public var alarmID: String

        public init(alarmID: String) {
            self.alarmID = alarmID
        }

        public init() {
            self.alarmID = ""
        }
    }
    ```
  + Copy Code

    16:10 - [Add a custom sound](/videos/play/wwdc2025/230/?time=970)

    ```
    // Add a custom sound

    import AlarmKit
    import AppIntents

    func scheduleAlarm() async throws {
      typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<CookingData>

      let id = UUID()
      let duration = Alarm.CountdownDuration(preAlert: (10 * 60), postAlert: (5 * 60))
      let customMetadata = CookingData(method: .frying)
      let secondaryIntent = OpenInApp(alarmID: id.uuidString)

      let stopButton = AlarmButton(
        text: "Dismiss",
        textColor: .white,
        systemImageName: "stop.circle")

      let openButton = AlarmButton(
        text: "Open",
        textColor: .white,
        systemImageName: "arrow.right.circle.fill")

      let alertPresentation = AlarmPresentation.Alert(
        title: "Food Ready!",
        stopButton: stopButton,
        secondaryButton: openButton,
        secondaryButtonBehavior: .custom)

      let pauseButton = AlarmButton(
        text: "Pause",
        textColor: .green,
        systemImageName: "pause")

      let countdownPresentation = AlarmPresentation.Countdown(
        title: "Cooking",
        pauseButton: pauseButton)

      let resumeButton = AlarmButton(
        text: "Resume",
        textColor: .green,
        systemImageName: "play")

      let pausedPresentation = AlarmPresentation.Paused(
        title: "Paused",
        resumeButton: resumeButton)

      let attributes = AlarmAttributes<CookingData>(
        presentation: AlarmPresentation(
          alert: alertPresentation,
          countdown: countdownPresentation,
          paused: pausedPresentation),
        metadata: customMetadata,
        tintColor: Color.green)

      let sound = AlertConfiguration.AlertSound.named("Chime")

      let alarmConfiguration = AlarmConfiguration(
        countdownDuration: duration,
        attributes: attributes,
        secondaryIntent: secondaryIntent,
        sound: sound)

      try await AlarmManager.shared.schedule(id: id, configuration: alarmConfiguration)

    }

    public struct OpenInApp: LiveActivityIntent {
        public func perform() async throws -> some IntentResult { .result() }

        public static var title: LocalizedStringResource = "Open App"
        public static var description = IntentDescription("Opens the Sample app")
        public static var openAppWhenRun = true

        @Parameter(title: "alarmID")
        public var alarmID: String

        public init(alarmID: String) {
            self.alarmID = alarmID
        }

        public init() {
            self.alarmID = ""
        }
    }
    ```
* + 0:00 - [Welcome](/videos/play/wwdc2025/230/?time=0)
  + AlarmKit is a new framework you can use to create timers and alarms. Learn about the experience, getting authorization, creating alarms, and managing their lifecycle.
  + 0:32 - [Overview](/videos/play/wwdc2025/230/?time=32)
  + Alarms are scheduled alerts that break through silent mode, displaying a custom title and app name. They can also show a countdown UI.
    People can stop, snooze, or interact with custom buttons. Alarms are visible on Lock Screen, Dynamic Island, StandBy, and Apple Watch, and people must opt-in per app.
  + 1:39 - [Authorization](/videos/play/wwdc2025/230/?time=99)
  + To enable alarm scheduling in an app, people must authorize it. This can be done automatically upon creating the first alarm or manually via the AlarmManager's 'requestAuthorization' API.
    You must add 'NSAlarmKitUsageDescription' to the Info.plist explaining how alarms are used. People can change authorization status in Settings.
    Before scheduling an alarm, the app can check authorization status; if denied, it should let people know that alarms won't be scheduled.
  + 3:06 - [Creation](/videos/play/wwdc2025/230/?time=186)
  + Creating an alarm involves several key components. First, the alarm can be set with a countdown duration, which can include both a pre-alert and post-alert interval. When the alarm is scheduled with a countdown, a countdown UI for the pre-alert duration. Once this time elapses, the alarm fires, showing a customized alert UI. If the alarm is snoozed, the countdown UI reappears for the post-alert interval before firing again.
    Alarms can be scheduled using either a fixed or relative schedule. A fixed schedule specifies a single future date and time, while a relative schedule allows for a daily time of day with an optional weekly recurrence pattern, ensuring the alarm adjusts correctly for time zone changes.
    In addition to scheduling, you can also customize the appearance of the alarm. This includes creating and configuring alert buttons, such as a 'Dismiss' button, and setting the alarm title. For alarms with countdown functionality, you can also add a 'Repeat' button. The alert presentation and attributes are then defined to specify how the alarm looks and behaves when it goes off.
    If an alarm includes countdown functionality, you must implement a Live Activity to display the countdown UI on the Lock Screen, Dynamic Island, and StandBy. This involves creating a custom interface for the countdown and setting up an 'ActivityConfiguration' with the appropriate alarm attributes. The Live Activity can display different views depending on whether the countdown is active or paused, providing a seamless user experience across various device states.
    The example introduces custom metadata to pass extra information to the Live Activity. This metadata includes a custom enum, allowing the alarm to display an icon based on the enum's value on both the Lock Screen and in the Dynamic Island during the countdown.
    The session describes how to create custom App Intents to run specific code when buttons are tapped, such as opening the app. It also describes how to configure the alarm sound, allowing people to choose a custom sound or use the default system sound.
  + 16:32 - [Life cycle](/videos/play/wwdc2025/230/?time=992)
  + AlarmKit allows people to create, schedule, and manage alarms using the 'AlarmManager' class. Alarms can be configured, tracked via unique identifiers, and put into various states (countdown, paused, stopped, etc.). Best practices include using alarms for countdowns and recurring alerts, ensuring clear alert presentation, and including all essential information and actions in the countdown Live Activity.

## Developer Footer

- [Videos](/videos/)
- [WWDC25](/videos/wwdc2025/)
- Wake up to the AlarmKit API

### Platforms

 [Open Menu](#footer-directory-column-section-state-platform)
Close Menu

* [iOS](/ios/)
* [iPadOS](/ipados/)
* [macOS](/macos/)
* [tvOS](/tvos/)
* [visionOS](/visionos/)
* [watchOS](/watchos/)

### Tools

 [Open Menu](#footer-directory-column-section-state-tools)
Close Menu

* [Swift](/swift/)
* [SwiftUI](/swiftui/)
* [Swift Playground](/swift-playground/)
* [TestFlight](/testflight/)
* [Xcode](/xcode/)
* [Xcode Cloud](/xcode-cloud/)
* [SF Symbols](/sf-symbols/)

### Topics & Technologies

 [Open Menu](#footer-directory-column-section-state-topics)
Close Menu

* [Accessibility](/accessibility/)
* [Accessories](/accessories/)
* [App Extensions](/app-extensions/)
* [App Store](/app-store/)
* [Audio & Video](/audio/)
* [Augmented Reality](/augmented-reality/)
* [Design](/design/)
* [Distribution](/distribute/)
* [Education](/education/)
* [Fonts](/fonts/)
* [Games](/games/)
* [Health & Fitness](/health-fitness/)
* [In-App Purchase](/in-app-purchase/)
* [Localization](/localization/)
* [Maps & Location](/maps/)
* [Machine Learning](/machine-learning/)
* [Open Source](https://opensource.apple.com)
* [Security](/security/)
* [Safari & Web](/safari/)

### Resources

 [Open Menu](#footer-directory-column-section-state-resources)
Close Menu

* [Documentation](/documentation/)
* [Tutorials](/learn/)
* [Downloads](/download/)
* [Forums](/forums/)
* [Videos](/videos/)

### Support

 [Open Menu](#footer-directory-column-section-state-support)
Close Menu

* [Support Articles](/support/articles/)
* [Contact Us](/contact/)
* [Bug Reporting](/bug-reporting/)
* [System Status](/system-status/)

### Account

 [Open Menu](#footer-directory-column-section-state-account)
Close Menu

* [Apple Developer](/account/)
* [App Store Connect](https://appstoreconnect.apple.com/)
* [Certificates, IDs, & Profiles](/account/ios/certificate/)
* [Feedback Assistant](https://feedbackassistant.apple.com/)

### Programs

 [Open Menu](#footer-directory-column-section-state-programs)
Close Menu

* [Apple Developer Program](/programs/)
* [Apple Developer Enterprise Program](/programs/enterprise/)
* [App Store Small Business Program](/app-store/small-business-program/)
* [MFi Program](https://mfi.apple.com/)
* [News Partner Program](/programs/news-partner/)
* [Video Partner Program](/programs/video-partner/)
* [Security Bounty Program](/security-bounty/)
* [Security Research Device Program](/programs/security-research-device/)

### Events

 [Open Menu](#footer-directory-column-section-state-events)
Close Menu

* [Meet with Apple](/events/)
* [Apple Developer Centers](/events/developer-centers/)
* [App Store Awards](/app-store/app-store-awards/)
* [Apple Design Awards](/design/awards/)
* [Apple Developer Academies](/academies/)
* [WWDC](/wwdc/)

Get the [Apple Developer app](https://apps.apple.com/us/app/apple-developer/id640199958).

Light

Dark

Auto

Copyright © 2025 [Apple Inc.](https://www.apple.com) All rights reserved.
[Terms of Use](https://www.apple.com/legal/internet-services/terms/site.html)
[Privacy Policy](https://www.apple.com/legal/privacy/)
[Agreements and Guidelines](/support/terms/)


