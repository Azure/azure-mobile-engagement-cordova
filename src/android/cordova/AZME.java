/*
 * Copyright (c) Microsoft Corporation.  All rights reserved.
 * Licensed under the MIT license. See License.txt in the project root for license information.
 */

package com.microsoft.azure.engagement.cordova;

import android.content.Intent;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaActivity;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;

import com.microsoft.azure.engagement.shared.EngagementDelegate;
import com.microsoft.azure.engagement.shared.EngagementShared;

public class AZME extends CordovaPlugin {

    private static final String pluginName = "CDVAZME";
    private static final String pluginVersion = "3.2.1";
    private static final String nativeSDKVersion = "4.2.3"; // to eventually retrieve from the SDK itself

    public CordovaInterface cordova = null;
    public CordovaWebView webView = null;
    public boolean isPaused = true;
    public String lastRedirect;
    private CallbackContext dataPushHandlerContext = null;
    private CallbackContext onOpenUrlHandlerContext = null;

    private boolean lazyAreaLocation;
    private boolean realtimeLocation ;
    private boolean fineRealtimeLocation;
    private boolean backgroundReporting;
    private boolean foregroundReporting ;

    EngagementDelegate delegate = new EngagementDelegate() {

        @Override
        public void didReceiveDataPush(JSONObject _data) {
            if (dataPushHandlerContext != null) {
                PluginResult result = new PluginResult(PluginResult.Status.OK, _data);
                result.setKeepCallback(true);
                dataPushHandlerContext.sendPluginResult(result);
            }
            else
                EngagementShared.instance().logD("Cannot receive datapush if enablePush not previously called");
        }
    };

    public AZME() {
    }

    public void initialize(CordovaInterface _cordova, CordovaWebView _webView) {
        CordovaActivity activity =  (CordovaActivity) _cordova.getActivity();

        String invokeString = activity.getIntent().getDataString();
        super.initialize(_cordova, _webView);

        cordova = _cordova;
        webView  = _webView;

        try {
            ApplicationInfo ai = activity.getPackageManager().getApplicationInfo(activity.getPackageName(), PackageManager.GET_META_DATA);
            Bundle bundle = ai.metaData;

            boolean nativeLog = bundle.getBoolean("engagement:log:test");
            boolean pluginLog = bundle.getBoolean("AZME_ENABLE_PLUGIN_LOG");
            EngagementShared.instance().setPluginLog(pluginLog);
            EngagementShared.instance().initSDK(pluginName,pluginVersion,nativeSDKVersion);
         
            if ( invokeString != null && !invokeString.equals("") ) {
                lastRedirect = invokeString;
                EngagementShared.instance().logD("handleOpenURL="+lastRedirect);
            }
       
            lazyAreaLocation = bundle.getBoolean("AZME_LAZYAREA_LOCATION");
            realtimeLocation = bundle.getBoolean("AZME_REALTIME_LOCATION");
            fineRealtimeLocation = bundle.getBoolean("AZME_FINEREALTIME_LOCATION");
            backgroundReporting= bundle.getBoolean("AZME_BACKGROUND_REPORTING");
            foregroundReporting = bundle.getBoolean("AZME_FOREGROUND_REPORTING");

            String connectionString = bundle.getString("AZME_ANDROID_CONNECTION_STRING");
            EngagementShared.backgroundReportingType background  = EngagementShared.backgroundReportingType.BACKGROUNDREPORTING_NONE;
            EngagementShared.locationReportingType locationReporting = EngagementShared.locationReportingType.LOCATIONREPORTING_NONE ;

            if (lazyAreaLocation)
                locationReporting = EngagementShared.locationReportingType.LOCATIONREPORTING_LAZY ;
            else
            if (realtimeLocation)
                locationReporting = EngagementShared.locationReportingType.LOCATIONREPORTING_REALTIME ;
            else
            if (fineRealtimeLocation)
                locationReporting = EngagementShared.locationReportingType.LOCATIONREPORTING_FINEREALTIME ;

            if (backgroundReporting)
                background = EngagementShared.backgroundReportingType.BACKGROUNDREPORTING_BACKGROUND;
            else
            if (foregroundReporting)
                background = EngagementShared.backgroundReportingType.BACKGROUNDREPORTING_FOREGROUND;

            EngagementShared.instance().initialize(activity,connectionString,locationReporting,background);
            EngagementShared.instance().setDelegate(delegate);

        } catch (PackageManager.NameNotFoundException e) {
            EngagementShared.instance().logE("Failed to load meta-data, NameNotFound: " + e.getMessage());
        } catch (NullPointerException e) {
            EngagementShared.instance().logE("Failed to load meta-data, NullPointer: " + e.getMessage());
        }

    }

