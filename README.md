    
#Cordova plugin for Azure Mobile Engagement
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
cordova plugin add cordova-plugin-ms-azme --variable KEY=<value>
```
#### Generic Variables

- `$AZME_ENABLE_LOG` : `true`|`false`, enable both plugin and AZME native logs
- `$AZME_REDIRECT_URL` : the url schemes of your application when using redirect actions in your campaign. Must be the url prefix without :// (ex: `myapp` to handle urls such as `myapp://shop`)

#### iOS Variables
- `$AZME_IOS_APPID` : the AZME application ID of your iOS application
- `$AZME_IOS_SDKKEY` : the sdk key 
- `$AZME_IOS_COLLECTION` : the collection
- `$AZME_IOS_REACH_ICON` : the icon used for reach notification : must be the name of the resource with its extension (ex: `icon.png`)

#### Android Variables
- `$AZME_ANDROID_APPID` : the AZME application ID of your Android application
- `$AZME_ANDROID_SDKKEY` : the sdk key 
- `$AZME_ANDROID_COLLECTION` : the collextion
- `$AZME_ANDROID_REACH_ICON` : the icon used for reach notification : must be the name of the resource without any extension, nor drawable prefix  (ex: `icon`)
- `$AZME_GOOGLE_PROJECT_NUMBER` : the project number used as the GCM (Google Cloud Messaging) sender ID
 
*The AppId, SDKKey and Collection can easily be retrieved from the connection string `Endpoint={YOUR_APP_COLLECTION.DOMAIN};SdkKey={YOUR_SDK_KEY};AppId={YOUR_APPID}`*

Example:
```sh
cordova plugin add cordova-plugin-ms-azme	--variable AZME_IOS_COLLECTION=$AZME_IOS_COLLECTION \
								--variable AZME_IOS_SDKKEY=$AZME_IOS_SDKKEY \
								--variable AZME_IOS_APPID=$AZME_IOS_APPID \
								--variable AZME_IOS_REACH_ICON=$AZME_IOS_REACH_ICON \
								--variable AZME_ANDROID_GOOGLE_PROJECT_NUMBER=$AZME_ANDROID_GOOGLE_PROJECT_NUMBER \
								--variable AZME_ANDROID_APPID=$AZME_ANDROID_APPID \
								--variable AZME_ANDROID_COLLECTION=$AZME_ANDROID_COLLECTION \
								--variable AZME_ANDROID_SDKKEY=$AZME_ANDROID_SDKKEY \
								--variable AZME_ANDROID_REACH_ICON=$AZME_ANDROID_REACH_ICON \
								--variable AZME_REDIRECT_URL=$AZME_REDIRECT_URL \
								--variable AZME_ENABLE_LOG=$AZME_ENABLE_LOG
```
To remove the plugin,
```sh
cordova plugin rm cordova-plugin-ms-azme
```

Methods
--
Once the `deviceready` event has been triggered by the Cordova framework, a `AZME` object is available to interact with the native AZME SDK.

* AZME.startActivity
* AZME.endActivity
* AZME.sendAppInfo
* AZME.startJob
* AZME.endJob
* AZME.sendEvent
* AZME.onOpenURL
* AZME.registerForRemoteNotification
* AZME.getStatus

### AZME.startActivity

Start a new activty  with the corresponding extra infos object.
```javascript
AZME.startActivity(_activityName, _extraInfos,[ _success], [_failure]);
```
##### Params
* `_activityName`: the name of the activity
* `_extraInfos`: a json object containing the extra infos attached to this activity

### AZME.endActivity
Ends the current Actvity. Would trigger a new session on the next startActivity
```javascript
AZME.endActivity([ _success], [_failure]);
```
### AZME.sendEvent
Send an event  with the corresponding extra infos object.
```javascript
AZME.sendEvent(_eventName, _extraInfos,[ _success], [_failure]);
```
##### Params
* `_eventName`: the name of the event
* `_extraInfos`: a json object containing the extra infos attached to this event

### AZME.startJob
Start an new job  with the corresponding extra infos object.
```javascript
AZME.startJob(_jobName, _extraInfos,[ _success], [_failure]);
```
##### Params
* `_jobName`: the name of the job
* `_extraInfos`: a json object containing the extra infos attached to this job

### AZME.endJob
End a job previously created by startJob
```javascript
AZME.endJob(_jobName,[ _success], [_failure]);
```
##### Params
* `_jobName`: the name of the job

### AZME.sendAppInfo
Send App Infos atttached to the currente device.
```javascript
AZME.sendAppInfo( _appInfos,[ _success], [_failure]);
```
##### Params
* `_appInfos`: the json object containing the app infos to be sent

### AZME.onOpenURL
Set an event handler when an application specific URL is triggered (from a push campaign for example). The URL scheme must match the one defined in the `$AZME_REDIRECT_URL` setting
```javascript
AZME.onOpenURL( _urlHandler,[ _success], [_failure]);
```
#####Params
* `_urlHandler`:  the handler that is passed the url that has been triggerd

#####Example
```javascript
	AZME.onOpenURL(function(_url) {
			console.log("user triggered url/action "+_url);
		});
```
### AZME.registerForPushNotification
Register the application to receive push notifications on iOS (this function does nothing on the other platforms)
```javascript
AZME.registerForPushNotification( [_success], [_failure]);
```
### AZME.getStatus
Returns information about the AZME library
```javascript
AZME.getStatus( _statusCallback, [_failure]);
```
##### Params
* `_statusCallback`:  the handler that is passed a json object containing information about the AZME library

##### Example
```javascript
	AZME.getStatus(function(_info) {
		    console.log("AZME SDK Version : "+_info.AZMEVersion);
		      console.log("AZME plugin Version : "+_info.pluginVersion);
		});
```


History
----

1.0.0
* Initial Release
    

