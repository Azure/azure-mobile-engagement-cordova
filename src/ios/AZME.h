/*
 * Copyright (c) Microsoft Corporation.  All rights reserved.
 * Licensed under the MIT license. See License.txt in the project root for license information.
 */

#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>
#import "AZME.h"
#import "EngagementAgent.h"
#import "AEReachDataPushDelegate.h"
#import "AppDelegate.h"
#import "AEReachModule.h"

@interface AppDelegate (AZME)
- (void)application:(UIApplication *)application customdidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)application:(UIApplication *)application customdidFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)application:(UIApplication *)application customdidReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler;
- (void)application:(UIApplication *)application customdidReceiveRemoteNotification:(NSDictionary *)userInfo ;
@end

@interface AZME : CDVPlugin <AEReachDataPushDelegate>
{
    BOOL enableLog;
}

- (void)startActivity:(CDVInvokedUrlCommand*)command;
- (void)endActivity:(CDVInvokedUrlCommand*)command;
- (void)sendAppInfo:(CDVInvokedUrlCommand*)command;
- (void)sendEvent:(CDVInvokedUrlCommand*)command;
- (void)startJob:(CDVInvokedUrlCommand*)command;
- (void)endJob:(CDVInvokedUrlCommand*)command;
- (void)checkRedirect:(CDVInvokedUrlCommand*)command;
- (void)getStatus:(CDVInvokedUrlCommand*)command;
- (void)handleOpenURL:(NSNotification*)notification;
@end
