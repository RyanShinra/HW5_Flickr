//
//  FlickrTopPlaces.h
//  Flickr Viewer
//
//  Created by Ryan Osterday on 2/20/16.
//  Copyright © 2016 Ryan Osterday. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FlickrTopPlace : NSObject
@property NSString* placeName;
@property NSString* countryName;
@property NSUInteger numPhotos;
@property id placeId;
@property NSString* regionName;

- (instancetype) initWithId: (id) placeId
                  PlaceName: (NSString*) placeName
                CountryName: (NSString*) countryName
                  NumPhotos: (NSUInteger) numPhotos
                 RegionName: (NSString*) regionName;
@end

