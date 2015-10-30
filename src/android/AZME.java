/*
 * Copyright (c) Microsoft Corporation.  All rights reserved.
 * Licensed under the MIT license. See License.txt in the project root for license information.
 */

package com.microsoft.azure.engagement.cordova;

import java.util.Arrays;
import java.util.Iterator;
import java.util.Map;

import android.annotation.TargetApi;
import android.content.pm.PackageInfo;
import android.content.pm.PermissionInfo;
import android.os.Build;
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

import com.microsoft.azure.engagement.EngagementConfiguration;
import com.microsoft.azure.engagement.EngagementAgent;

public class AZME extends CordovaPlugin {

    public static final String LOG_TAG = "cdvazme-test";
    private static final String pluginVersion = "2.2.0";
    private static final String nativeSDKVersion = "4.1.0"; // to eventually retrieve from the SDK itself

    public static AZME singleton = null;

    public CordovaInterface cordova = null;
    public CordovaWebView webView = null;
    public boolean isPaused = true;
    private String previousActivityName = null;
    private String lastRedirect = null;
    private boolean enableLog = false;
    private boolean lazyAreaLocation = false;
    private boolean realtimeLocation = false;
    private boolean fineRealtimeLocation = false;
    private boolean backgroundReporting = false;
    private boolean foregroundReporting = false;
    public boolean readyForPush = false;
    private CallbackContext dataPushHandlerContext;

    public void initialize(CordovaInterface _cordova, CordovaWebView _webView) {
        CordovaActivity activity =  (CordovaActivity) _cordova.getActivity();

        final String invokeString = activity.getIntent().getDataString();
        if ( invokeString != null && !invokeString.equals("") ) {
            lastRedirect = invokeString;
            if (enableLog)
                Log.i(AZME.LOG_TAG,"Preparing Redirect to " + lastRedirect);
        }
        super.initialize(_cordova, _webView);
        cordova = _cordova;
        webView  = _webView;

        try {
            ApplicationInfo ai = activity.getPackageManager().getApplicationInfo(activity.getPackageName(), PackageManager.GET_META_DATA);
            Bundle bundle = ai.metaData;
          
            enableLog = bundle.getBoolean("engagement:log:test"); 
            lazyAreaLocation = bundle.getBoolean("AZME_LAZYAREA_LOCATION");
            realtimeLocation = bundle.getBoolean("AZME_REALTIME_LOCATION");
            fineRealtimeLocation = bundle.getBoolean("AZME_REALTIME_LOCATION");
            backgroundReporting= bundle.getBoolean("AZME_BACKGROUND_REPORTING");
            foregroundReporting = bundle.getBoolean("AZME_FOREGROUND_REPORTING");

            String connectionString = bundle.getString("AZME_ANDROID_CONNECTION_STRING");     
            if (enableLog)
                Log.i(AZME.LOG_TAG,"Initializing AZME with connectionString " + connectionString);
            EngagementConfiguration engagementConfiguration = new EngagementConfiguration();
            engagementConfiguration.setConnectionString(connectionString);
            
            if (lazyAreaLocation) {
                engagementConfiguration.setLazyAreaLocationReport(true);
                if (enableLog)
                    Log.i(AZME.LOG_TAG,"Lazy Area Location enabled");
            }
            else
            if (realtimeLocation) {
                engagementConfiguration.setRealtimeLocationReport(true);
                if (enableLog)
                    Log.i(AZME.LOG_TAG,"Realtime Location enabled");
            }
            else
            if (fineRealtimeLocation) {
                engagementConfiguration.setRealtimeLocationReport(true);
                engagementConfiguration.setFineRealtimeLocationReport(true);
                if (enableLog)
                    Log.i(AZME.LOG_TAG,"Fine Realtime Location enabled");
            }

            if (backgroundReporting) {
                if (fineRealtimeLocation || realtimeLocation) {
                    engagementConfiguration.setBackgroundRealtimeLocationReport(true);
                    if (enableLog)
                        Log.i(AZME.LOG_TAG,"Background Location enabled");
                }
                else
                    Log.i(AZME.LOG_TAG,"Background mode requires realtime location");
            }
            else
            if (foregroundReporting) {
                if (lazyAreaLocation || fineRealtimeLocation || realtimeLocation) {
                }
                else
                    Log.e(AZME.LOG_TAG,"Foreground mode requires location");
            }
            else {
                if (lazyAreaLocation || fineRealtimeLocation || realtimeLocation) {
                    Log.e(AZME.LOG_TAG, "Foreground or Background required when using location");
                }
            }

            EngagementAgent.getInstance(activity).init(engagementConfiguration);

            Bundle b = new Bundle();
            b.putString("CDVAZMEVersion", pluginVersion);
            EngagementAgent.getInstance(activity).sendAppInfo(b);

        } catch (PackageManager.NameNotFoundException e) {
            Log.e(AZME.LOG_TAG,"Failed to load meta-data, NameNotFound: " + e.getMessage());
        } catch (NullPointerException e) {
            Log.e(AZME.LOG_TAG,"Failed to load meta-data, NullPointer: " + e.getMessage());
        }

        singleton = this;
    }

