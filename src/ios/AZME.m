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

#define AZME_PLUGIN_VERSION @"2.2.0"
#define NATIVE_PLUGIN_VERSION @"3.1.0"
#define CDVAZME_TAG @"[cdvazme-test] "
#define CDVAZME_ERROR @"[cdvazme-test] ERROR: "

static bool enableLog = false;

@implementation AppDelegate(AZME)

// Use swizzling
// http://stackoverflow.com/questions/1085479/override-a-method-via-objc-category-and-call-the-default-implementation

- (void)application:(UIApplication *)application  azmeDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if (enableLog)
        NSLog(CDVAZME_TAG @"azmeDidFailToRegisterForRemoteNotificationsWithError %@", error);
    
    // call the previous implementation (and not itself!)
    [self application:application azmeDidFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application  azmeDidReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    if (enableLog)
        NSLog(CDVAZME_TAG @"azmedidReceiveRemoteNotificationfetchCompletionHandler");
    
    [[EngagementAgent shared] applicationDidReceiveRemoteNotification:userInfo fetchCompletionHandler:handler];
    
    // call the previous implementation (and not itself!)
    [self application:application azmeDidReceiveRemoteNotification:userInfo fetchCompletionHandler:handler];
}

// IOS6 Support
- (void)application:(UIApplication*)application azmeDidReceiveRemoteNotification:(NSDictionary*)userInfo
{
    if (enableLog)
        NSLog(CDVAZME_TAG @"azmeDidReceiveRemoteNotification");
    
    [[EngagementAgent shared] applicationDidReceiveRemoteNotification:userInfo fetchCompletionHandler:nil];
    
    // call the previous implementation (and not itself!)
    [self application:application azmeDidReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application azmeDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if (enableLog)
        NSLog(CDVAZME_TAG @"azmeDidRegisterForRemoteNotificationsWithDeviceToken");
    
    [[EngagementAgent shared] registerDeviceToken:deviceToken];
    
    // call the previous implementation (and not itself!)
    [self application:application azmeDidRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

//  used in case the "parent" delegate was not implemented
- (void)application:(UIApplication *)application azmeEmpty:(id)_fake
{
    
}

+ (void)swizzleInstanceSelector:(SEL)originalSelector withNewSelector:(SEL)newSelector
{
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method newMethod = class_getInstanceMethod(self, newSelector);
    
    // if the original Method does not exist, replace it with an empty implementation
    if (originalMethod==nil)
    {
        Method emptyMethod = class_getInstanceMethod(self, @selector(application:azmeEmpty:));
        BOOL methodAdded = class_addMethod([self class],
                                           originalSelector,
                                           method_getImplementation(emptyMethod), // empty code
                                           method_getTypeEncoding(newMethod)); // but keep signature
        
        if (methodAdded==false)
            NSLog(CDVAZME_TAG @"Failed to add method %@",NSStringFromSelector(originalSelector));
        
        originalMethod = class_getInstanceMethod(self, originalSelector);
    }
    
    method_exchangeImplementations(originalMethod, newMethod);
}

+ (void)load
{
    
    NSString* str = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AZME_ENABLE_LOG"];
    enableLog = ([str compare:@"1"] == NSOrderedSame || [str caseInsensitiveCompare:@"true"] == NSOrderedSame );
    
    if (enableLog)
        NSLog(CDVAZME_TAG @"Plugin cordova-plugin-ms-azure-mobile-engagement v" AZME_PLUGIN_VERSION " (SDK Version "NATIVE_PLUGIN_VERSION")");
    
    [self swizzleInstanceSelector:@selector(application:didFailToRegisterForRemoteNotificationsWithError:)
                  withNewSelector:@selector(application:azmeDidFailToRegisterForRemoteNotificationsWithError:)];
    
    [self swizzleInstanceSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)
                  withNewSelector:@selector(application:azmeDidReceiveRemoteNotification:fetchCompletionHandler:)];
    
    [self swizzleInstanceSelector:@selector(application:didReceiveRemoteNotification:)
                  withNewSelector:@selector(application:azmeDidReceiveRemoteNotification:)];
    
    [self swizzleInstanceSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)
                  withNewSelector:@selector(application:azmeDidRegisterForRemoteNotificationsWithDeviceToken:)];
}

@end

@implementation AZME

- (void)pluginInitialize
{
    
    NSString* AZME_IOS_CONNECTION_STRING = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AZME_IOS_CONNECTION_STRING"];
    NSString* AZME_IOS_REACH_ICON = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AZME_IOS_REACH_ICON"];
    NSString* AZME_LAZYAREA_LOCATION = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AZME_LAZYAREA_LOCATION"];
    NSString* AZME_REALTIME_LOCATION = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AZME_REALTIME_LOCATION"];
    NSString* AZME_FINEREALTIME_LOCATION = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AZME_FINEREALTIME_LOCATION"];
    NSString* AZME_BACKGROUND_REPORTING = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AZME_BACKGROUND_REPORTING"];
    NSString* AZME_FOREGROUND_REPORTING = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AZME_FOREGROUND_REPORTING"];
    
    bool lazyareaLocation =  AZME_LAZYAREA_LOCATION && [ AZME_LAZYAREA_LOCATION caseInsensitiveCompare:@"true"] == NSOrderedSame ;
    bool realtimeLocation =  AZME_REALTIME_LOCATION && [ AZME_REALTIME_LOCATION caseInsensitiveCompare:@"true"] == NSOrderedSame ;
    bool finerealtimeLocation =  AZME_FINEREALTIME_LOCATION && [ AZME_FINEREALTIME_LOCATION caseInsensitiveCompare:@"true"] == NSOrderedSame ;
    bool foregroundReporting = AZME_FOREGROUND_REPORTING && [ AZME_FOREGROUND_REPORTING caseInsensitiveCompare:@"true"] == NSOrderedSame ;
    bool backgroundReporting = AZME_BACKGROUND_REPORTING && [ AZME_BACKGROUND_REPORTING caseInsensitiveCompare:@"true"] == NSOrderedSame ;
    
    readyForPush = false;
    readyForURL  = false;
    lastURL = nil;
    dataPushes  = [[NSMutableArray alloc] init];
    
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
                    NSLog(CDVAZME_TAG @"Preparing Reach Module with Icon :%@", AZME_IOS_REACH_ICON);
                
                UIImage* icon = [UIImage imageNamed:AZME_IOS_REACH_ICON];
                if (icon == nil)
                    NSLog(CDVAZME_ERROR @"Icon '%@' missing (must be added in the XCode project)", AZME_IOS_REACH_ICON);
                
                reach = [AEReachModule moduleWithNotificationIcon:icon];
                if (reach == nil)
                    NSLog(CDVAZME_ERROR @"Failed to initialize reach");
                else
                {
                    [reach setAutoBadgeEnabled:YES];
                    [reach setDataPushDelegate:self];

                #if TARGET_IPHONE_SIMULATOR
                    NSLog(CDVAZME_TAG @"Running on iOS Simulator -- push notifications are disabled");        
                #endif

                }
            }

            [EngagementAgent init:AZME_IOS_CONNECTION_STRING modules:reach, nil];

            if ( lazyareaLocation )
            {
                [[EngagementAgent shared] setLazyAreaLocationReport:YES];
                if (enableLog)
                    NSLog(CDVAZME_TAG @"Lazy Area Location enabled");
            }
            else
            if ( realtimeLocation )
            {
                [[EngagementAgent shared] setRealtimeLocationReport:YES];
                if (enableLog)
                    NSLog(CDVAZME_TAG @"Real Time Location enabled");

            }
            else
            if ( finerealtimeLocation )
            {
                [[EngagementAgent shared] setRealtimeLocationReport:YES];
                [[EngagementAgent shared] setFineRealtimeLocationReport:YES];
                if (enableLog)
                    NSLog(CDVAZME_TAG @"Fine Real Time Location enabled");

            }

            if ( backgroundReporting )
            {
                if ( realtimeLocation || finerealtimeLocation )
                {
         
                    [[EngagementAgent shared] setBackgroundRealtimeLocationReport:YES withLaunchOptions:nil];
                      if (enableLog)
                        NSLog(CDVAZME_TAG @"Enabling Background Mode for realtime reporting");
                }
                else
                     NSLog(CDVAZME_ERROR @"Background mode requires realtime location");
            }
            else
            if (foregroundReporting)
            {
                if ( lazyareaLocation || realtimeLocation || finerealtimeLocation )
                {

                }
                else
                     NSLog(CDVAZME_ERROR @"Location required when using Foreground Location");
            }
            else
            {
                if ( lazyareaLocation || realtimeLocation || finerealtimeLocation )
                {
                        NSLog(CDVAZME_ERROR @"Foreground or Background required when using Location");
                }
            }
            
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  AZME_PLUGIN_VERSION, @"CDVAZMEVersion",  nil];
            
            [[EngagementAgent shared] sendAppInfo:dict];
            
        }
        @catch (NSException * e) {
            NSLog(CDVAZME_ERROR @"Failed to initialize AZME, Exception: %@", e);
        }
    }
    else
        NSLog( CDVAZME_ERROR @"AZME_IOS_CONNECTION_STRING not set");
    
}

