/*
 * Copyright (c) Microsoft Corporation.  All rights reserved.
 * Licensed under the MIT license. See License.txt in the project root for license information.
 */


window.azureEngagement = {
    pluginVersion : "3.1.0",    
    AZME_ENABLE_PLUGIN_LOG: $AZME_ENABLE_PLUGIN_LOG, // Filled by the after_build.js hook
    AZME_ENABLE_NATIVE_LOG: $AZME_ENABLE_NATIVE_LOG,
    connectionString: "$AZME_WINDOWS_CONNECTION_STRING",
    appVersionName: "$APP_VERSION_NAME",
    appVersionCode: $APP_VERSION_CODE
};

function engagementLogger(_log)
{
    if (window.azureEngagement.AZME_ENABLE_PLUGIN_LOG)
        console.log("[Engagement Plugin] " + _log);
}

engagementLogger("AZME pluginVersion v"+window.azureEngagement.pluginVersion);

var script = document.createElement('script');
script.src =  "plugins/cordova-plugin-ms-azure-mobile-engagement/libs/azure-engagement.js";
script.onload = function () {
    engagementLogger("Native Library loaded!");
}
document.head.appendChild(script); 

cordova.commandProxy.add("Engagement",{ 

    startActivity: function (successCallback, errorCallback, _params) {
        var activityName = _params[0];
        var userInfos = JSON.parse(_params[1]);
        engagementLogger("startActivity " + activityName);
        engagement.agent.startActivity(activityName , userInfos);
        successCallback();
    },

    endActivity: function (successCallback, errorCallback, _params) {
        engagementLogger("endActivity");
        engagement.agent.endActivity();
        successCallback();
    },

    sendSessionEvent: function (successCallback, errorCallback, _params) {
        var sessionName = _params[0];
        var userInfos = JSON.parse(_params[1]);
        engagementLogger("sendSessionEvent " + sessionName);
        engagement.agent.sendSessionEvent(sessionName , userInfos);
        successCallback();
    },

    sendSessionError: function (successCallback, errorCallback, _params) {
        var errorName = _params[0];
        var userInfos = JSON.parse(_params[1]);
        engagementLogger("sendSessionError " + errorName);
        engagement.agent.sendSessionError(errorName , userInfos);
        successCallback();
    },

    sendEvent: function (successCallback, errorCallback, _params) {
        var eventName = _params[0];
        var userInfos = JSON.parse(_params[1]);
        engagementLogger("sendEvent " + eventName);
        engagement.agent.sendEvent(eventName , userInfos);
        successCallback();
    },

    startJob: function (successCallback, errorCallback, _params) {
        var jobName = _params[0];
        var userInfos = JSON.parse(_params[1]);
        engagementLogger("startJob " + jobName);
        engagement.agent.startJob(jobName , userInfos);
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
        var userInfos = JSON.parse(_params[2]);
        engagementLogger("sendJobError " + errorName+", job "+jobName);
        engagement.agent.sendJobError(errorName , jobName, userInfos);
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
            deviceId : null
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

    requestPermissions:function(successCallback, errorCallback) {
        engagementLogger("not supported on Windows");
        successCallback();
    }
});

