//
//  FlickrPhotos.m
//  Flickr Viewer
//
//  Created by Ryan Osterday on 11/15/15.
//  Copyright © 2015 Ryan Osterday. All rights reserved.
//

#import "FlickrPhotos.h"
#import "FlickrFetcher.h"
@interface FlickrPhotos()
@property (nonatomic) NSTimeInterval lastRecentPhotosQueryTime;
+ (NSURLSession*) defaultURLSession;

@end


@implementation FlickrPhotos

+ (NSURLSession*) defaultURLSession
{
    NSURLSessionConfiguration* downloadConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* downloadSession = [NSURLSession sessionWithConfiguration:downloadConfig];
    return downloadSession;
}

- (void) demoNSURLSession: (NSURL*) requestUrl
{
    NSURLSessionConfiguration* downloadConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLRequest* downloadRequest = [NSURLRequest requestWithURL:requestUrl];
    NSURLSession* downloadSession = [NSURLSession sessionWithConfiguration:downloadConfig];
    NSURLSessionDataTask* downloadTask = [downloadSession dataTaskWithRequest:downloadRequest];
    
    [downloadTask resume];
}


+ (NSArray<NSDictionary*>*) recentPhotosInfo
{
    //TODO: Turn this class into a non-static version so we can track the photos / encapsulate properly
//    NSDate* now = [NSDate date];
    NSURL* urlForRecentPhotos = [FlickrFetcher URLForQuery:[NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&license=1,2,4,7&extras=original_format,description,geo,date_upload,owner_name"]];
    
    NSLog(@"%@", urlForRecentPhotos);
    return [FlickrPhotos photosInfoAtURL:urlForRecentPhotos];
}

+ (NSArray< NSDictionary* >*) photosInfoAtURL: (NSURL*) readingURL
{
    NSData* recentPhotosJson = [NSData dataWithContentsOfURL:readingURL];
    
    NSDictionary* recentPhotosDict= [NSJSONSerialization JSONObjectWithData:recentPhotosJson options:0 error:NULL];
    //NSLog(@"%@", recentPhotosDict);
    //NSLog(@"%@", recentPhotosDict.allKeys);
    //NSLog(@"%@", recentPhotosDict.allValues);
    
    return recentPhotosDict[@"photos"][@"photo"];
}


+ (NSString*) photoTitle:(NSDictionary *)photo
{
    return photo[FLICKR_PHOTO_TITLE];
}

+ (NSString*) photoDescription:(NSDictionary *)photo
{
    id photoDescription = photo[FLICKR_PHOTO_DESCRIPTION];
    id photoOwnerName = photo[FLICKR_PHOTO_OWNER];
    if (photoDescription) {
        return photo[FLICKR_PHOTO_DESCRIPTION];
    }
    else if (photoOwnerName){
        return [NSString stringWithFormat:@"Owner: %@", photoOwnerName];
    }
    else{
        return @"No Description.";
    }

}

+ (NSArray<FlickrTopPlace*>*) topPlaces
{
    NSURL* urlForGeostuffs = [FlickrFetcher URLforTopPlaces];
    NSLog(@"%@", urlForGeostuffs);
    
    NSData* topPlacesData = [NSData dataWithContentsOfURL:urlForGeostuffs];
    
    NSDictionary* topPlacesDict = [NSJSONSerialization JSONObjectWithData:topPlacesData
                                                                  options:0
                                                                    error:NULL];
    
    NSArray* topPlacesArray = [topPlacesDict valueForKeyPath:FLICKR_RESULTS_PLACES];
    NSMutableSet<id>* placeIdList = [[NSMutableSet alloc] initWithCapacity: [topPlacesArray count]];

    NSMutableArray<FlickrTopPlace*>* topPlacesAnswer = [[NSMutableArray alloc]initWithCapacity:[topPlacesArray count]];
    
    
    for (NSDictionary* curPlaceInfo in topPlacesArray) {
        id curPlaceId = [curPlaceInfo valueForKeyPath:FLICKR_PLACE_ID];
        
        if (![placeIdList containsObject:curPlaceId]) {
            [placeIdList addObject:curPlaceId];
            
            //Split the _content entry to get the country, city and region
            NSString* placeDescription = [curPlaceInfo valueForKeyPath:FLICKR_PLACE_NAME];
            
            NSArray<NSString*>* placeNames = [placeDescription componentsSeparatedByString: @","];
            
//            
//            NSLog(@"Country:%@, Region:%@, City:%@",
//                  placeNames[2],
//                  placeNames[1],
//                  placeNames[0]);
            
            
            NSInteger x = [curPlaceInfo [@"photo_count"] integerValue];
            NSUInteger y = x < 0 ? 0 : (NSUInteger)x;
            
            NSString* countryName = [placeNames lastObject];
            NSMutableString* placeName = [[NSMutableString alloc]init];
            
            NSUInteger numPlaceNamesToMerge = placeNames.count - 1;
            
            for (size_t i = 0; i < numPlaceNamesToMerge; ++i) {
                [placeName appendString:placeNames[i]];
                //don't put a comma after the last item
                if (i < numPlaceNamesToMerge - 1) {
                    [placeName appendString:@","];
                }
            }
            NSString* regionName = [FlickrFetcher extractRegionNameFromPlaceInformation:curPlaceInfo];
            FlickrTopPlace* myTopPlace = [[FlickrTopPlace alloc]initWithId:curPlaceId
                                                                 PlaceName:placeName
                                                               CountryName:countryName
                                                                 NumPhotos:y
                                                                RegionName:regionName];
            [topPlacesAnswer addObject:myTopPlace];
        }
    }
    
    //Rediculously early return for debugging purposes
    return topPlacesAnswer;
    
#if 0
    
    dispatch_semaphore_t lastStand = dispatch_semaphore_create(0);
    
    for (id curPlaceId in placeIdList) {
        NSURL* urlForThisPlaceId = [FlickrFetcher URLforInformationAboutPlace:curPlaceId];
        
        [[[FlickrPhotos defaultURLSession] dataTaskWithURL:urlForThisPlaceId
                                        completionHandler:^(NSData * _Nullable curPlaceInfoData,
                                                            NSURLResponse * _Nullable response,
                                                            NSError * _Nullable error)
        {
            if(!error){
                NSDictionary* curPlaceInfo = [NSJSONSerialization JSONObjectWithData:curPlaceInfoData
                                                                             options:0 error:NULL];
                
                NSString* curPlaceName = [FlickrFetcher extractNameOfPlace:curPlaceId
                                                      fromPlaceInformation:curPlaceInfo];
                
                NSString* curPlaceRegionName = [FlickrFetcher extractRegionNameFromPlaceInformation:curPlaceInfo];
                NSLog(@"%@ : %@", curPlaceRegionName, curPlaceName);
            }
            dispatch_semaphore_signal(lastStand);
        }]resume];
    }
    
    //Now wait for all the things to finish
    //this relies on the completion handlers incrementing the semaphore
    //The timeout value is one second
    for (size_t i = 0; i < [placeIdList count]; ++i) {
        dispatch_semaphore_wait(lastStand,dispatch_time(DISPATCH_TIME_NOW, (1 * NSEC_PER_SEC))  );
        
    }
#endif
    
}



@end