    private Bundle stringToBundle(String _param) {
        JSONObject jObj;

        try {
            jObj = new JSONObject(_param);
            Bundle b = new Bundle();

            @SuppressWarnings("unchecked")
            Iterator<String> keys = jObj.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                String val = jObj.getString(key);
                b.putString(key, val);
            }
            return b;

        } catch (JSONException e) {
            return null;
        }
    }

    public void checkDataPush()
    {
        if (!readyForPush || isPaused) {
             return;
        }
        Map<String,String> m = com.microsoft.azure.engagement.cordova.AZMEDataPushReceiver.getPendingDataPushes(cordova.getActivity().getApplicationContext());
        for (Map.Entry<String, ?> entry : m.entrySet())
        {
            String timestamp = entry.getKey();
            String[] p = entry.getValue().toString().split(" ");
            String encodedCategory = p[0];
            String encodedBody = p[1];
            if (enableLog)
                Log.i(AZME.LOG_TAG,"handling data push ("+timestamp+")");

            JSONObject ret = new JSONObject();

            try {
                ret.put("category", encodedCategory);
                ret.put("body",encodedBody);
                PluginResult result = new PluginResult(PluginResult.Status.OK, ret);
                result.setKeepCallback(true);
                dataPushHandlerContext.sendPluginResult(result);
            } catch (JSONException e) {
                Log.e(AZME.LOG_TAG, "Failed to prepare data push " + e.getMessage());
            }

        }
    }

    public boolean execute(String action, JSONArray args, CallbackContext callbackContext)   {
        if (enableLog)
            Log.i(AZME.LOG_TAG,"execute: "+action+" w/ "+args.toString());


        if (action.equals("checkRedirect")) {

            String redirectType;
            try {
                redirectType = args.getString(0);
                if (redirectType.equals( "url")) {
                    callbackContext.success(lastRedirect);
                    lastRedirect = null;
                } else if (redirectType.equals("data")) {

                    PluginResult result = new PluginResult(PluginResult.Status.OK);
                    result.setKeepCallback(true);
                    callbackContext.sendPluginResult(result);
                    dataPushHandlerContext = callbackContext;
                    readyForPush = true;
                    checkDataPush();

                } else
                    callbackContext.error("unsupport type:" + redirectType);

            } catch (JSONException e) {
                callbackContext.error("missing arg for checkRedirect");
            }

            return true;
        }
        else if (action.equals("getStatus")) {

            final CallbackContext cb = callbackContext;
            EngagementAgent.getInstance(cordova.getActivity()).getDeviceId(new EngagementAgent.Callback<String>() {
                @Override
                public void onResult(String deviceId) {
                    Log.i(AZME.LOG_TAG,"DeviceID:" + deviceId);
                    JSONObject j;
                    String response = "{";
                    response = "{" +
                               "\"pluginVersion\": \"" + pluginVersion + "\"," +
                               "\"AZMEVersion\": \""+nativeSDKVersion+"\"," +
                               "\"deviceId\": \"" + deviceId + "\"" +
                               "}";
                    try {
                        cb.success(new JSONObject(response));
                    } catch (JSONException e) {
                     //   e.printStackTrace();
                        cb.error("could not retrieve status");
                    }
                }
            });
            return true;
        } else if (action.equals("startActivity")) {
            String activityName;
            try {
                activityName = args.getString(0);
                String param = args.getString(1);
                Bundle b = stringToBundle(param);
                if (b == null) {
                    callbackContext.error("invalid param for startActivity");
                    return true;
                }
                previousActivityName = activityName;
                EngagementAgent.getInstance(cordova.getActivity()).startActivity(cordova.getActivity(), activityName, b);
                callbackContext.success();
            } catch (JSONException e) {
                callbackContext.error("invalid args for startActivity");
            }
            return true;
        } else if (action.equals("endActivity")) {
            EngagementAgent.getInstance(cordova.getActivity()).endActivity();
            previousActivityName = null;
            callbackContext.success();
            return true;
        } else if (action.equals("sendEvent")) {

            String eventName;
            try {
                eventName = args.getString(0);
                String param = args.getString(1);
                Bundle b = stringToBundle(param);
                if (b == null) {
                    callbackContext.error("invalid param for sendEvent");
                    return true;
                }

                EngagementAgent.getInstance(cordova.getActivity()).sendEvent(eventName, b);
                callbackContext.success();
            } catch (JSONException e) {
                callbackContext.error("invalid args for sendEvent");
            }
            return true;
        } else if (action.equals("startJob")) {

            String jobName;
            try {
                jobName = args.getString(0);
                String param = args.getString(1);
                Bundle b = stringToBundle(param);
                if (b == null) {
                    callbackContext.error("invalid param for start Job");
                    return true;
                }
                EngagementAgent.getInstance(cordova.getActivity()).startJob(jobName, b);
            } catch (JSONException e) {
                callbackContext.error("invalid args for start Job");
            }
            return true;
        } else if (action.equals("endJob")) {

            String jobName;
            try {
                jobName = args.getString(0);
                EngagementAgent.getInstance(cordova.getActivity()).endJob(jobName );
                callbackContext.success();
            } catch (JSONException e) {
                callbackContext.error("invalid args for end Job");
            }
            return true;
        } else if (action.equals("sendAppInfo")) {
            String param;
            try {
                param = args.getString(0);
                Bundle b = stringToBundle(param);
                if (b == null) {
                    callbackContext.error("invalid param for sendAppInfo");
                    return true;
                }
                EngagementAgent.getInstance(cordova.getActivity()).sendAppInfo( b);
                callbackContext.success();

            } catch (JSONException e) {
                callbackContext.error("invalid args for sendAppInfo");
            }
            return true;
        } else if (action.equals("registerForPushNotification")) {
            // does nothing on Android
            callbackContext.success();
            return true;
        }
      
        String str = "Unrecognized Command : "+action;
        Log.e(AZME.LOG_TAG,str);
        callbackContext.error(str);
        return false;
    }

    public void onPause(boolean multitasking) {
        isPaused = true;
        EngagementAgent.getInstance(cordova.getActivity()).endActivity();
    }

    public void onResume(boolean multitasking) {
        if (previousActivityName != null)
            EngagementAgent.getInstance(cordova.getActivity()).startActivity(cordova.getActivity(), previousActivityName, null);
        isPaused = false;
        checkDataPush();
    }

}
