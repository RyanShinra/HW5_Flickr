//
//  FlickrTopPlaces.m
//  Flickr Viewer
//
//  Created by Ryan Osterday on 2/16/16.
//  Copyright © 2016 Ryan Osterday. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrPhotos.h"


@implementation FlickrTopPlace


- (instancetype) initWithId: (id) placeId
                  PlaceName: (NSString*) placeName
                CountryName: (NSString*) countryName
                  NumPhotos: (NSUInteger) numPhotos
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
    
    return self;
}


@end