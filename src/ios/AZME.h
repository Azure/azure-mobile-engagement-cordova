/*
 * Copyright (c) Microsoft Corporation.  All rights reserved.
 * Licensed under the MIT license. See License.txt in the project root for license information.
 */

#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>
#import "AZME.h"
#import "EngagementAgent.h"
#import "AEPushDelegate.h"
#import "AppDelegate.h"

#import "AEReachModule.h"

@interface AppDelegate (AZME)
- (void)application:(UIApplication *)application customdidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)application:(UIApplication *)application customdidFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)application:(UIApplication *)application customdidReceiveRemoteNotification:(NSDictionary *)userInfo;
@end

@interface AZME : CDVPlugin <AEPushDelegate>
{
    NSString* AZME_IOS_SDKKEY ;
    NSString* AZME_IOS_APPID ;
    NSString* AZME_IOS_COLLECTION ;
    NSString* AZME_IOS_REACH_ICON;
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
