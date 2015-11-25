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
@end
@implementation FlickrPhotos


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
    NSDate* now = [NSDate date];
    NSURL* urlForRecentPhotos = [FlickrFetcher URLForQuery:[NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&license=1,2,4,7&extras=original_format,description,geo,date_upload,owner_name"]];
    
    NSLog(@"%@", urlForRecentPhotos);
    NSData* recentPhotosJson = [NSData dataWithContentsOfURL:urlForRecentPhotos];
    
    
    
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
    
    if (photoDescription) {
        return photo[FLICKR_PHOTO_DESCRIPTION];
    }
    else{
        return @"No Description.";
    }

}
@end
