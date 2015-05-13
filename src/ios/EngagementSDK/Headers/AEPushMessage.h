/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 */

#import <Foundation/Foundation.h>

/**
 * A `AEPushMessage` object represents a Engagement push message.
 *
 * Engagement push messages are passed through Engagement agent to modules and Engagement push delegate.
 *
 * **See also**
 *
 * - <[EngagementAgent setPushDelegate:]>
 * - <AEPushDelegate>
 * - <AEModule>
 */
@interface AEPushMessage : NSObject<NSCoding>

/** Message's identifier */
@property(nonatomic, copy) NSString* messageId;

/** Message's payload */
@property(nonatomic, copy) NSString* payload;

/** optional XMPP address to reply to (can be `nil`). */
@property(nonatomic, copy) NSString* replyTo;

/** YES if this message was retrieved from the cache, NO otherwise */
@property(nonatomic, assign) BOOL cached;

@end
