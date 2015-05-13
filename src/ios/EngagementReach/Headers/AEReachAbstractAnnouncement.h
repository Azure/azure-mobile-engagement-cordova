/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "AEInteractiveContent.h"

/**
 * The `AEReachAbstractAnnouncement` is a base class for all kind of announcements.
 */
@interface AEReachAbstractAnnouncement : AEInteractiveContent
{
  @private
  NSString* _actionURL;
}

/**
 * Initialize an abstract announcement. Should only be called by subclasses.
 * @param element Parsed XML root DOM element.
 * @param params special parameters to replace in the action URL.
 * @result An initialized abstract announcement or nil if it couldn't be parsed.
 */
- (id)initWithElement:(AE_TBXMLElt*)element params:(NSDictionary*)params;

/** URL to launch as an action */
@property (nonatomic, retain) NSString* actionURL;

@end
