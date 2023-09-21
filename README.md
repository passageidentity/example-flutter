<img src="https://storage.googleapis.com/passage-docs/passage-logo-gradient.svg" alt="Passage logo" style="width:250px;"/>

# Example Flutter App with Passage Auth

### 🔑 The easiest way to get passkeys up and running for Flutter

[Passage](https://passage.id/) and the [Passage Flutter SDK](https://github.com/passageidentity/passage-flutter) were built to make passkey authentication as fast, simple, and secure as possible. This example application is a great place to start. Before using Passage in your own Flutter app, you can use this example app to:

- Plug in your own Passage app credentials to see passkeys in action
- Learn basic implementation of the Passage Flutter SDK

A successful registration flow will look like this:

<img src="https://storage.googleapis.com/passage-docs/passage-flutter-example.png" alt="Passage Flutter Example" />


## Requirements

- Android Studio Electric Eel or newer
- Xcode 14 or newer
- A Passage account and Passage app (you can register for a free account [here](https://passage.id/))
- Completed setup of
  - Associated Domains file (iOS) ([view instructions](https://docs.passage.id/mobile/ios/add-passage#step-1-publish-associated-domains-file))
  - Asset Links file (Android) ([view instructions](https://docs.passage.id/mobile/android/add-passage#step-1-publish-digital-asset-links-file))
  - Key hash registration (Android) ([view instructions](https://docs.passage.id/mobile/android/add-passage#step-2-register-your-android-app-with-passage))

## Installation

```sh
flutter pub add passage_flutter
```
<br>

## Configuration
To get this example Flutter app working with your Passage account/app, you'll need to swap out the placeholder authentication origin with your own. Learn more about Passage auth origins [here](https://docs.passage.id/console-administration/apps#app-core-settings).


### iOS
You'll need to replace `YOUR_AUTH_ORIGIN` in the Associated Domains file ([found here](https://github.com/passageidentity/example-flutter/blob/main/ios/Runner/Runner.entitlements)).
```xml
<plist version="1.0">
  <dict>
    <key>com.apple.developer.associated-domains</key>
    <array>
      <string>webcredentials:YOUR_AUTH_ORIGIN</string>
      <string>applinks:YOUR_AUTH_ORIGIN</string>
    </array>
  </dict>
</plist>
```

### Android

In the `strings.xml` file ([found here](https://github.com/passageidentity/example-flutter/blob/main/android/app/src/main/res/values/strings.xml)) replace `YOUR_AUTH_ORIGIN` with your app’s auth origin.

```xml
<resources>
    <!-- Required Passage app settings -->
    <string name="passage_auth_origin">YOUR_APP_ORIGIN</string>
    ...
</resources>
```

### Web

When you're running the web app locally you'll want to make sure your [Passage app auth origin](https://docs.passage.id/console-administration/apps#app-core-settings) and [Flutter web app port](https://www.kindacode.com/snippet/how-to-run-flutter-web-with-a-custom-port/) are set to the same localhost.


### Final step
Lastly, replace `YOUR_APP_ID` in the `passage_state_container.dart` file [here](https://github.com/passageidentity/example-flutter/blob/main/lib/state/passage_state_container.dart).

```dart
_passage = PassageFlutter('YOUR_APP_ID');
```


## 🚀 Run the app!

If all of the configuration was setup correctly, you should be able to run this application in the simulator or a real device!
