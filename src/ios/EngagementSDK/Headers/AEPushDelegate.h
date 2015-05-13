/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AEPushMessage;

/**
 * The `AEPushDelegate` protocol defines the messages sent to a delegate when a push message is received.
 *
 * This delegate can be given to the Engagement agent
 * if you want to be notified of push messages coming from the Engagement Push Service.
 *
 * **Related method**
 *
 * - <[EngagementAgent setPushDelegate:]>
 */
@protocol AEPushDelegate<NSObject>
@optional

/**
 * ----------------------------------------------------
 * @name Messages coming from the Engagement Push Service
 * ----------------------------------------------------
 */

/**
 * Sent when a push message is received by the Engagement Push Service.
 * @param message An object representing the Engagement message.
 */
- (void)didReceiveMessage:(AEPushMessage*)message;

/**
 * Sent when Engagement is about to retrieve the push message that launched the application (from an Apple push
 * notification).
 * It is a good opportunity to start displaying a message to the end user indicating that data is being loaded.
 */
- (void)willRetrieveLaunchMessage;

/**
 * Sent when Engagement failed to retrieve the push message that launched the application.
 * Use this opportunity to hide any loading message and to display a dialog to the end user
 * indicating that the message could not be fetched.
 */
- (void)didFailToRetrieveLaunchMessage;

/**
 * Sent when Engagement received the push message that launched the application.
 * Use this opportunity to to hide any loading message and display appropriate content to the end user.
 * @param launchMessage An object representing the Engagement message that launched the application.
 */
- (void)didReceiveLaunchMessage:(AEPushMessage*)launchMessage;

@end
