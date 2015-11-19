//
//  FlickrPhotos.h
//  Flickr Viewer
//
//  Created by Ryan Osterday on 11/15/15.
//  Copyright © 2015 Ryan Osterday. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrPhotos : NSObject


///This will block the calling thread, so make sure to put it on the background
+ (NSArray<NSDictionary*>*) recentPhotosInfo;
+ (NSString*) photoTitle: (NSDictionary*) photo;

@end
