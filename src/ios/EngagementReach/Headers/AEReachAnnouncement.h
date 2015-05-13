/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "AEReachAbstractAnnouncement.h"

/**
 * Announcement's type.
 */
typedef NS_ENUM (NSInteger, AEAnnouncementType)
{
  /** Unknwon announcement type */
  AEAnnouncementTypeUnknown = -1,

  /** Announcement with a text plain content */
  AEAnnouncementTypeText = 1,

  /** Announcement with an HTML content */
  AEAnnouncementTypeHtml = 2

};

/**
 * The `AEReachAnnouncement` class defines objects that represent generic Engagement announcements.
 *
 * You usually have to use this class when you implement your own
 * announcement view controller.<br> The Engagement Reach SDK will instantiate your view controller using
 * method <[AEAnnouncementViewController initWithAnnouncement:]>.
 */
@interface AEReachAnnouncement : AEReachAbstractAnnouncement {
  @private
  AEAnnouncementType _type;
}

/**
 * Parse an announcement
 * @param element Parsed XML root DOM element.
 * @param params special parameters to replace in the action URL and body of the announcement.
 * @result A new announcement or nil if it couldn't be parsed.
 */
+ (id)announcementWithElement:(AE_TBXMLElt*)element params:(NSDictionary*)params;

/**
 * Get the mime type for this announcement. This is useful to interpret the text returned by
 * #body.
 *
 * Possible values are:
 *
 * - `AEAnnouncementTypeUnknown`: Unknown announcement type
 * - `AEAnnouncementTypeText`: A text announcement (associated mimetype is text/plain)
 * - `AEAnnouncementTypeHtml`: An HTML announcement (associated mimetype is text/html)
 */
@property(readonly) AEAnnouncementType type;

@end
