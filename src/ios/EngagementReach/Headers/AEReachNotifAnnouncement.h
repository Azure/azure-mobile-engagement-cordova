/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "AEReachAbstractAnnouncement.h"

/**
 * The `AEReachNotifAnnouncement` class defines objects that represent a Engagement _notification only_ announcement.
 *
 * This is a special announcement used when you just want to display the notification (application banner or apple
 * push).
 * When the user clicks on the notification, the action url is launched, and the announcement is acknownledged.
 */
@interface AEReachNotifAnnouncement : AEReachAbstractAnnouncement

/**
 * Parse a notif announcement
 * @param element Parsed XML root DOM element.
 * @param params special parameters to replace in the action URL.
 * @result A new notif announcement or nil if it couldn't be parsed.
 */
+ (id)notifAnnouncementWithElement:(AE_TBXMLElt*)element params:(NSDictionary*)params;


@end
