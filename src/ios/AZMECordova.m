/*
 * Copyright (c) Microsoft Corporation.  All rights reserved.
 * Licensed under the MIT license. See License.txt in the project root for license information.
 */

#include <sys/types.h>
#include <sys/sysctl.h>
#import <Cordova/CDV.h>
#import <objc/runtime.h>
#import <objc/message.h>
#include "AZMECordova.h"

#define AZME_PLUGIN_VERSION @"3.0.0"
#define NATIVE_PLUGIN_VERSION @"3.1.0" 
#define SDK_NAME @"CDVAZME"

EngagementShared* engagementSharedSingleton;

@implementation AppDelegate(AZME)

// Use swizzling
// http://stackoverflow.com/questions/1085479/override-a-method-via-objc-category-and-call-the-default-implementation

- (void)application:(UIApplication *)application  azmeDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [engagementSharedSingleton didFailToRegisterForRemoteNotificationsWithError:error ];
     
    // call the previous implementation (and not itself!)
    [self application:application azmeDidFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application  azmeDidReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    [engagementSharedSingleton didReceiveRemoteNotification:userInfo fetchCompletionHandler:handler ];
    
    // call the previous implementation (and not itself!)
    [self application:application azmeDidReceiveRemoteNotification:userInfo fetchCompletionHandler:handler];
}

