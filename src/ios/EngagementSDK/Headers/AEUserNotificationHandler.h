/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 */

#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This user notification handler is an implementation of the UNUserNotificationCenterDelegate protocol
 * for Engagement notifications.
 *
 * @see UNUserNotificationCenterDelegate
 */
@interface AEUserNotificationHandler : NSObject<UNUserNotificationCenterDelegate>

/**
 * Called when a notification is delivered to a foreground app.
 * This implementation forces system notifications from Engagement to NOT be presented
 * while the application is in foreground.
 * The completionHandler, if not nil, is called on Engagement notifications only.
 * @param center The notification center that received the notification.
 * @param notification The notification that is about to be delivered.
 * @param completionHandler The block to execute with the presentation option for the notification.
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(nullable void (^)(UNNotificationPresentationOptions options)) completionHandler;

/**
 * Called to let the application know which action was selected by the user for a given notification.
 * This implementation handles Engagement notifications being actioned by the user.
 * A notification is not actioned if it has been dismissed by the user.
 * The completionHandler, if not nil, is called on Engagement notifications only.
 * @param center The notification center that received the notification.
 * @param notification The user’s response to the notification.
 * @param completionHandler The block to execute when the user’s response is finished processing.
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(nullable void(^)()) completionHandler;

@end

NS_ASSUME_NONNULL_END

