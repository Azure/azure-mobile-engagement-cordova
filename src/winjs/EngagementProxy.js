/*
 * Copyright (c) Microsoft Corporation.  All rights reserved.
 * Licensed under the MIT license. See License.txt in the project root for license information.
 */


window.azureEngagement = {
    pluginVersion = "3.2.2",    
    AZME_ENABLE_PLUGIN_LOG: ${AZME_ENABLE_PLUGIN_LOG}, // set by the after_prepare.js hook
    AZME_ENABLE_NATIVE_LOG: ${AZME_ENABLE_NATIVE_LOG},
    connectionString: "${AZME_WINDOWS_CONNECTION_STRING}",
    appVersionName: "${APP_VERSION_NAME}",
    lastActivityName: null,
    lastActivityUserInfo: null
};

function engagementLogger(_log) {
    if (window.azureEngagement.AZME_ENABLE_PLUGIN_LOG)
        console.log("[Engagement Plugin] " + _log);
}

engagementLogger("AZME pluginVersion v"+window.azureEngagement.pluginVersion);

var xhrObj = new XMLHttpRequest();
xhrObj.open('GET', "ms-appx-web://${BUNDLE_ID}/www/plugins/cordova-plugin-ms-azure-mobile-engagement/libs/azure-engagement.js", false);
xhrObj.send('');
var se = document.createElement('script');
se.type = "text/javascript";
se.text = xhrObj.responseText;
document.getElementsByTagName('head')[0].appendChild(se);
engagementLogger("JS SDK loaded");

cordova.commandProxy.add("Engagement",{ 

    startActivity: function (successCallback, errorCallback, _params) {
        var activityName = _params[0];
        var userInfo = JSON.parse(_params[1]);

        engagementLogger("startActivity " + activityName );
        engagement.agent.startActivity( activityName, userInfo);

        window.azureEngagement.lastActivityName = activityName;
        window.azureEngagement.lastActivityUserInfo = userInfo;
        
        successCallback();
    },

    endActivity: function (successCallback, errorCallback, _params) {
        engagementLogger("endActivity");
        engagement.agent.endActivity();
        successCallback();
    },

    sendSessionEvent: function (successCallback, errorCallback, _params) {
        var sessionName = _params[0];
        var userInfo = JSON.parse(_params[1]);
        engagementLogger("sendSessionEvent " + sessionName);
        engagement.agent.sendSessionEvent(sessionName , userInfo);
        successCallback();
    },

    sendSessionError: function (successCallback, errorCallback, _params) {
        var errorName = _params[0];
        var userInfo = JSON.parse(_params[1]);
        engagementLogger("sendSessionError " + errorName);
        engagement.agent.sendSessionError(errorName , userInfo);
        successCallback();
    },

    sendEvent: function (successCallback, errorCallback, _params) {
        var eventName = _params[0];
        var userInfo = JSON.parse(_params[1]);
        engagementLogger("sendEvent " + eventName);
        engagement.agent.sendEvent(eventName , userInfo);
        successCallback();
    },

    startJob: function (successCallback, errorCallback, _params) {
        var jobName = _params[0];
        var userInfo = JSON.parse(_params[1]);
        engagementLogger("startJob " + jobName);
        engagement.agent.startJob(jobName , userInfo);
        successCallback();
    },

    endJob: function (successCallback, errorCallback, _params) {
        var jobName = _params[0];
        engagementLogger("endJob" + jobName);
        engagement.agent.endJob(jobName);
        successCallback();
    },

    sendJobError: function (successCallback, errorCallback, _params) {
        var errorName = _params[0];
        var jobName = _params[1];
        var userInfo = JSON.parse(_params[2]);
        engagementLogger("sendJobError " + errorName+", job "+jobName);
        engagement.agent.sendJobError(errorName , jobName, userInfo);
        successCallback();
    },

    sendCrash: function (successCallback, errorCallback, _params) {
        var crashId = _params[0];
        var crash = _params[1];
        engagementLogger("sendCrash " + crashId);
        engagement.agent.sendCrash(crash, crashId);
        successCallback();
    },

    sendAppInfo: function (successCallback, errorCallback, _params) {
        var appInfos = JSON.parse(_params[0]);
        engagementLogger("sendAppInfo " + _params[0]);
        engagement.agent.sendAppInfo(appInfos);
        successCallback();
    },

    getStatus:function(successCallback, errorCallback) {
        var status = {
            nativeVersion: azureEngagement.serviceVersion,
            pluginVersion: azureEngagement.pluginVersion,
            isEnabled : engagement.agent.isEnabled(),
            deviceId : engagement.deviceId
        }
        engagementLogger("getStatus " + JSON.stringify(status));
        successCallback(status);
    },

    enableURL:function(successCallback, errorCallback) {
        successCallback();
    },
   
    enableDataPush:function(successCallback, errorCallback) {
        successCallback();
    },

    setEnabled: function (successCallback, errorCallback, _params) {
        var _enabled = _params[0];
        engagement.agent.setEnabled(_enabled);
        successCallback(engagement.agent.isEnabled());
    },

    isEnabled: function (successCallback, errorCallback) {
        successCallback(engagement.agent.isEnabled());
    },

    requestPermissions:function(successCallback, errorCallback) {
        engagementLogger("not supported on Windows");
        successCallback();
    }
});

document.addEventListener("deviceready",function(){
    document.addEventListener("pause", function() {
        if (azureEngagement.lastActivityName != null) {
            engagementLogger("Pausing activity " + window.azureEngagement.lastActivityName);
            engagement.agent.endActivity();
        }
    }, false);
    document.addEventListener("resume", function(){
        if (azureEngagement.lastActivityName != null) {
            engagementLogger("Resuming activity " + window.azureEngagement.lastActivityName);
            engagement.agent.startActivity(window.azureEngagement.lastActivityName, window.azureEngagement.lastActivityUserInfo);
        }
    }, false);

},false);
