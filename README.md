    
Cordova plugin for Azure Mobile Engagement
----

Introduction
--
This plugin integrates the Azure Mobile Engagement (AZME) SDK into your Cordova Application. It supports both *reporting* and *push* features. 

*Please refer to the Azure Mobile Engagement documentation for more information about the various AZME concepts.*

Supported Platforms
--
* iOS
* Android

Supported Framework
--
* Cordova
* PhoneGap
* CocoonJS
* CrossWalk

Installation
--
To install the plugin, just add it to your Cordova project using your proper AZME credentials through Cordova variables.
```sh
cordova plugin add cordova-plugin-ms-azure-mobile-engagement --variable KEY=<value>
```
#### Generic Variables

- `AZME_ENABLE_PLUGIN_LOG` : `true`|`false`, enable logs from the Cordova Wrapper  (recommended for development)
- `AZME_ENABLE_NATIVE_LOG` : `true`|`false`, enable logs from the AZME native SDK
- `AZME_ACTION_URL` : the url schemes of your application when using redirect actions in your campaign. Must be the url prefix without :// (ex: `myapp` to handle urls such as `myapp://shop`)

#### iOS Variables
- `AZME_IOS_CONNECTION_STRING` : the iOS connection string (to retrieve from the AZME portal)
- `AZME_IOS_REACH_ICON` : the icon used for reach notification : must be the name of the resource with its extension (ex: `mynotificationicon.png`), and the icon file must be added into your iOS project with XCode (using the Add Files Menu)

