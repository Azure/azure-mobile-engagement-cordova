/*
 * Copyright (c) Microsoft Corporation.  All rights reserved.
 * Licensed under the MIT license. See License.txt in the project root for license information.
 */

#include <sys/types.h>
#include <sys/sysctl.h>
#include "AZME.h"
#import <Cordova/CDV.h>
#import <objc/runtime.h>
#import <objc/message.h>

#define AZME_PLUGIN_VERSION "2.0.0"
#define NATIVE_PLUGIN_VERSION "3.1.0"
#define CDVAZME_TAG @"[cdvazme-test] "

static bool enableLog = false;

@implementation AppDelegate(AZME)

bool hasDidReceiveRemoteNotificationFetchCompletionHandler = false;
bool hasDidFailToRegisterForRemoteNotificationsWithError = false;
bool hasDidReceiveRemoteNotification = false;
bool hasDidRegisterForRemoteNotificationsWithDeviceToken = false;

- (void)application:(UIApplication *)application  azmeDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if (enableLog)
        NSLog(CDVAZME_TAG @"azmeDidFailToRegisterForRemoteNotificationsWithError %@", error);
    
    if (hasDidFailToRegisterForRemoteNotificationsWithError)
         [self application:application azmeDidFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application  azmeDidReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    if (enableLog)
      NSLog(CDVAZME_TAG @"azmedidReceiveRemoteNotificationfetchCompletionHandler");

    [[EngagementAgent shared] applicationDidReceiveRemoteNotification:userInfo fetchCompletionHandler:handler];
    
    if (hasDidReceiveRemoteNotificationFetchCompletionHandler)
        [self application:application azmeDidReceiveRemoteNotification:userInfo fetchCompletionHandler:handler];
}

// IOS6 Support
- (void)application:(UIApplication*)application azmeDidReceiveRemoteNotification:(NSDictionary*)userInfo
{
    if (enableLog)
        NSLog(CDVAZME_TAG @"azmeDidReceiveRemoteNotification");

    [[EngagementAgent shared] applicationDidReceiveRemoteNotification:userInfo fetchCompletionHandler:nil];
    
    if (hasDidReceiveRemoteNotification)
         [self application:application azmeDidReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application azmeDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if (enableLog)
        NSLog(CDVAZME_TAG @"azmeDidRegisterForRemoteNotificationsWithDeviceToken");
    
    [[EngagementAgent shared] registerDeviceToken:deviceToken];
    
    if (hasDidRegisterForRemoteNotificationsWithDeviceToken)
        [self application:application azmeDidRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

// Use swizzling
// http://stackoverflow.com/questions/1085479/override-a-method-via-objc-category-and-call-the-default-implementation

+ (bool)swizzleInstanceSelector:(SEL)originalSelector
                 withNewSelector:(SEL)newSelector
{
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method newMethod = class_getInstanceMethod(self, newSelector);
    
    BOOL methodAdded = class_addMethod([self class],
                                       originalSelector,
                                       method_getImplementation(newMethod),
                                       method_getTypeEncoding(newMethod));
    
    if (methodAdded) {
        class_replaceMethod([self class],
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(newMethod));
        return false;
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
        return true;
    }
}

+ (void)load
{
    hasDidFailToRegisterForRemoteNotificationsWithError =
    [self swizzleInstanceSelector:@selector(application:didFailToRegisterForRemoteNotificationsWithError:)
                  withNewSelector:@selector(application:azmeDidFailToRegisterForRemoteNotificationsWithError:)];
    
    hasDidReceiveRemoteNotificationFetchCompletionHandler =
    [self swizzleInstanceSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)
                  withNewSelector:@selector(application:azmeDidReceiveRemoteNotification:fetchCompletionHandler:)];
    
    hasDidReceiveRemoteNotification =
    [self swizzleInstanceSelector:@selector(application:didReceiveRemoteNotification:)
                  withNewSelector:@selector(application:azmeDidReceiveRemoteNotification:)];
    
    hasDidRegisterForRemoteNotificationsWithDeviceToken =
    [self swizzleInstanceSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)
                  withNewSelector:@selector(application:azmeDidRegisterForRemoteNotificationsWithDeviceToken:)];
}

@end

@implementation AZME

- (void)pluginInitialize
{
    enableLog = false;

    NSString* AZME_IOS_CONNECTION_STRING = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AZME_IOS_CONNECTION_STRING"];
    NSString* AZME_IOS_REACH_ICON = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AZME_IOS_REACH_ICON"];
  
    NSString* str = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AZME_ENABLE_LOG"];
    if ([str compare:@"1"] == NSOrderedSame || [str caseInsensitiveCompare:@"true"] == NSOrderedSame )
        enableLog = true;


    if (AZME_IOS_CONNECTION_STRING.length != 0)
    {

        if (enableLog)
        {
            NSLog(CDVAZME_TAG @"Initializing AZME with ConnectionString:%@", AZME_IOS_CONNECTION_STRING);
            [EngagementAgent setTestLogEnabled:YES];
        }

        @try {

            AEReachModule* reach = nil;
            if (AZME_IOS_REACH_ICON.length > 0)
            {
                if (enableLog)
                    NSLog(CDVAZME_TAG @"Preparing Reach with Icon :%@", AZME_IOS_REACH_ICON);
                
                UIImage* icon = [UIImage imageNamed:AZME_IOS_REACH_ICON];
                if (icon == nil)
                    NSLog(CDVAZME_TAG @"*** Icon '%@' missing", AZME_IOS_REACH_ICON);

                reach = [AEReachModule moduleWithNotificationIcon:icon];
                if (reach == nil)
                    NSLog(CDVAZME_TAG @"*** Failed to initialize reach");
                else
                    [reach setAutoBadgeEnabled:YES];
            }

            [EngagementAgent init:AZME_IOS_CONNECTION_STRING modules:reach, nil];
        
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  [NSString stringWithUTF8String:AZME_PLUGIN_VERSION], @"CDVAZMEVersion",  nil];

            [[EngagementAgent shared] sendAppInfo:dict];

        }
        @catch (NSException * e) {
            NSLog(@"**** FAILED TO INITIALIZE AZME ***, Exception: %@", e);
        }
    }
    else
        NSLog(@"*** AZME_IOS_CONNECTION_STRING not set");
}