    public boolean execute(String action, JSONArray args, CallbackContext callbackContext)   {
       
          if (action.equals("enableURL")) {
              EngagementShared.instance().logD("enableURL=" + lastRedirect);
              PluginResult result = new PluginResult(PluginResult.Status.OK,lastRedirect);
              result.setKeepCallback(true);
              callbackContext.sendPluginResult(result);
              onOpenUrlHandlerContext = callbackContext;
              return true;
        }
        else
        if (action.equals("enableDataPush")) {

            EngagementShared.instance().logD("enableDataPush");
            PluginResult result = new PluginResult(PluginResult.Status.OK);
            result.setKeepCallback(true);
            callbackContext.sendPluginResult(result);
            dataPushHandlerContext = callbackContext;
            EngagementShared.instance().enableDataPush();
            return true;
        }
        else if (action.equals("getStatus")) {

            final CallbackContext cb = callbackContext;

            EngagementShared.instance().getStatus(new EngagementDelegate() {
                @Override
                public void onGetStatusResult(JSONObject _result) {
                    cb.success(_result);
                }
            });
            return true;
        } else if (action.equals("startActivity")) {

            try {
                String activityName = args.getString(0);
                String extraInfos = args.getString(1);
                EngagementShared.instance().startActivity(activityName,extraInfos);
                callbackContext.success();
            } catch (JSONException e) {
                callbackContext.error("invalid args for startActivity");
            }
            return true;
        } else if (action.equals("endActivity")) {
            EngagementShared.instance().endActivity();
            callbackContext.success();
            return true;
        } else if (action.equals("sendEvent")) {

            try {
                String eventName = args.getString(0);
                String extraInfos = args.getString(1);
                EngagementShared.instance().sendEvent(eventName, extraInfos);
                callbackContext.success();
            } catch (JSONException e) {
                callbackContext.error("invalid args for sendEvent");
            }
            return true;
        } else if (action.equals("startJob")) {

            try {
                String jobName = args.getString(0);
                String extraInfos = args.getString(1);
                EngagementShared.instance().startJob(jobName, extraInfos);
                callbackContext.success();

            } catch (JSONException e) {
                callbackContext.error("invalid args for startJob");
            }
            return true;
        } else if (action.equals("endJob")) {

            try {
                String jobName = args.getString(0);
                EngagementShared.instance().endJob(jobName);
                callbackContext.success();
            } catch (JSONException e) {
                callbackContext.error("invalid args for endJob");
            }
            return true;
        } else if (action.equals("sendSessionEvent")) {

            try {
                String eventName = args.getString(0);
                String extraInfos = args.getString(1);
                EngagementShared.instance().sendSessionEvent(eventName, extraInfos);
                callbackContext.success();

            } catch (JSONException e) {
                callbackContext.error("invalid args for sendSessionEvent");
            }
            return true;
        } else if (action.equals("sendSessionError")) {

            try {
                String error = args.getString(0);
                String extraInfos = args.getString(1);
                EngagementShared.instance().sendSessionError(error, extraInfos);
                callbackContext.success();

            } catch (JSONException e) {
                callbackContext.error("invalid args for sendSessionError");
            }
            return true;
        } else if (action.equals("sendError")) {

            try {
                String error = args.getString(0);
                String extraInfos = args.getString(1);
                EngagementShared.instance().sendError(error, extraInfos);
                callbackContext.success();

            } catch (JSONException e) {
                callbackContext.error("invalid args for sendError");
            }
            return true;
       } else if (action.equals("sendJobEvent")) {

            try {
                String eventName = args.getString(0);
                String jobName = args.getString(1);
                String extraInfos = args.getString(2);
                EngagementShared.instance().sendJobEvent(eventName, jobName, extraInfos);
                callbackContext.success();

            } catch (JSONException e) {
                callbackContext.error("invalid args for sendJobEvent");
            }
            return true;
        } else if (action.equals("sendJobError")) {

            try {
                String error = args.getString(0);
                String jobName = args.getString(1);
                String extraInfos = args.getString(2);
                EngagementShared.instance().sendJobError(error, jobName, extraInfos);
                callbackContext.success();

            } catch (JSONException e) {
                callbackContext.error("invalid args for sendJobError");
            }
            return true;
        } else if (action.equals("sendAppInfo")) {

            try {
                String extraInfos = args.getString(0);
                EngagementShared.instance().sendAppInfo(extraInfos);
                callbackContext.success();
            } catch (JSONException e) {
                callbackContext.error("invalid args for sendAppInfo");
            }
            return true;
           
        } else if (action.equals("requestPermissions")) {

            JSONObject ret =  EngagementShared.instance().requestPermissions(realtimeLocation,fineRealtimeLocation,lazyAreaLocation);
            if (!ret.has("error"))
                callbackContext.success(ret);
            else {
                String errString = null;
                try {
                    errString = ret.getString("error");
                } catch (JSONException e) {
                    Log.e(EngagementShared.LOG_TAG,"missing error tag");
                }
                callbackContext.error(errString);
            }
            return true;
        }
        else if (action.equals("setEnabled")) {

            try {
                boolean enabled = args.getBoolean(0);
                EngagementShared.instance().setEnabled(enabled);
                callbackContext.success(enabled?1:0);
            } catch (JSONException e) {
                callbackContext.error("invalid args for setEnabled");
            }
            return true;
           
        }
         else if (action.equals("isEnabled")) {
            callbackContext.success(EngagementShared.instance().isEnabled()?1:0);
            return true;
           
        }
      
        String str = "Unrecognized Command : "+action;
        EngagementShared.instance().logE(str);
        callbackContext.error(str);
        return false;
    }

    public void onPause(boolean multitasking) {

        EngagementShared.instance().onPause();
    }

    public void onResume(boolean multitasking) {

        EngagementShared.instance().onResume();
    }

    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) throws JSONException {
        
        if (requestCode == 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED)
          EngagementShared.instance().refreshPermissions();
    }

    public void onNewIntent(Intent intent)
    {
        super.onNewIntent(intent);
        String invokeString = intent.getDataString();
        if ( invokeString != null && !invokeString.equals("") ) {
            EngagementShared.instance().logD("onNewIntent, handleOpenURL "+invokeString);
            if (onOpenUrlHandlerContext != null) {
                PluginResult result = new PluginResult(PluginResult.Status.OK, invokeString);
                result.setKeepCallback(true);
                onOpenUrlHandlerContext.sendPluginResult(result);
            }
            else
                EngagementShared.instance().logD("Cannot trigger onOpenUrl if enableURL not previously called");

        }
    }

}
