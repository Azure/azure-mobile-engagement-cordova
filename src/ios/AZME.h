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
- (void)application:(UIApplication *)application azmeDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)application:(UIApplication *)application azmeDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)application:(UIApplication *)application azmeDidReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler;
- (void)application:(UIApplication *)application azmeDidReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void)application:(UIApplication *)application azmeEmpty:(id)_fake;
+ (void)swizzleInstanceSelector:(SEL)originalSelector withNewSelector:(SEL)newSelector;
+ (void)load;
@end

@interface AZME : CDVPlugin <AEReachDataPushDelegate>
{
    bool readyForPush;
    NSMutableArray*  dataPushes ;
}
- (void)pluginInitialize;
- (void)processDataPush;
- (void)addDataPush:(NSString*)category withBody:(NSString*)body;
- (BOOL)didReceiveStringDataPushWithCategory:(NSString*)category body:(NSString*)body;
-(BOOL)didReceiveBase64DataPushWithCategory:(NSString*)category decodedBody:(NSData *)decodedBody encodedBody:(NSString *)encodedBody;
- (void)startActivity:(CDVInvokedUrlCommand*)command;
- (void)endActivity:(CDVInvokedUrlCommand*)command;
- (void)sendAppInfo:(CDVInvokedUrlCommand*)command;
- (void)sendEvent:(CDVInvokedUrlCommand*)command;
- (void)startJob:(CDVInvokedUrlCommand*)command;
- (void)endJob:(CDVInvokedUrlCommand*)command;
- (void)checkRedirect:(CDVInvokedUrlCommand*)command;
- (void)getStatus:(CDVInvokedUrlCommand*)command;
- (void)handleOpenURL:(NSNotification*)notification;
- (void)registerForPushNotification:(CDVInvokedUrlCommand*)command;
@end
