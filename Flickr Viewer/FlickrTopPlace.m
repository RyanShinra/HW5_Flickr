//
//  FlickrTopPlaces.m
//  Flickr Viewer
//
//  Created by Ryan Osterday on 2/20/16.
//  Copyright © 2016 Ryan Osterday. All rights reserved.
//

#import "FlickrTopPlace.h"

@implementation FlickrTopPlace

- (instancetype) initWithId: (id) placeId
                  PlaceName: (NSString*) placeName
                CountryName: (NSString*) countryName
                  NumPhotos: (NSUInteger) numPhotos
                 RegionName:(NSString *)regionName
{
    //such weirdness....
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.placeName = placeName;
    self.countryName = countryName;
    self.numPhotos  = numPhotos;
    self.placeId = placeId;
    self.regionName = regionName;
    return self;
}


@end
