## Getting Started with Cordova Plugin for AZME
#### App Creation
Create a Sample Cordova App
```sh
cordova create <myAppName> <myAppBundleId> <myAppShortName>
```
Add the platform you'd like to support (iOS in this case)
```sh
cordova platform add ios
```
Retrieve your credentials for the AZURE Portal to configure the AZME plugin
```sh
cordova plugin add cordova-plugin-ms-azure-mobile-engagement --variable AZME_IOS_CONNECTION_STRING=<yourConnectionString> 
--variable AZME_ACTION_URL=myapp 
```
#### Send an activity to the AZME portal
Edit `www/js/index.js`to add the call to AZME to declare a new activity once the ``deviceReady``event is received.
```js
 onDeviceReady: function() {
        Engagement.startActivity("myPage",{});
    },
```
Launch your application...
```sh
cordova run ios
```
... a new session should appear in the AZME portal and you should see the following log in your iOS application
 ```log
[Engagement] Agent: Session started
[Engagement] Agent: Activity 'myPage' started
[Engagement] Connection: Established
[Engagement] Connection: Sent: appInfo
[Engagement] Connection: Sent: startSession
[Engagement] Connection: Sent: activity name='myPage'
```
#### Extend your app to add Reach Support
Edit `www/js/index.js`to add the call to AZME to request push new notification, and declare an handler
```js
 onDeviceReady: function() {
        Engagement.initializeReach(
            // on OpenUrl
            function(_url) { 
            alert(_url); 
            });
        Engagement.startActivity("myPage",{});
    },
```
Launch your application...
```sh
cordova run ios
```
... a popup should appear to the user to allow notifications

You can then create a Reach campaign with an Action URL ``myapp://test``

Activating the campaign shoud trigger the webview, and when the action button is being pressed, the alert box in the handler should be triggered 



