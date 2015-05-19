/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AEPushMessage;

/**
 * The `AEModule` protocol defines an interface for Engagement modules
 *
 * You can pass a module in the Engagement initialization method.
 *
 * **Related methods**
 *
 * - <[EngagementAgent init:modules:]>
 * - <[EngagementAgent getModule:]>
 */
@protocol AEModule<NSObject>

/**
 * Start module.
 * This method is called by the <EngagementAgent> when Engagement has been initialized.<br>
 * You can start using Engagement agent methods at this point.
 */
- (void)start;

/**
 * Stop module.
 * This method is called by the <EngagementAgent> when Engagement is going to be released.<br>
 * You should release uneeded resources in this method. You won't be able to call any methods from the <EngagementAgent>
 * after this point.
 */
- (void)stop;

/**
 * The unique name of the module
 */
- (NSString*)name;


@optional

/**
 * Called when one or several push messages are received by Engagement.
 * This does not include the push message if it has been received following application launch
 * (typically when the user clicks on the Apple Push notification of the notification center).
 * This message will be passed to the method <displayPushMessageNotification:> instead.
 *
 * @param msgs A list of <AEPushMessage> objects.
 * @see AEPushMessage
 */
- (void)pushMessagesReceived:(NSArray*)msgs;

/**
 * Called after the user clicks on an Apple notification handled by Engagement.
 * The module receive the Engagement push message associated to the Apple
 * notification in order to display it to the end-user.
 * @param msg The Engagement push message to display.
 * @result YES if given message has been processed and displayed, NO otherwise.
 * @see AEPushMessage
 */
- (BOOL)displayPushMessageNotification:(AEPushMessage*)msg;

/**
 * Called after the user clicks on an Apple notification that contains an action url.
 * The module receive the Engagement push message associated to the Apple
 * notification in order to display it to the end-user.
 * @param userInfo The notification object.
 * @result YES if given message has been processed and displayed, NO otherwise.
 * @see AEPushMessage
 */
- (BOOL)displayPushMessageNotificationWithActionUrl:(NSDictionary*)userInfo;

/**
 * Called when remote notification is received.
 * @param userInfo The notification object.
 * @result YES if given message has been processed and displayed, NO otherwise.
 */
- (BOOL)processRemoteNotification:(NSDictionary*)userInfo;

/**
 * Called when Engagement has detected that the current activity has changed.
 * @param activityName The name of the new activity.
 */
- (void)activityChanged:(NSString*)activityName;

/**
 * Called when an Apple push notification is received.
 * @param notification The notification payload.
 */
- (void)pushNotificationReceived:(NSDictionary*)notification;

/**
 * Called when the deviceid or the appid has changed.
 * You should use this method to clear the storage, for example.
 * Careful : The module is not started yet.
 */
- (void)configurationChanged;

@end
