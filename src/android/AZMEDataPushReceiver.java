
/*
 * Copyright (c) Microsoft Corporation.  All rights reserved.
 * Licensed under the MIT license. See License.txt in the project root for license information.
 */

package com.microsoft.azure.engagement.cordova;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Map;
import java.util.TreeMap;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import com.microsoft.azure.engagement.reach.EngagementReachDataPushReceiver;

public class AZMEDataPushReceiver extends EngagementReachDataPushReceiver
{
    public static final String AZME_PREFERENCES = "AZMEDataPush";

    //  http://stackoverflow.com/questions/607176/java-equivalent-to-javascripts-encodeuricomponent-that-produces-identical-outpu
    public static String encodeURIComponent(String s) {
        String result = null;

        try {
            
                result = URLEncoder.encode(s, "UTF-8")
                        .replaceAll("\\+", "%20")
                        .replaceAll("\\%21", "!")
                        .replaceAll("\\%28", "(")
                        .replaceAll("\\%29", ")")
                        .replaceAll("\\%7E", "~");
        }
        catch (UnsupportedEncodingException e) {
            Log.e(AZME.LOG_TAG,"Unsupported Encoding");
        }
        return result;
    }

    public static Map<String,String> getPendingDataPushes(Context context) {
        Map<String, String> smap = new TreeMap<String, String>();

        SharedPreferences settings = context.getSharedPreferences(AZME_PREFERENCES, 0/*MODE_PRIVATE*/);
        Map<String,?> m = settings.getAll();

        // convert to treemap to keep the order by timestamp
        for (Map.Entry<String, ?> entry : m.entrySet()) {
            smap.put(entry.getKey(), entry.getValue().toString());

        }
        // remove all
        settings.edit().clear().commit();

        return smap;
    }

    public void addDataPush(Context context,String category, String body) {
        SharedPreferences settings = context.getSharedPreferences(AZME_PREFERENCES, 0/*MODE_PRIVATE*/);
        SharedPreferences.Editor prefEditor = settings.edit();

        Long tsLong = System.currentTimeMillis()/1000;
        String ts = tsLong.toString();
        String value=  category+" "+body;
        prefEditor.putString(ts,value);
        prefEditor.commit();

        Log.i(AZME.LOG_TAG, "received data push ("+ts+") w/ category:"+category);
    }

    @Override
    protected Boolean onDataPushStringReceived(Context context, String category, String body) {

        if (category==null)
            category = "None";

        String encodedCategory = encodeURIComponent(category);
        String encodedBody = encodeURIComponent(body);
       
        addDataPush(context.getApplicationContext(), encodedCategory, encodedBody);
        if (AZME.singleton != null)
            AZME.singleton.checkDataPush();

        return true;
    }

    @Override
    protected Boolean onDataPushBase64Received(Context context, String category, byte[] decodedBody, String encodedBody) {
       
        if (category==null)
            category = "None";
        
        String encodedCategory = encodeURIComponent(category);
        addDataPush(context.getApplicationContext(),encodedCategory,encodedBody);
        if (AZME.singleton != null)
            AZME.singleton.checkDataPush();

        return true;
    }
}