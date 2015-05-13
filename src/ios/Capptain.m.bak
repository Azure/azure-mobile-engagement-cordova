/*
 * Copyright (c) 2014,2015 Oliver Goguel - o@goguel.com
 * Licensed under the Apache License, Version 2.0. See License.txt in the project root for license information.
 */

#include <sys/types.h>
#include <sys/sysctl.h>
#include "Capptain.h"
#import <Cordova/CDV.h>
#import <objc/runtime.h>
#import <objc/message.h>

#define CAPPTAIN_PLUGIN_VERSION "1.0.3"

@implementation AppDelegate(Capptain)

- (void)application:(UIApplication *)application  customdidFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError %@",error);
}

- (void)application:(UIApplication *)application  customdidReceiveRemoteNotification:(NSDictionary *)userInfo
{
     NSLog(@"customdidReceiveRemoteNotification");
    [[CapptainAgent shared] applicationDidReceiveRemoteNotification:userInfo];
}


- (void)application:(UIApplication *)application customdidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[CapptainAgent shared] registerDeviceToken:deviceToken];
}

// Use swizzling
// http://stackoverflow.com/questions/1085479/override-a-method-via-objc-category-and-call-the-default-implementation

void MethodSwizzle(Class c, SEL orig, SEL new) {
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
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
                  @selector(application:customdidReceiveRemoteNotification:),
                  @selector(application:didReceiveRemoteNotification:) );
    
    MethodSwizzle(self,
                  @selector(application:customdidRegisterForRemoteNotificationsWithDeviceToken:),
                  @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:) );
    
}

@end


@implementation Capptain


- (void)pluginInitialize
{
    
    enableLog = false;

    capptainAppId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CapptainAppId"];
    capptainAppKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CapptainSDKKey"];
    capptainReachIcon = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CapptainReachIcon"];
    NSString* str = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CapptainEnableLog"];
    
    if ([str compare:@"1"] == NSOrderedSame || [str caseInsensitiveCompare:@"true"] == NSOrderedSame )
        enableLog = true;

    if (capptainAppId.length!=0 && capptainAppKey.length!=0)
    {
        
        NSLog(@"Initializing Capptain with appId :%@",capptainAppId);
    
        @try {
            
            CPReachModule* reach = nil;
            if (capptainReachIcon.length>0)
            {
                if  ([capptainReachIcon compare:@"{{capptain_reach_icon}}"]==NSOrderedSame)
                {
                    NSLog(@"**** CapptainReachIcon not set ***");
                }
                else
                {
                    NSLog(@"Preparing Reach with Icon :%@",capptainReachIcon);
                    reach = [CPReachModule moduleWithNotificationIcon:[UIImage imageNamed:capptainReachIcon]];
                    [reach setAutoBadgeEnabled:YES];
                 }
            }
            
            [CapptainAgent registerApp:capptainAppId identifiedBy:capptainAppKey modules:reach, nil];
            if (reach !=nil )
                  [[CapptainAgent shared] setPushDelegate:self];
          

            if (enableLog)
                [CapptainAgent setTestLogEnabled:YES];

            
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [NSString stringWithUTF8String:CAPPTAIN_PLUGIN_VERSION],  @"CDVCapptainVersion",  nil];

            [[CapptainAgent shared] sendAppInfo:dict];

        }
        @catch (NSException * e) {
            NSLog(@"**** FAILED TO INITIALIZE CAPPTAIN ***, Exception: %@", e);
        }
    }
    else
        NSLog(@"*** CapptainAppId or CapptainSDKKey not set");

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
    [[CapptainAgent shared] startActivity:name extras:JSON];
       
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)endActivity:(CDVInvokedUrlCommand*)command
{
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
   
    [[CapptainAgent shared] endActivity];
    
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
    [[CapptainAgent shared] sendEvent:name extras:JSON];
        
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
    [[CapptainAgent shared] startJob:name extras:JSON];
       
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)endJob:(CDVInvokedUrlCommand*)command
{

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK ];
    NSString *name = [command.arguments objectAtIndex:0];
  
    [[CapptainAgent shared] endJob:name];
        
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
    [[CapptainAgent shared] sendAppInfo:JSON];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getStatus:(CDVInvokedUrlCommand*)command
{
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithUTF8String:CAPPTAIN_PLUGIN_VERSION],@"pluginVersion",
                            @"1.16.2",@"capptainVersion", // à récuperer du SDK!
                            [[CapptainAgent shared] deviceId],@"deviceId",
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
    NSString* jsString = [NSString stringWithFormat:@"Capptain.handleOpenURL(\"%@\");", url];
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
