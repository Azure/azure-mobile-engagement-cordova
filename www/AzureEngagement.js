
/*
 * Copyright (c) Microsoft Corporation.  All rights reserved.
 * Licensed under the MIT license. See License.txt in the project root for license information.
 */


module.exports = {

    pluginName : 'AzureEngagement',
    pluginVersion : '2.1.1',

    onError : function(_error) {
        console.error(_error);
    },

    onOpenURL : function (_handler) {
        var _this = this;
        _this.openURLHandler  = _handler;
        cordova.exec(_this.handleOpenURL,_this.onError, _this.pluginName, 'checkRedirect', ['url'] );
    },

    onDataPushReceived : function(_handler) {
         var _this = this;
        _this.dataPushHandler = _handler;
        cordova.exec( _this.handleDataPush, _this.onError, _this.pluginName, 'checkRedirect', ['data'] );
    },

    handleOpenURL : function(_url) {
        if (!_url)
            return ;
        var handler = /*this*/AzureEngagement.openURLHandler;
        if (handler) {
            handler(_url);
        }
        else
            console.error("missing openURLHandler");
    },

    // called by the plugin
    handleDataPush : function(_result) {
        if (!_result ||_result=="OK")
             // ignore the checkredirect result
            return;

        var handler = /*this*/AzureEngagement.dataPushHandler;
        if (handler) {
            var decodedCategory = decodeURIComponent(_result.category);
            var decodedBody = decodeURIComponent(_result.body);
           handler(decodedCategory,decodedBody);
        }
        else
            console.error("missing dataPushHandler");
    },

    startActivity: function (_activityName,_extraInfos,_success,_failure) {
        cordova.exec(_success, _failure, this.pluginName, 'startActivity', [_activityName,JSON.stringify(_extraInfos)] );
    },

    endActivity: function (_success,_failure) {
        cordova.exec(_success, _failure, this.pluginName, 'endActivity', [] );
    },

    sendAppInfo: function (_appInfos,_success,_failure) {
        cordova.exec(_success,_failure, this.pluginName, 'sendAppInfo', [JSON.stringify(_appInfos)] );
    },

    sendEvent: function (_eventName,_extraInfos,_success,_failure) {
        cordova.exec(_success,_failure, this.pluginName, 'sendEvent', [_eventName,JSON.stringify(_extraInfos)] );
    },

    startJob: function (_jobName,_extraInfos,_success,_failure) {
        cordova.exec(_success,_failure, this.pluginName, 'startJob',[_jobName, JSON.stringify(_extraInfos)] );
    },

    endJob: function (_jobName,_success,_failure) {
        cordova.exec(_success,_failure, this.pluginName, 'endJob', [_jobName] );
    },

    getStatus: function (_success,_failure) {
        cordova.exec(_success,_failure, this.pluginName, 'getStatus', [] );
    },

    registerForPushNotification: function (_success,_failure) {
        cordova.exec(_success,_failure, this.pluginName, 'registerForPushNotification', [] );
    },

};



