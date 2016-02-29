//
//  FlickrGeoTableViewCell.h
//  Flickr Viewer
//
//  Created by Ryan Osterday on 2/23/16.
//  Copyright © 2016 Ryan Osterday. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrTopPlace.h"
@interface FlickrGeoTableViewCell : UITableViewCell
@property (strong, atomic) FlickrTopPlace* sourcePlace;
@end
