    
Cordova plugin for Azure Mobile Engagement
----

Introduction
--
This plugin integrates the Azure Mobile Engagement (AZME) SDK into your Cordova/PhoneGap Application. It supports both *reporting* and *push* features. 

*Please refer to the Azure Mobile Engagement documentation for more information about the various AZME concepts*.

Supported Platforms
--
* iOS
* Android

Installation
--
To install the plugin, just add it to your Cordova project using your proper AZME credentials through Cordova variables.
```sh
cd <your project>
cordova plugin add cordova-plugin-ms-azure-mobile-engagement --variable KEY=<value>
```
#### Generic Variables

- `AZME_ENABLE_LOG` : `true`|`false`, enable both plugin and AZME native logs
- `AZME_REDIRECT_URL` : the url schemes of your application when using redirect actions in your campaign. Must be the url prefix without :// (ex: `myapp` to handle urls such as `myapp://shop`)

#### iOS Variables
- `AZME_IOS_CONNECTION_STRING` : the iOS connection string (to retrieve from the AZME portal)
- `AZME_IOS_REACH_ICON` : the icon used for reach notification : must be the name of the resource with its extension (ex: `mynotificationicon.png`), and the icon file must be added into your iOS project with XCode (using the Add Files Menu)

#### Android Variables
- `AZME_ANDROID_CONNECTION_STRING` : the iOS connection string (to retrive from the AZME portal)
- `AZME_ANDROID_REACH_ICON` : the icon used for reach notification : must be the name of the resource without any extension, nor drawable prefix  (ex: `mynotificationicon`), and the icon file must be copied into your android project (`platforms/android/res/drawable)`
- `AZME_GOOGLE_PROJECT_NUMBER` : the project number used as the GCM (Google Cloud Messaging) sender ID
 
Only the `AZME_ANDROID_CONNECTION_STRING` and/or `AZME_IOS_CONNECTION_STRING` are required : all the other variables are optionals.

Example:
```sh
cordova plugin add cordova-plugin-ms-azure-mobile-engagement --variable AZME_IOS_CONNECTION_STRING=AZME_IOS_CONNECTION_STRING --variable AZME_ANDROID_CONNECTION_STRING=AZME_ANDROID_CONNECTION_STRING 
```
To remove the plugin,
```sh
cordova plugin rm cordova-plugin-ms-azure-mobile-engagement
```
Push Notification Support
--
To enable push notification on iOS, you  need to create a provision profile with push notifications support.

If you are using Xcode 7 and iOS 9, you have to perform the following additional steps:
* Set Enable Bitcode to No under Targets > Build Settings > set Enable Bitcode to Yes or No. (Make sure to select ALL from the top bar.)
* Enable Push Notifications in Targets > Your Target Name > Capabilities.


Methods
--
Once the `deviceready` event has been triggered by the Cordova framework, a `AzureEngagement` object is available to interact with the native AZME SDK.

* AzureEngagement.startActivity
* AzureEngagement.endActivity
* AzureEngagement.sendAppInfo
* AzureEngagement.startJob
* AzureEngagement.endJob
* AzureEngagement.sendEvent
* AzureEngagement.onOpenURL
* AzureEngagement.onDataPushReceived
* AzureEngagement.registerForPushNotification
* AzureEngagement.getStatus

### AzureEngagement.startActivity

Start a new activty  with the corresponding extra infos object.
```javascript
AzureEngagement.startActivity(_activityName, _extraInfos,[ _success], [_failure]);
```
##### Params
* `_activityName`: the name of the activity
* `_extraInfos`: a json object containing the extra infos attached to this activity

### AzureEngagement.endActivity
Ends the current Actvity. Would trigger a new session on the next startActivity
```javascript
AzureEngagement.endActivity([ _success], [_failure]);
```
### AzureEngagement.sendEvent
Send an event  with the corresponding extra infos object.
```javascript
AzureEngagement.sendEvent(_eventName, _extraInfos,[ _success], [_failure]);
```
##### Params
* `_eventName`: the name of the event
* `_extraInfos`: a json object containing the extra infos attached to this event

### AzureEngagement.startJob
Start an new job  with the corresponding extra infos object.
```javascript
AzureEngagement.startJob(_jobName, _extraInfos,[ _success], [_failure]);
```
##### Params
* `_jobName`: the name of the job
* `_extraInfos`: a json object containing the extra infos attached to this job

### AzureEngagement.endJob
End a job previously created by startJob
```javascript
AzureEngagement.endJob(_jobName,[ _success], [_failure]);
```
##### Params
* `_jobName`: the name of the job

### AzureEngagement.sendAppInfo
Send App Infos atttached to the currente device.
```javascript
AzureEngagement.sendAppInfo( _appInfos,[ _success], [_failure]);
```
##### Params
* `_appInfos`: the json object containing the app infos to be sent

### AzureEngagement.onOpenURL
Set an event handler when an application specific URL is triggered (from a push campaign for example). The URL scheme must match the one defined in the `$AZME_REDIRECT_URL` setting
```javascript
AzureEngagement.onOpenURL( _urlHandler,[ _success], [_failure]);
```
### Params
* `_urlHandler`:  the handler that is passed the url that has been triggerd

### Example
```javascript
    AzureEngagement.onOpenURL(function(_url) {
            console.log("user triggered url/action "+_url);
        });
```

### AzureEngagement.onDataPushReceived
Set an event handler when data are being pushed to your application
```javascript
AzureEngagement.onDataPushReceived( _dataPushHandler,[ _success], [_failure]);
```
#### Params
* `_dataPushHandler`:  the function handler to receive the data push. The function needs to accept two parameters : the `category` , and the `body` 

#### Notes
* If no category was defined during the creation of the data push, the category will contain `None`
* If the body contains non-text data, it will be  received encoded in base64 format 
  * If the data is an image, it can be directly displayed using the prefix  `data:image/png;base64` (cf. example)
  * If you want to extract the data bytes, you would need to use the `btoa()` function to convert base64 to binary

#### Example
```javascript
    AzureEngagement.onDataPushReceived(function(_category,_body) {
            if (_category=="png")
                str += '<img src="data:image/png;base64,'+_body+'" width="128" height="128" />';
            else
                str += _body;
            // ...
        });
```

### AzureEngagement.registerForPushNotification
Register the application to receive push notifications on iOS : this call will ask the user to autorize push notifications for your application, so it is recommended to trigger that call at the proper time (ie: once the users are engaged into your application)

```javascript
AzureEngagement.registerForPushNotification( [_success], [_failure]);
```
This function does nothing on platforms other than iOS. 
### AzureEngagement.getStatus
Returns information about the AZME plugin.
```javascript
AzureEngagement.getStatus( _statusCallback, [_failure]);
```
##### Params
* `_statusCallback`:  the handler that is passed a json object containing information about the AZME library

##### Example
```javascript
    AzureEngagement.getStatus(function(_info) {
            console.log("AZME SDK Version : "+_info.AZMEVersion);
            console.log("AZME plugin Version : "+_info.pluginVersion);
            console.log("Device ID : "+_info.deviceId);
        });
```


History
----
2.1.1
* Refactor Native <-> JS Bridge

2.1.0
* Added data push support

2.0.1
* Added debug logs 

2.0.0
* Upgraded Native Android SDK to v4.1.0
* Upgraded Native iOS SDK to v3.1.0
* Using the ConnectionString instead of the former AppID/SDKKey/Collection

1.0.0
* Initial Release
    

