//
//  SortedGeoPlaces.m
//  Flickr Viewer
//
//  Created by Ryan Osterday on 2/20/16.
//  Copyright © 2016 Ryan Osterday. All rights reserved.
//

#import "SortedGeoPlaces.h"

@interface SortedGeoPlaces ()

@property (nonatomic)  NSArray< NSArray< FlickrTopPlace* >* >* placesData;

+ (NSArray<NSString*>*) getSortedCountryNames : (NSArray<FlickrTopPlace*>*) source;
+ (NSArray<FlickrTopPlace*>*) getPlacesForCountry: (NSString*) countryName
                                  FromSourceArray: (NSArray<FlickrTopPlace*>*) source;

+ (NSArray< NSArray< FlickrTopPlace* >* >*) buildPlacesDataFromSource:(NSArray<FlickrTopPlace*>*) source;
- (NSArray< FlickrTopPlace* >*) placesArrayAtCountryIndex: (NSUInteger) index;

@end


@implementation SortedGeoPlaces

- (instancetype) initWithTopPlacesArray: (NSArray<FlickrTopPlace*>*) source
{
    self = [super init];
    if (!self){return self;}
    
    self.placesData = [SortedGeoPlaces buildPlacesDataFromSource:source];
    return self;
}

- (NSArray< FlickrTopPlace* >*) placesArrayAtCountryIndex: (NSUInteger) index
{
    if (self.placesData.count > index) {
        return self.placesData[index];
    }
    return nil;
}

- (NSString*) countryNameAtIndex: (NSUInteger) index
{
    FlickrTopPlace* thePlaceWithTheName = [self topPlaceAtCountryIndex:index atPlaceIndex:0];
    if (thePlaceWithTheName) {
        return thePlaceWithTheName.countryName;
    }
    return nil;
}

- (NSString*) placeNameAtCountryIndex: (NSUInteger) countryIndex
                         atPlaceIndex: (NSUInteger) placeIndex
{
    FlickrTopPlace* thePlaceWithTheName = [self topPlaceAtCountryIndex:countryIndex atPlaceIndex:placeIndex];
    if (thePlaceWithTheName) {
        NSLog(@"%@ %@", thePlaceWithTheName.countryName, thePlaceWithTheName.placeName);
        return thePlaceWithTheName.placeName;
    }
    return nil;
}

- (FlickrTopPlace*) topPlaceAtCountryIndex: (NSUInteger) countryIndex
                              atPlaceIndex: (NSUInteger) placeIndex
{
    NSArray< FlickrTopPlace* >* thePlaceArray = [self placesArrayAtCountryIndex:countryIndex];
    if (thePlaceArray) {
        if (thePlaceArray.count > placeIndex) {
            return thePlaceArray[placeIndex];
        }
    }
    return nil;
}

- (NSArray< NSArray< FlickrTopPlace* >* >*) placesData
{
    if(!_placesData){
        _placesData = [[NSArray alloc] init];
    }
    return _placesData;
}

+ (NSArray<NSString*>*) getSortedCountryNames : (NSArray<FlickrTopPlace*>*) source
{
    NSMutableSet<NSString*> *countryNames = [[NSMutableSet alloc] init];
    
    for (FlickrTopPlace* curPlace in source) {
        [countryNames addObject: curPlace.countryName];
    }
    
    NSArray<NSString*>* unsortedCountryNames = [[NSArray alloc]initWithArray: [countryNames allObjects]];
    
    NSArray<NSString*>* sortedCountryNames = [unsortedCountryNames sortedArrayUsingComparator:^NSComparisonResult(NSString*  _Nonnull obj1, NSString*  _Nonnull obj2) {
        return  [obj1 compare:obj2];
    }];
    return sortedCountryNames;
}


+ (NSArray<FlickrTopPlace*>*) getPlacesForCountry: (NSString*) countryName
                                  FromSourceArray: (NSArray<FlickrTopPlace*>*) source
{
    NSMutableArray<FlickrTopPlace*>* placesForCountry = [[NSMutableArray alloc] init];
   
    for (FlickrTopPlace* curPlace in source) {
        if ([curPlace.countryName isEqualToString:countryName]) {
            [placesForCountry addObject:curPlace];
        }
    }
    
    return placesForCountry;
}

+ (NSArray< NSArray< FlickrTopPlace* >* >*) buildPlacesDataFromSource:(NSArray<FlickrTopPlace*>*) source
{
    NSArray<NSString*>* sortedCountryNames = [SortedGeoPlaces getSortedCountryNames:source];
    NSMutableArray< NSArray< FlickrTopPlace* >* >* placesData = [[NSMutableArray alloc]init];
    
    for (NSString* curCountryName in sortedCountryNames) {
        [placesData addObject: [SortedGeoPlaces getPlacesForCountry:curCountryName FromSourceArray:source]];
    }
    return placesData;
}

- (NSUInteger) numberOfCountries
{
    return self.placesData.count;
}

- (NSUInteger) numberOfPlacesInCountryIndex: (NSUInteger) countryIndex
{
    if (self.placesData.count > countryIndex) {
        return self.placesData[countryIndex].count;
    }
    return 0;
}
@end
