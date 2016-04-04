
/*
 * Copyright (c) Microsoft Corporation.  All rights reserved.
 * Licensed under the MIT license. See License.txt in the project root for license information.
 */


module.exports = {

    pluginName : 'Engagement',
    pluginVersion : '3.0.1',

    onError : function(_error) {
        console.error(_error);
    },

    initializeReach : function(_onOpenURL,_onDataPushReceived) {
        this.openURLHandler  = _onOpenURL;
        this.dataPushHandler  = _onDataPushReceived;  
        cordova.exec(this.handleOpenURL,this.onError, this.pluginName, 'enableURL' , []);
        cordova.exec(this.handleDataPush,this.onError, this.pluginName, 'enableDataPush' , []);
    },

    handleOpenURL : function(_url) {
        if (!_url)
            return ;
        var handler = /*this*/Engagement.openURLHandler;
        if (handler) {
            handler(_url);
        }
        else
            console.error('missing openURLHandler');
    },

    // called by the plugin
    handleDataPush : function(_result) {
        if (!_result ||_result=='OK')
            return;
        var handler = /*this*/Engagement.dataPushHandler;
        if (handler) {
            var decodedCategory = decodeURIComponent(_result.category);
            var decodedBody = decodeURIComponent(_result.body);
            handler(decodedCategory,decodedBody);
        }
        else
            console.error('missing dataPushHandler');
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

    sendSessionEvent: function (_evtName,_extraInfos,_success,_failure) {
        cordova.exec(_success,_failure, this.pluginName, 'sendSessionEvent',[_evtName, JSON.stringify(_extraInfos)] );
    },

    sendSessionError: function (_error,_extraInfos,_success,_failure) {
        cordova.exec(_success,_failure, this.pluginName, 'sendSessionError',[_error, JSON.stringify(_extraInfos)] );
    },

    sendError: function (_error,_extraInfos,_success,_failure) {
        cordova.exec(_success,_failure, this.pluginName, 'sendError',[_error, JSON.stringify(_extraInfos)] );
    },

    sendJobEvent: function (_eventName,_jobName,_extraInfos,_success,_failure) {
        cordova.exec(_success,_failure, this.pluginName, 'sendJobEvent',[_eventName,_jobName, JSON.stringify(_extraInfos)] );
    },

    sendJobError: function (_error,_jobName,_extraInfos,_success,_failure) {
        cordova.exec(_success,_failure, this.pluginName, 'sendJobError',[_error,_jobName, JSON.stringify(_extraInfos)] );
    },

    getStatus: function (_success,_failure) {
        cordova.exec(_success,_failure, this.pluginName, 'getStatus', [] );
    },

    requestPermissions: function (_success,_failure) {
        cordova.exec(_success,_failure, this.pluginName, 'requestPermissions', [] );
    },

};



