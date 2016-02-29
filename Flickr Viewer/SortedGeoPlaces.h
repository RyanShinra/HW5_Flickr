//
//  SortedGeoPlaces.h
//  Flickr Viewer
//
//  Created by Ryan Osterday on 2/20/16.
//  Copyright © 2016 Ryan Osterday. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrTopPlace.h"

@interface SortedGeoPlaces : NSObject

- (instancetype) initWithTopPlacesArray: (NSArray<FlickrTopPlace*>*) source;
- (NSString*) countryNameAtIndex: (NSUInteger) index;

- (NSString*) placeNameAtCountryIndex: (NSUInteger) countryIndex
                         atPlaceIndex: (NSUInteger) placeIndex;

- (FlickrTopPlace*) topPlaceAtCountryIndex: (NSUInteger) countryIndex
                              atPlaceIndex: (NSUInteger) placeIndex;

- (NSUInteger) numberOfCountries;

- (NSUInteger) numberOfPlacesInCountryIndex: (NSUInteger) countryIndex;
@end