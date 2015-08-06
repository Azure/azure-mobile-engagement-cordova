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

@implementation AppDelegate(AZME)

- (void)application:(UIApplication *)application  customdidFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError %@", error);
}

- (void)application:(UIApplication *)application  customdidReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    NSLog(@"customdidReceiveRemoteNotification");
    [[EngagementAgent shared] applicationDidReceiveRemoteNotification:userInfo fetchCompletionHandler:handler];
}

- (void)application:(UIApplication *)application customdidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[EngagementAgent shared] registerDeviceToken:deviceToken];
}

// Use swizzling
// http://stackoverflow.com/questions/1085479/override-a-method-via-objc-category-and-call-the-default-implementation

void MethodSwizzle(Class c, SEL orig, SEL new) 
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

+(void) load
{
    MethodSwizzle(self,
                  @selector(application:customdidFailToRegisterForRemoteNotificationsWithError:),
                  @selector(application:didFailToRegisterForRemoteNotificationsWithError:) );

    MethodSwizzle(self,

                  @selector(application:customdidReceiveRemoteNotification:fetchCompletionHandler:),
                  @selector( application:didReceiveRemoteNotification:fetchCompletionHandler:) );

    MethodSwizzle(self,
                  @selector(application:customdidRegisterForRemoteNotificationsWithDeviceToken:),
                  @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:) );
}

@end

@implementation AZME

- (void)pluginInitialize
{
    enableLog = false;

    AZME_IOS_SDKKEY = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AZME_IOS_SDKKEY"];
    AZME_IOS_APPID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AZME_IOS_APPID"];
    AZME_IOS_COLLECTION = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AZME_IOS_COLLECTION"];
    AZME_IOS_REACH_ICON = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AZME_IOS_REACH_ICON"];
    NSString* str = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AZME_ENABLE_LOG"];

    if ([str compare:@"1"] == NSOrderedSame || [str caseInsensitiveCompare:@"true"] == NSOrderedSame )
        enableLog = true;

    if (AZME_IOS_SDKKEY.length != 0 && AZME_IOS_APPID.length != 0 && AZME_IOS_COLLECTION.length != 0)
    {

        NSLog(@"Initializing AZME for AppId:%@", AZME_IOS_APPID);

        @try {

            AEReachModule* reach = nil;
            if (AZME_IOS_REACH_ICON.length > 0)
            {
                NSLog(@"Preparing Reach with Icon :%@", AZME_IOS_REACH_ICON);
                reach = [AEReachModule moduleWithNotificationIcon:[UIImage imageNamed:AZME_IOS_REACH_ICON]];
                [reach setAutoBadgeEnabled:YES];
            }

            NSString* endPoint = [NSString stringWithFormat:@"Endpoint=%@;SdkKey=%@;AppId=%@", AZME_IOS_COLLECTION, AZME_IOS_SDKKEY, AZME_IOS_APPID];
            [EngagementAgent init:endPoint modules:reach, nil];
                        
            if (reach != nil )
                [reach setDataPushDelegate:self];

            if (enableLog)
                [EngagementAgent setTestLogEnabled:YES];

            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  [NSString stringWithUTF8String:AZME_PLUGIN_VERSION],  @"CDVAZMEVersion",  nil];

            [[EngagementAgent shared] sendAppInfo:dict];

        }
        @catch (NSException * e) {
            NSLog(@"**** FAILED TO INITIALIZE AZME ***, Exception: %@", e);
        }
    }
    else
        NSLog(@"*** AZME_IOS_APPID, AZME_IOS_SDKKEY or AZME_IOS_COLLECTION not set");
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
                          @"3.0.0", @"AZMEVersion", // à récuperer du SDK!
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
    NSString* jsString = [NSString stringWithFormat:@"AzureEngagement.handleOpenURL(\"%@\");", url];
    [self.commandDelegate evalJs:jsString];
}

- (void)registerForPushNotification:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];

    if (enableLog)
        NSLog(@"registerForPushNotification");

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
