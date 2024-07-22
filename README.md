# Stytch iOS UIKit example application

<p align="center">
  <img src="https://github.com/stytchauth/stytch-ios-uikit-example/assets/99769393/e73cea5c-da47-4f74-b28e-da4d550b4d8d" height="400">
</p>

## Overview

This example application demonstrates how one may use Stytch within a UIKit iOS application.

This project uses Stytch's [iOS SDK](https://stytchauth.github.io/stytch-swift/documentation/stytchcore/) which provides headless methods to securely interact with Stytch.

This application features SMS OTP as well as Apple and Google OAuth authentication. You can use this application's source code as a learning resource, or use it as a jumping off point for your own project. We are excited to see what you build with Stytch!

## Set up

Follow the steps below to get this application fully functional and running using your own Stytch credentials.

### In the Stytch Dashboard

1. Create a [Stytch](https://stytch.com/) account. Once your account is set up a Project called "My first project" will be automatically created for you.

1. Within your new Project, navigate to [SDK configuration](https://stytch.com/dashboard/sdk-configuration), and make the following changes:

   - Click **Enable SDK in Test**.
   - Under **Authorized applications** add the Bundle ID `com.stytch.UIKitExample`.
     
     <img width="400" alt="Authorized applications" src="https://user-images.githubusercontent.com/99769393/224113711-4b66b298-c92d-4ee8-a0f3-991253d73eff.jpg">

1. Navigate to [Redirect URLs](https://stytch.com/dashboard/redirect-urls), and add `uikit-example://login` as type **Login** and `uikit-example://signup` as type **Sign-up**.
   
   <img width="400" alt="Redirect URLs" src="https://user-images.githubusercontent.com/99769393/224113848-bf673aa0-5299-488f-9aff-e78fea636e2b.jpg">

1. Navigate to [OAuth](https://stytch.com/dashboard/oauth), and set up login for Apple and Google in the Test environment. Follow all the instructions provided in the Dashboard. If you are not interested in OAuth login you can skip this step. However, the _Continue with Apple_ and _Continue with Google_ buttons in this application will not work. _NOTE: for this example app's Apple OAuth config, only Team ID and Application ID fields require real data, the other fields can be stubbed out with fake data._
 
   <img width="600" alt="OAuth configuration" src="https://user-images.githubusercontent.com/99769393/224114896-2c4862d7-38b2-47b3-bff5-3d41a6abf995.jpg">
1. Finally, navigate to [API Keys](https://stytch.com/dashboard/api-keys), and copy your `public_token`. You will need this value later on.

### On your machine

In your terminal clone the repo and open the Xcode project:

```bash
git clone https://github.com/stytchauth/stytch-ios-uikit-example.git
cd stytch-ios-uikit-example
xed UIKitExample/UIKitExample.xcodeproj
```

Next, replace the `YOUR TOKEN` placeholder with your `public_token` in HomeViewController.swift. In a production scenario, you might fetch this token from your backend, or embed in a StytchConfiguration.plist file.

## Running the app

After completing all the set up steps above the application can be run as normally from Xcode.

You'll be able to login with SMS OTP, Sign In With Apple, or Google OAuth and see your values from your Stytch User object as well as see how logging out works.

## Next steps

This example app showcases a small portion of what you can accomplish with Stytch. Here are a few ideas to explore:

1. Add additional login methods like [Passwords](https://stytchauth.github.io/stytch-swift/documentation/stytchcore/stytchclient/passwords-swift.struct) or [Biometrics](https://stytchauth.github.io/stytch-swift/documentation/stytchcore/stytchclient/biometrics-swift.struct).
1. Take advantage of the SDK's [headless methods](https://stytchauth.github.io/stytch-swift/documentation/stytchcore) and replace the included UI with your own look and feel.
1. Use [Stytch Sessions](https://stytch.com/docs/sessions) to secure your backend.

## Get help and join the community

#### :speech_balloon: Stytch community Slack

Join the discussion, ask questions, and suggest new features in our ​[Slack community](https://stytch.com/docs/resources/support/overview)!

#### :question: Need support?

Check out the [Stytch Forum](https://forum.stytch.com/) or email us at [support@stytch.com](mailto:support@stytch.com).
