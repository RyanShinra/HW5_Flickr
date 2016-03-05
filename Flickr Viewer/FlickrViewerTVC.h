//
//  FlickrViewerTVCTableViewController.h
//  Flickr Viewer
//
//  Created by Ryan Osterday on 11/14/15.
//  Copyright © 2015 Ryan Osterday. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewController.h"

@interface FlickrViewerTVC : UITableViewController
@property (weak, nonatomic) IBOutlet UINavigationItem *controllerTitle;
- (void) prepareImageViewController: (ImageViewController*) destIVC toDisplayPhoto:(NSDictionary*) photoDictionary;
@property (strong, atomic) NSURL* presentationURL;
@end