#### Android Variables
- `AZME_ANDROID_CONNECTION_STRING` : the iOS connection string (to retrive from the AZME portal)
- `AZME_ANDROID_REACH_ICON` : the icon used for reach notification : must be the name of the resource without any extension, nor drawable prefix  (ex: `mynotificationicon`), and the icon file must be copied into your android project (`platforms/android/res/drawable)`
- `AZME_ANDROID_GOOGLE_PROJECT_NUMBER` : the project number used as the GCM (Google Cloud Messaging) sender ID
 
Only the `AZME_ANDROID_CONNECTION_STRING` and/or `AZME_IOS_CONNECTION_STRING` are required : all the other variables are optionals.

Example:
```sh
cordova plugin add cordova-plugin-ms-azure-mobile-engagement --variable AZME_IOS_CONNECTION_STRING=AZME_IOS_CONNECTION_STRING --variable AZME_ANDROID_CONNECTION_STRING=AZME_ANDROID_CONNECTION_STRING 
```
To remove the plugin,
```sh
cordova plugin rm cordova-plugin-ms-azure-mobile-engagement
```

Location Reporting
--
Location reporting can be activated by using two additional variables to define which location to report, and whether this reporting should be performed while the application is running in the background:
* `--variable enableLocation` : `lazyarea`|`realtime`|`finerealtime`
* `--variable backgroundReporting` : `true`|`false`

##### Example
```sh
cordova plugin add cordova-plugin-ms-azure-mobile-engagement --variable enableLocation=realtime --variable backgroundReporting=true
```
##### Remarks

* By default, location report is being deactivated.
* Internally, some additional plugins are being added to your project, but they will be automatically removed when the AZME plugin is being removed
  * `cordova-plugin-ms-azure-mobile-engagement-lazyarea-location`
  * `cordova-plugin-ms-azure-mobile-engagement-runtime-location`
  * `cordova-plugin-ms-azure-mobile-engagement-fineruntime-location`
  * `cordova-plugin-ms-azure-mobile-engagement-foreground-reporting`
  * `cordova-plugin-ms-azure-mobile-engagement-background-reporting`
* If you are targetting AndroidM, your application needs to call  `Engagement.requestPermissions`at some point (cf. below)
* For IOS, you can also add  `--variable AZME_IOS_LOCATION_DESCRIPTION : <desc> ` to define the message that will be displayed to the end user in the permission dialog


Push Notification Support
--
To enable Reach, you need to call 
 `Engagement.initializeReach()` to register the application to receive push notification.

```javascript
Engagement.initializeReach( _openURLHandler, _dataPushHandler, [_success], [_failure]);
```
##### Params
* `_onOpenURLHandler`:  the function to be called when an application specific URL is triggered (from a push campaign for example). The URL scheme must match the one defined in the `$AZME_ACTION_URL` setting
* `_dataPushHandler`:  the function handler to receive the data push. The function needs to accept two parameters : the `category` , and the `body` 

##### Example
```javascript
    onOpenURL = function(_url) {
            console.log("user triggered url/action "+_url);
        };
     onDataPushReceived = function(_category,_body) {
            if (_category=="png")
                str += '<img src="data:image/png;base64,'+_body+'" width="128" height="128" />';
            else
                str += _body;
            // ...
        };  
     Engagement.initializeReach(onOpenURL,onDataPushReceived);
```

##### Notes
* on IOS, this call will ask the user to autorize push notifications for your application, so it is recommended to trigger that call at the proper time (ie: once the users are engaged into your application)
* If the body contains non-text data, it will be  received encoded in base64 format 
  * If the data is an image, it can be directly displayed using the prefix  `data:image/png;base64` (cf. example)
  * If you want to extract the data bytes, you would need to use the `btoa()` function to convert base64 to binary


Public Interface
--
Once the `deviceready` event has been triggered by the Cordova framework, a `Engagement` object is available to interact with the native AZME SDK.

* Engagement.startActivity
* Engagement.endActivity
* Engagement.sendAppInfo
* Engagement.startJob
* Engagement.endJob
* Engagement.sendEvent
* Engagement.getStatus
* Engagement.requestPermissions
* Engagement.sendSessionEvent
* Engagement.sendSessionError
* Engagement.sendError
* Engagement.sendJobEvent
* Engagement.sendJobError

### Engagement.startActivity

Start a new activty  with the corresponding extra infos object.
```javascript
Engagement.startActivity(_activityName, _extraInfos,[ _success], [_failure]);
```
##### Params
* `_activityName`: the name of the activity
* `_extraInfos`: a json object containing the extra infos attached to this activity

### Engagement.endActivity
Ends the current Actvity. Would trigger a new session on the next startActivity
```javascript
Engagement.endActivity([ _success], [_failure]);
```
### Engagement.sendEvent
Send an event  with the corresponding extra infos object.
```javascript
Engagement.sendEvent(_eventName, _extraInfos,[ _success], [_failure]);
```
##### Params
* `_eventName`: the name of the event
* `_extraInfos`: a json object containing the extra infos attached to this event

### Engagement.startJob
Start an new job  with the corresponding extra infos object.
```javascript
Engagement.startJob(_jobName, _extraInfos,[ _success], [_failure]);
```
##### Params
* `_jobName`: the name of the job
* `_extraInfos`: a json object containing the extra infos attached to this job

### Engagement.endJob
End a job previously created by startJob
```javascript
Engagement.endJob(_jobName,[ _success], [_failure]);
```
##### Params
* `_jobName`: the name of the job

### Engagement.sendSessionEvent
Send a session event
```javascript
Engagement.sendSessionEvent(_eventName, _extraInfos ,[ _success], [_failure]);
```
### Engagement.sendSessionError
Send a session error
```javascript
Engagement.sendSessionError(_error, _extraInfos ,[ _success], [_failure]);
```

### Engagement.sendError
Send an error
```javascript
Engagement.sendError(_error, _extraInfos ,[ _success], [_failure]);
```

### Engagement.sendJobEvent
Send a job event
```javascript
Engagement.sendError(_eventName, _jobName, _extraInfos ,[ _success], [_failure]);
```

### Engagement.sendJobError
Send a job error
```javascript
Engagement.sendError(_error, _jobName, _extraInfos ,[ _success], [_failure]);
```

### Engagement.sendAppInfo
Send App Infos atttached to the currente device.
```javascript
Engagement.sendAppInfo( _appInfos,[ _success], [_failure]);
```
##### Params
* `_appInfos`: the json object containing the app infos to be sent


### Engagement.requestPermissions

Allow the user to autorize the permissions needed for the proper execution of the AZME plugin. 
By default, there's no need for a additional permissions, but if you've enabled the location reporting, this function must be called  to let the user allow the location based permissions (`ACCESS_FINE_LOCATION` and/or `ACCESS_COARSE_LOCATION`)

```javascript
Engagement.requestPermissions([_success], [_failure]);
```

##### Notes
* Returns the list of permissions that have been asked, ans whether the user has allowed them or not
* This function does nothing on platforms other than Android M. 

##### Example
```javascript
Engagement.requestPermissions(function(_ret) {
                console.log("permissions = "+JSON.stringify(_ret));
    });
```

### Engagement.getStatus
Returns information about the AZME plugin.
```javascript
Engagement.getStatus( _statusCallback, [_failure]);
```
##### Params
* `_statusCallback`:  the handler that is passed a json object containing information about the AZME library

##### Example
```javascript
    Engagement.getStatus(function(_info) {
            console.log("AZME native Version : "+_info.nativeVersion);
            console.log("AZME plugin Version : "+_info.pluginVersion);
            console.log("Device ID : "+_info.deviceId);
        });
```


History
----
##### 3.0.0

* API Breaking Change
  * `AZME_ENABLE_NATIVE_LOG`/`AZME_ENABLE_PLUGIN_LOG` instead of `AZME_ENABLE_LOG`
  * `AZME_ACTION_URL` instead of `AZME_REDIRECT_URL`
  * `initializeReach` instead of `registerForPushNotification`/`onHandleURL`/`onDataPushReceived`
  * Category is set to `null` instead of `None`if not defined within a campaign
* Added `AZME_IOS_LOCATION_DESCRIPTION` variable
* Fix Location reporting hooks

##### 2.3.1
* Added Android M Support
* Added reporting functions
* Refactor underlying code to share the same base code with the AZME Unity SDK

##### 2.2.0
* Added location reporting

##### 2.1.1
* Refactor Native <-> JS Bridge

##### 2.1.0
* Added data push support

##### 2.0.1
* Added debug logs 

##### 2.0.0
* Upgraded Native Android SDK to v4.1.0
* Upgraded Native iOS SDK to v3.1.0
* Using the ConnectionString instead of the former AppID/SDKKey/Collection

##### 1.0.0
* Initial Release
    