- (void)startActivity:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    NSString *name = [command.arguments objectAtIndex:0];
    NSString *param = [command.arguments objectAtIndex:1];
    NSDictionary *JSON ;

    JSON = [NSJSONSerialization     JSONObjectWithData: [param dataUsingEncoding:NSUTF8StringEncoding]
            options: NSJSONReadingMutableContainers
            error: nil];
    [[EngagementAgent shared] startActivity:name extras:JSON];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)endActivity:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];

    [[EngagementAgent shared] endActivity];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendEvent:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    NSString *name = [command.arguments objectAtIndex:0];
    NSString *param = [command.arguments objectAtIndex:1];
    NSDictionary *JSON ;

    JSON = [NSJSONSerialization     JSONObjectWithData: [param dataUsingEncoding:NSUTF8StringEncoding]
            options: NSJSONReadingMutableContainers
            error: nil];
    [[EngagementAgent shared] sendEvent:name extras:JSON];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)startJob:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    NSString *name = [command.arguments objectAtIndex:0];
    NSString *param = [command.arguments objectAtIndex:1];
    NSDictionary *JSON ;

    JSON = [NSJSONSerialization     JSONObjectWithData: [param dataUsingEncoding:NSUTF8StringEncoding]
            options: NSJSONReadingMutableContainers
            error: nil];
    [[EngagementAgent shared] startJob:name extras:JSON];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)endJob:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    NSString *name = [command.arguments objectAtIndex:0];

    [[EngagementAgent shared] endJob:name];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendAppInfo:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    NSString *param = [command.arguments objectAtIndex:0];
    NSDictionary *JSON ;

    JSON = [NSJSONSerialization JSONObjectWithData: [param dataUsingEncoding:NSUTF8StringEncoding]
            options: NSJSONReadingMutableContainers
            error: nil];
    [[EngagementAgent shared] sendAppInfo:JSON];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getStatus:(CDVInvokedUrlCommand*)command
{
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSString stringWithUTF8String:AZME_PLUGIN_VERSION], @"pluginVersion",
                           [NSString stringWithUTF8String:NATIVE_PLUGIN_VERSION], @"AZMEVersion", 
                          [[EngagementAgent shared] deviceId], @"deviceId",
                          nil];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsDictionary:dict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// CheckRedirect does nothing on iOS
- (void)checkRedirect:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsString:nil ];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)handleOpenURL:(NSNotification*)notification
{
    NSString* url = [notification object];
    
    if (enableLog)
        NSLog(CDVAZME_TAG @"handleOpenURL with :%@",url);

    NSString* jsString = [NSString stringWithFormat:@"AzureEngagement.handleOpenURL(\"%@\");", url];
    [self.commandDelegate evalJs:jsString];
}

- (void)registerForPushNotification:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];

    if (enableLog)
        NSLog(CDVAZME_TAG @"registerForPushNotification enabled");

    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
