/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "AE_TBXML.h"

/**
 * Abstract class for reach contents such as announcements and polls.
 */
@interface AEReachContent : NSObject
{
  @private
  NSUInteger _localId;
  NSString* _category;
  NSString* _body;
  BOOL _processed;
  BOOL _feedback;
  NSDate* _expiryDate;
  BOOL _expiryLocaltz;
}

/**
 * Parse a reach content from a given xml element
 * @param root Parsed XML root DOM element
 * @result The parsed reach content or nil if content couldn't be parsed.
 */
- (id)initWithElement:(AE_TBXMLElt*)root;

/** The unique reach content identifier setter method. */
@property (nonatomic, copy) NSString *contentId;

/** Local storage identifier */
@property(assign) NSUInteger localId;

/**
 * Category of this content. You usually don't need to read this value by yourself.
 * Instead, you should use the method <[AEReachModule registerAnnouncementController:forCategory:]>
 * or <[AEReachModule registerPollController:forCategory:]> to tell the reach module
 * which controller to display for a given category.
 */
@property (nonatomic, copy) NSString* category;

/** Reach content's body */
@property(nonatomic, copy) NSString* body;

/** Feedback required ? */
@property BOOL feedback;

/** Drop content. */
- (void)drop;

/** Report content has been actioned. */
- (void)actionContent;

/** Report content has been exited.  */
- (void)exitContent;

/** @result YES if content is expired and should be dropped, NO otherwise */
- (BOOL)isExpired;

/**
 * Utility method to decode base64 data.
 * @param str The string to decode.
 */
- (NSData*)decodeBase64:(NSString*)str;

/**
 * Send feedback to reach about this content.
 * @param status The feedback status.
 * @param extras Extra information like poll answers.
 */
- (void)sendFeedback:(NSString*)status extras:(NSDictionary*)extras;

/**
 * Send content reply to the service that sent it, after that new contents can be notified.
 * @param status The feedback status.
 * @param extras Extra information like poll answers.
 */
- (void)process:(NSString*)status extras:(NSDictionary*)extras;

@end
