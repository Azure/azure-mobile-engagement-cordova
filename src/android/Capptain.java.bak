/*
 * Copyright (c) 2014,2015 Oliver Goguel - o@goguel.com
 * Licensed under the Apache License, Version 2.0. See License.txt in the project root for license information.
 */

package com.del7a.capptain;

import java.util.Iterator;
import android.content.Context;
import android.content.Intent;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaActivity;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.os.Bundle;
import com.ubikod.capptain.android.sdk.CapptainAgent;
import com.ubikod.capptain.utils.CapptainUtils;

public class Capptain extends CordovaPlugin {
    private CordovaInterface cordova;
    private String previousActivityName = null;
    private String lastRedirect = null;
	private final String pluginVersion = "1.0.3";

    public void initialize(CordovaInterface _cordova, CordovaWebView webView) {

		CordovaActivity Activity =  (CordovaActivity) _cordova.getActivity();
    	final String invokeString = Activity.getIntent().getDataString();
    	if(invokeString != "" && invokeString != null)
    	{
    		lastRedirect = invokeString;
    		System.out.println("Preparing Redirect to "+lastRedirect);
    	}
        super.initialize(_cordova, webView);
        cordova = _cordova;

        Bundle b = new Bundle();   
		b.putString("CDVCapptainVersion",pluginVersion);
	    CapptainAgent.getInstance(cordova.getActivity()).sendAppInfo( b); 
    }

    private Bundle stringToBundle(String _param)
    {
		JSONObject jObj;
		try {
			jObj = new JSONObject(_param);
			Bundle b = new Bundle();   
			
			@SuppressWarnings("unchecked")
			Iterator<String> keys = jObj.keys();
			    while(keys.hasNext()){
			        String key = keys.next();
			        String val = jObj.getString(key);
			        b.putString(key, val);
			    }
			return b;
			
		} catch (JSONException e) {
			return null;
		}
    }
   
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext)   {
    
    	if (action.equals("checkRedirect")) {
    		callbackContext.success(lastRedirect);
    		lastRedirect=null;
	        return true;
	    }
	    if (action.equals("getStatus")) {
	    	JSONObject j;
        	String response = "{";
            response = "{"+
	            "\"pluginVersion\": \""+pluginVersion+"\","+
	            "\"capptainVersion\": \"2.4.1\","+
	            "\"deviceId\": \"?\""+ 	            
            "}";
      
	        try {
	            callbackContext.success(new JSONObject(response));
	        } catch (JSONException e) {
	            e.printStackTrace();
	            callbackContext.error("could not retrieve status");
	       	}
	       	return true;
   		}
	    else
    	if (action.equals("startActivity")) {
        	String activityName;
			try {
				activityName = args.getString(0);
				String param = args.getString(1);
	        	Bundle b = stringToBundle(param);
	        	if (b==null)
	        	{
	        		callbackContext.error("invalid param for startActivity");
	        		return true;
	        	}
	        	previousActivityName = activityName;
	        	CapptainAgent.getInstance(cordova.getActivity()).startActivity(cordova.getActivity(), activityName, b); 
	        	callbackContext.success();
			} catch (JSONException e) {
				callbackContext.error("invalid args for startActivity");
			}
			return true;
        }
        else
        if (action.equals("endActivity")) {
	        CapptainAgent.getInstance(cordova.getActivity()).endActivity();
	        previousActivityName= null;
	        callbackContext.success();
	        return true;
        }
        else
        if (action.equals("sendEvent")) {
    		
        	String eventName;
			try {
				eventName = args.getString(0);
				String param = args.getString(1);
	        	Bundle b = stringToBundle(param);
	        	if (b==null)
	        	{
	        		callbackContext.error("invalid param for sendEvent");
	        		return true;
	        	}

	        	CapptainAgent.getInstance(cordova.getActivity()).sendEvent(eventName, b); 
	        	callbackContext.success();
	      	} catch (JSONException e) {
				callbackContext.error("invalid args for sendEvent");
			}
			return true;
        }
        else
        if (action.equals("startJob")) {
    		
        	String jobName;
			try {
				jobName = args.getString(0);
	        	String param = args.getString(1);
	        	Bundle b = stringToBundle(param);
	        	if (b==null)
	        	{
	        		callbackContext.error("invalid param for start Job");
	        		return true;
	        	}
        		CapptainAgent.getInstance(cordova.getActivity()).startJob(jobName, b); 
        	} 
        	catch (JSONException e) {
				callbackContext.error("invalid args for start Job");
			}
			return true;
        }
        else
        if (action.equals("endJob")) {
    		
        	String jobName;
			try {
				jobName = args.getString(0);
				CapptainAgent.getInstance(cordova.getActivity()).endJob(jobName ); 
	        	callbackContext.success();
	        } catch (JSONException e) {
				callbackContext.error("invalid args for end Job");
			}
			return true;
        }
        else
        if (action.equals("sendAppInfo")) {
        	String param;
			try {
				param = args.getString(0);
				Bundle b = stringToBundle(param);
				if (b==null)
				{
					callbackContext.error("invalid param for sendAppInfo");
		        	return true;
				}
	        	CapptainAgent.getInstance(cordova.getActivity()).sendAppInfo( b); 
	        	callbackContext.success();
	        	
			} catch (JSONException e) {
				callbackContext.error("invalid args for sendAppInfo");
			}
			return true;
        }
		else
        if (action.equals("registerForPushNotification")) {
        	// does nothing on Android
	        callbackContext.success();
	        return true;
        }
        callbackContext.error("unrecognized command :"+action);
        return false;
    }

    public void onPause(boolean multitasking) {
    	CapptainAgent.getInstance(cordova.getActivity()).endActivity();
	}

    public void onResume(boolean multitasking) {
    	if (previousActivityName!=null)
    		CapptainAgent.getInstance(cordova.getActivity()).startActivity(cordova.getActivity(), previousActivityName, null);
    }

  
}
