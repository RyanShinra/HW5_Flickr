//
//  ImageViewController.h
//  Flickr Viewer
//
//  Created by Ryan Osterday on 11/19/15.
//  Copyright © 2015 Ryan Osterday. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController <NSURLSessionDownloadDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) NSURL* imageLocation;
@property (weak, nonatomic) IBOutlet UINavigationItem *imageViewerNavigation;

@end
