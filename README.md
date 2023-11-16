![Aptabase](https://aptabase.com/og.png)

# aptabase_flutter

[![pub package](https://img.shields.io/pub/v/aptabase_flutter.svg)](https://pub.dev/packages/aptabase_flutter)
[![pub points](https://img.shields.io/pub/points/aptabase_flutter?color=2E8B57&label=pub%20points)](https://pub.dev/packages/aptabase_flutter/score)

Instrument your app with Aptabase, an Open Source, Privacy-First, and Simple Analytics for Mobile, Desktop, and Web Apps.

## Platform Support

| Android | iOS | MacOS | Web | Linux | Windows |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ✔️    | ✔️  |  ✔️   | ✔️  |  ✔️   |   ✔️    |

## Install

You can install the SDK by running the following command:

```shell
pub add aptabase_flutter
```

## Usage

First, you need to get your `App Key` from Aptabase, you can find it in the `Instructions` menu on the left side menu.

On your `main.dart`, import `package:aptabase_flutter/aptabase_flutter.dart` and initialized the SDK.

```diff
void main() async {
+ WidgetsFlutterBinding.ensureInitialized();
+ await Aptabase.init("<YOUR_APP_KEY>"); // 👈 this is where you enter your App Key

  runApp(const MyApp());
}
```

`Note:` You need to change your main function to be `async` and call `WidgetsFlutterBinding.ensureInitialized();` before initializing the SDK.

Afterward, you can start tracking events with `Aptabase.instance` anywhere in your Dart. Here's an example:

```dart
import 'package:aptabase_flutter/aptabase_flutter.dart';

class _CounterState extends State<Counter> {
  int _counter = 0;

  // Tracking how many times the user has clicked the button, alongside the current counter value
  void _incrementCounter() {
    Aptabase.instance.trackEvent("increment", { "counter": _counter });
    
    setState(() {
      _counter++;
    });
  }
}
```

A few important notes:

1. The SDK will automatically enhance the event with some useful information, like the OS, the app version, and other things.
2. You're in control of what gets sent to Aptabase. This SDK does not automatically track any events, you need to call `trackEvent` manually.
    - Because of this, it's generally recommended to at least track an event at startup
3. You do not need to await for the `trackEvent` function, it'll run in the background.
3. Only strings and numbers values are allowed on custom properties

## About persistence

Use a dedicated db to store events.

The maximal amount of offline stored events is 100 by default. To change it, pass the desired value when instantiating AddEvent();

## Preparing for Submission to Apple App Store

When submitting your app to the Apple App Store, you'll need to fill out the `App Privacy` form. You can find all the answers on our [How to fill out the Apple App Privacy when using Aptabase](https://aptabase.com/docs/apple-app-privacy) guide.
