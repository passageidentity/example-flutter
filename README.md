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
To get this example Flutter app working with your Passage account/app, you'll need to swap out the placeholder app id and authentication origin with your own. Learn more about Passage app ids and auth origins [here](https://docs.passage.id/console-administration/apps#app-core-settings).


### iOS
In the `Passage.plist` file ([found here](https://github.com/passageidentity/example-flutter/blob/main/ios/Runner/Passage.plist)) replace `YOUR_APP_ID` and `YOUR_AUTH_ORIGIN` with your app’s Passage app id and auth origin, respectively.

```xml
<plist version="1.0">
  <dict>
    <key>appId</key>
    <string>YOUR_APP_ID</string>
    <key>authOrigin</key>
    <string>YOUR_AUTH_ORIGIN</string>
  </dict>
</plist>
```

Also, you'll need to replace `YOUR_AUTH_ORIGIN` in the Associated Domains file ([found here](https://github.com/passageidentity/example-flutter/blob/main/ios/Runner/Runner.entitlements)).
```xml
<plist version="1.0">
  <dict>
    <key>com.apple.developer.associated-domains</key>
    <array>
      <string>webcredentials:YOUR_APP_ID</string>
      <string>applinks:YOUR_APP_ID</string>
    </array>
  </dict>
</plist>
```

### Android

In the `strings.xml` file ([found here](https://github.com/passageidentity/example-flutter/blob/main/android/app/src/main/res/values/strings.xml)) replace `YOUR_APP_ID` and `YOUR_AUTH_ORIGIN` with your app’s Passage app id and auth origin, respectively.

```xml
<resources>
    <!-- Required Passage app settings -->
    <string name="passage_app_id">YOUR_APP_ID</string> 
    <string name="passage_auth_origin">YOUR_APP_ORIGIN</string>
    ...
</resources>
```

### Web

In the `index.html` file ([found here](https://github.com/passageidentity/example-flutter/blob/main/web/index.html)) replace `YOUR_APP_ID` with your app's Passage app id.

```html
<!-- This script adds the Passage -->
<script type="module">
  import { Passage } from "https://cdn.passage.id/passage-js.js";
  window.Passage = Passage;
  window.passageAppId = "YOUR_APP_ID";
</script>
```

Lastly, when you're running the web app locally you'll want to make sure your [Passage app auth origin](https://docs.passage.id/console-administration/apps#app-core-settings) and [Flutter web app port](https://www.kindacode.com/snippet/how-to-run-flutter-web-with-a-custom-port/) are set to the same localhost.


## 🚀 Run the app!

If all of the configuration was setup correctly, you should be able to run this application in the simulator or a real device!