// IOS6 Support
- (void)application:(UIApplication*)application azmeDidReceiveRemoteNotification:(NSDictionary*)userInfo
{
    [engagementSharedSingleton didReceiveRemoteNotification:userInfo];
    
    // call the previous implementation (and not itself!)
    [self application:application azmeDidReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application azmeDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{

    [engagementSharedSingleton didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    
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
            NSLog( @"%@Failed to add method %@",ENGAGEMENT_ERRORTAG,NSStringFromSelector(originalSelector));
        
        originalMethod = class_getInstanceMethod(self, originalSelector);
    }
    
    method_exchangeImplementations(originalMethod, newMethod);
}
     
+(void)load
{
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

+(void)load
{
    NSString* str = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AZME_ENABLE_LOG"];
    BOOL enableLog = ([str compare:@"1"] == NSOrderedSame || [str caseInsensitiveCompare:@"true"] == NSOrderedSame );
 
    engagementSharedSingleton = [[EngagementShared alloc] init:SDK_NAME withPluginVersion:AZME_PLUGIN_VERSION withNativeVersion:NATIVE_PLUGIN_VERSION];
    [engagementSharedSingleton enablePluginLog:enableLog];
    [engagementSharedSingleton enableNativeLog:enableLog];

}
     
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
    
    locationReportingType reportingType = LOCATIONREPORTING_NONE;
    
    if (lazyareaLocation)
        reportingType = LOCATIONREPORTING_LAZY;
    else
    if (realtimeLocation)
        reportingType = LOCATIONREPORTING_REALTIME;
    else
    if (finerealtimeLocation)
        reportingType = LOCATIONREPORTING_FINEREALTIME;
    
    backgroundReportingType reportingMode = BACKGROUNDREPORTING_NONE;
    if (foregroundReporting)
        reportingMode = BACKGROUNDREPORTING_FOREGROUND ;
    else
    if (backgroundReporting)
         reportingMode = BACKGROUNDREPORTING_BACKGROUND ;

   [engagementSharedSingleton   initialize:AZME_IOS_CONNECTION_STRING
                    withReachEnabled:[NSNumber numberWithBool:true] // Always on ON!
                    withReachIcon:AZME_IOS_REACH_ICON
                    withLocation:reportingType
                    backgroundReporting:reportingMode
                    withDelegate:self] ;
}

// EngagementShared Delegates

- (void)didReceiveDataPush:(NSString*)_category withBody:(NSString*)_body isBase64:(NSNumber*)_isBase64
{
    
    NSDictionary* JSON = [NSDictionary dictionaryWithObjectsAndKeys:
                          _category, @"category",
                          _body, @"body",
                          _isBase64, @"isBase64",
                          nil];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:JSON options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString* js = [NSString stringWithFormat:@"Engagement.handleDataPush(%@);",jsonString];
    [self.commandDelegate evalJs:js];
    
}

- (void)didReceiveURL:(NSString*)_url
{
    NSString* jsString = [NSString stringWithFormat:@"Engagement.handleOpenURL(\"%@\");", _url];
    [self.commandDelegate evalJs:jsString];
    
}

// JS Interface
                                  

- (void)startActivity:(CDVInvokedUrlCommand*)command
{
    NSString *name = [command.arguments objectAtIndex:0];
    NSString *param = [command.arguments objectAtIndex:1];
        
    [engagementSharedSingleton startActivity:name withExtraInfos:param];
        
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void)endActivity:(CDVInvokedUrlCommand*)command
{
    
    [engagementSharedSingleton endActivity];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendEvent:(CDVInvokedUrlCommand*)command
{
   
    NSString *name = [command.arguments objectAtIndex:0];
    NSString *param = [command.arguments objectAtIndex:1];
    [engagementSharedSingleton sendEvent:name withExtraInfos:param];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendAppInfo:(CDVInvokedUrlCommand*)command
{
   
    NSString *param = [command.arguments objectAtIndex:0];
    [engagementSharedSingleton sendAppInfo:param];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

}

- (void)startJob:(CDVInvokedUrlCommand*)command
{
   
    NSString *name = [command.arguments objectAtIndex:0];
    NSString *param = [command.arguments objectAtIndex:1];
  
    [engagementSharedSingleton startJob:name withExtraInfos:param];
    
     CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)endJob:(CDVInvokedUrlCommand*)command
{
   
    NSString *name = [command.arguments objectAtIndex:0];
    
   [engagementSharedSingleton endJob:name];
    
     CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendSessionEvent:(CDVInvokedUrlCommand*)command
{
    NSString *evtname = [command.arguments objectAtIndex:0];
    NSString *extraInfos = [command.arguments objectAtIndex:1];
  
    [engagementSharedSingleton sendSessionEvent:evtname withExtraInfos:extraInfos];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void)sendSessionError:(CDVInvokedUrlCommand*)command
{
    NSString *error = [command.arguments objectAtIndex:0];
    NSString *extraInfos = [command.arguments objectAtIndex:1];
  
    [engagementSharedSingleton sendSessionError:error withExtraInfos:extraInfos];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendError:(CDVInvokedUrlCommand*)command
{
    NSString *error = [command.arguments objectAtIndex:0];
    NSString *extraInfos = [command.arguments objectAtIndex:1];
  
    [engagementSharedSingleton sendError:error withExtraInfos:extraInfos];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendJobEvent:(CDVInvokedUrlCommand*)command
{
    NSString *eventName = [command.arguments objectAtIndex:0];
    NSString *jobName = [command.arguments objectAtIndex:1];
    NSString *extraInfos = [command.arguments objectAtIndex:2];
  
    [engagementSharedSingleton sendJobEvent:eventName inJob:jobName withExtraInfos:extraInfos];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendJobError:(CDVInvokedUrlCommand*)command
{
    NSString *error = [command.arguments objectAtIndex:0];
    NSString *jobName = [command.arguments objectAtIndex:1];
    NSString *extraInfos = [command.arguments objectAtIndex:2];
  
    [engagementSharedSingleton sendJobError:error inJob:jobName withExtraInfos:extraInfos];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getStatus:(CDVInvokedUrlCommand*)command
{
    NSDictionary* dict = [engagementSharedSingleton getStatus];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsDictionary:dict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void)enableURL:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsString:nil ];
    [engagementSharedSingleton enableURL];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)enableDataPush:(CDVInvokedUrlCommand*)command
{

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsString:nil ];
    [engagementSharedSingleton registerForPushNotification];
    [engagementSharedSingleton enablePush];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


// Does nothing on iOS
- (void)requestPermissions:(CDVInvokedUrlCommand*)command
{  
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsString:nil ];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// Cordova Delegates

- (void)handleOpenURL:(NSNotification*)notification
{
    NSString* url = [notification object];
    [engagementSharedSingleton handleOpenURL:url];
}
 
@end
