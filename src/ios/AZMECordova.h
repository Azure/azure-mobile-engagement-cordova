/*
 * Copyright (c) Microsoft Corporation.  All rights reserved.
 * Licensed under the MIT license. See License.txt in the project root for license information.
 */


#import <Cordova/CDVPlugin.h>
 #import "AppDelegate.h"
#import "EngagementShared.h"

@interface AppDelegate (AZME)
- (void)application:(UIApplication *)application azmeDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)application:(UIApplication *)application azmeDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)application:(UIApplication *)application azmeDidReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler;
- (void)application:(UIApplication *)application azmeDidReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void)application:(UIApplication *)application azmeEmpty:(id)_fake;
+ (void)swizzleInstanceSelector:(SEL)originalSelector withNewSelector:(SEL)newSelector;
+ (void)load;
@end

@interface AZME: CDVPlugin <EngagementDelegate>

- (void)pluginInitialize;

// JS Interface

- (void)startActivity:(CDVInvokedUrlCommand*)command;
- (void)endActivity:(CDVInvokedUrlCommand*)command;

- (void)sendEvent:(CDVInvokedUrlCommand*)command;
- (void)sendAppInfo:(CDVInvokedUrlCommand*)command;
- (void)startJob:(CDVInvokedUrlCommand*)command;
- (void)endJob:(CDVInvokedUrlCommand*)command;

- (void)getStatus:(CDVInvokedUrlCommand*)command;
- (void)requestPermissions:(CDVInvokedUrlCommand*)command;

- (void)sendSessionEvent:(CDVInvokedUrlCommand*)command;
- (void)sendSessionError:(CDVInvokedUrlCommand*)command;
- (void)sendError:(CDVInvokedUrlCommand*)command;
- (void)sendJobEvent:(CDVInvokedUrlCommand*)command;
- (void)sendJobError:(CDVInvokedUrlCommand*)command;

// Cordova Delegate

- (void)handleOpenURL:(NSNotification*)notification;


@end