-(void)processDataPush
{
    if (readyForPush == FALSE)
        return ;
    
    for (NSArray* push in dataPushes) {
     
        NSString* encodedCategory = push[0];
        NSString* encodedBody = push[1];

        if (enableLog)
             NSLog(CDVAZME_TAG @"handling data push w/ category %@", encodedCategory);

        NSString* jsString = [NSString stringWithFormat:@"AzureEngagement.handleDataPush({\"category\":\"%@\",\"body\":\"%@\"});", encodedCategory,encodedBody ];
        [self.commandDelegate evalJs:jsString];
    }
    
    [dataPushes removeAllObjects];
    
}

-(void)addDataPush:(NSString*)category withBody:(NSString*)body
{
    NSArray* push = [NSArray arrayWithObjects:category,body,nil];
    [dataPushes addObject:push];
    [self processDataPush];
    
}

-(BOOL)didReceiveStringDataPushWithCategory:(NSString*)category body:(NSString*)body
{
 
    if (category==nil)
        category=@"None";
    
    if (enableLog)
        NSLog(CDVAZME_TAG @"received string data push message w/ category: %@", category);

    NSString* encodedCategory= [category stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* encodedBody = [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self addDataPush:encodedCategory withBody:encodedBody];
    
   return YES;
}

-(BOOL)didReceiveBase64DataPushWithCategory:(NSString*)category decodedBody:(NSData *)decodedBody encodedBody:(NSString *)encodedBody
{
    if (category==nil)
        category=@"None";
    
    if (enableLog)
         NSLog(CDVAZME_TAG @"received base64 data push message w/ category: %@", category);

    NSString* encodedCategory= [category stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self addDataPush:encodedCategory withBody:encodedBody];
    
   return YES;
}

- (void)startActivity:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    NSString *name = [command.arguments objectAtIndex:0];
    NSString *param = [command.arguments objectAtIndex:1];
    NSDictionary *JSON ;
    
    if (enableLog)
        NSLog(CDVAZME_TAG @"startActivity:%@",name);
    
    JSON = [NSJSONSerialization     JSONObjectWithData: [param dataUsingEncoding:NSUTF8StringEncoding]
                                               options: NSJSONReadingMutableContainers
                                                 error: nil];
    [[EngagementAgent shared] startActivity:name extras:JSON];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)endActivity:(CDVInvokedUrlCommand*)command
{
    
    if (enableLog)
        NSLog(CDVAZME_TAG @"endActivity");
    
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
    
    if (enableLog)
        NSLog(CDVAZME_TAG @"sendEvent:%@",name);
    
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
    
    if (enableLog)
        NSLog(CDVAZME_TAG @"startJob:%@",name);
    
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
    
    if (enableLog)
        NSLog(CDVAZME_TAG @"endJob:%@",name);
    
    [[EngagementAgent shared] endJob:name];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendAppInfo:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    NSString *param = [command.arguments objectAtIndex:0];
    NSDictionary *JSON ;
    
    if (enableLog)
        NSLog(CDVAZME_TAG @"sendAppInfo:%@",param);
    
    JSON = [NSJSONSerialization JSONObjectWithData: [param dataUsingEncoding:NSUTF8StringEncoding]
                                           options: NSJSONReadingMutableContainers
                                             error: nil];
    [[EngagementAgent shared] sendAppInfo:JSON];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getStatus:(CDVInvokedUrlCommand*)command
{
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          AZME_PLUGIN_VERSION, @"pluginVersion",
                          NATIVE_PLUGIN_VERSION, @"AZMEVersion",
                          [[EngagementAgent shared] deviceId], @"deviceId",
                          nil];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsDictionary:dict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void)checkRedirect:(CDVInvokedUrlCommand*)command
{
    NSString *type = [command.arguments objectAtIndex:0];
    CDVPluginResult* pluginResult ;

    if (enableLog)
        NSLog(CDVAZME_TAG @"checkRedirect:%@",type);

    if ([type compare:@"url"]==NSOrderedSame)
    {
        readyForURL = true;
        [self processURL];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsString:nil ];
    }
    else
    if ([type compare:@"data"]==NSOrderedSame)
    {
        readyForPush = true;
        [self processDataPush];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsString:nil ];
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR  messageAsString:@"unsupported type" ];
    }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


-(void)processURL
{
    if (readyForURL == FALSE || lastURL==nil)
        return ;
    
    if (enableLog)
        NSLog(CDVAZME_TAG @"processing URL : %@",lastURL);
    
    NSString* jsString = [NSString stringWithFormat:@"AzureEngagement.handleOpenURL(\"%@\");", lastURL];
    [self.commandDelegate evalJs:jsString];
    lastURL = nil;
}

- (void)handleOpenURL:(NSNotification*)notification
{
    NSString* url = [notification object];
    
    if (enableLog)
        NSLog(CDVAZME_TAG @"handling URL :%@",url);
    
    lastURL = url;
    [self processURL];
   
}

- (void)registerForPushNotification:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    
    if (enableLog)
        NSLog(CDVAZME_TAG @"register the application for Push notifications");
    
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
