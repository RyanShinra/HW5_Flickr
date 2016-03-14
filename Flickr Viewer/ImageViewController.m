//
//  ImageViewController.m
//  Flickr Viewer
//
//  Created by Ryan Osterday on 11/19/15.
//  Copyright © 2015 Ryan Osterday. All rights reserved.
//

#import "ImageViewController.h"


@interface ImageViewController () <UISplitViewControllerDelegate>
- (void) downloadImage;

@property (strong, nonatomic) UIImageView* imageView;
@property (strong, nonatomic) UIImage* image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic) CGFloat minimumZoom;
@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.progressView.progress = 0;
    
    //NOTE: ATTENTION: This is very important; the image won't shop up without it.
    [self.scrollView addSubview:self.imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) URLSession:(NSURLSession *)session
       downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)fileLocation
{
    NSLog(@"Finished Downloading");
    
    if([[downloadTask originalRequest].URL isEqual: self.imageLocation]){
        UIImage* dlImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:fileLocation]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressView setHidden:YES];
            self.image = dlImage;
        });
    }
    [session finishTasksAndInvalidate];
}

- (void) URLSession:(NSURLSession *)session
       downloadTask:(NSURLSessionDownloadTask *)downloadTask
       didWriteData:(int64_t)bytesWritten
  totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"Data Rcv: %lld / %lld", totalBytesWritten, totalBytesExpectedToWrite);
    float written = (float)totalBytesWritten;
    float total = totalBytesExpectedToWrite;
    float progress = written / total;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setProgress:progress animated:YES];
    });

}

- (void) downloadImage
{
    //This session will only be used once.
    NSURLSessionConfiguration* dlConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    
    //Create the download session that will be used, assigning ourselves
    // (the imageViewController) as the delegate to handle the tasks when the download completes
    // (i.e. we implement those methods above that are inherited from the protocol)
    //Passing nil to the delegateQueue tells it to make its own serial process queue
    //We will probably want to promote this to a member instance property
    NSURLSession* dlSession = [NSURLSession sessionWithConfiguration:dlConfig
                                                            delegate:self
                                                       delegateQueue:nil];
    
    
    //Create the request to go to the image URL, but use cached data if it is already loaded
    NSURLRequest* dlRequest = [[NSURLRequest alloc]initWithURL:self.imageLocation
                                                   cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                               timeoutInterval:1.5];
    

    //Ask the session to create a download task for the download request (i.e. download from our URL)
    NSURLSessionDownloadTask* dlTask = [dlSession downloadTaskWithRequest:dlRequest];
    
    //Go Get them
    [dlTask resume];
    
}


#pragma mark Property Synthesis
- (void) setImageLocation:(NSURL *)imageLocation
{
    if (![imageLocation isEqual:_imageLocation]) {
        _imageLocation = imageLocation;
        [self downloadImage];
    }

}

- (UIImageView*) imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
    }
    return _imageView;
}

- (UIImage*) image
{
    return self.imageView.image;
}

- (void) setImage: (UIImage*) newImage
{
    self.imageView.image = newImage;
    
    //Reset the min/max zoom levels to allow for our zooming in a few lines
    self.scrollView.minimumZoomScale = 0.2; //Magic number, we should make these constants.
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.zoomScale = 1.0;
    self.imageView.frame = CGRectMake(0, 0, newImage.size.width, newImage.size.height);

    // self.scrollView could be nil on the next line if outlet-setting has not happened yet
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;

    CGRect newBounds = CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height);
    [self.scrollView zoomToRect:newBounds animated:NO];
    self.minimumZoom = self.scrollView.zoomScale;
    self.scrollView.minimumZoomScale = self.minimumZoom;
}

- (void) setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;

    if (self.image) {
        _scrollView.contentSize = self.image.size;
    }
    else{
        _scrollView.contentSize = CGSizeZero;
    }
}

#pragma mark - UIScrollViewDelegate

// mandatory zooming method in UIScrollViewDelegate protocol

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)viewDidLayoutSubviews
{
    //[self.scrollView zoomToRect:self.imageView.frame animated:YES];
//    self.minimumZoom = self.scrollView.zoomScale;
    //self.scrollView.minimumZoomScale = self.minimumZoom;
}

#pragma mark - UISplitViewDelegate
- (void) awakeFromNib
{
    self.splitViewController.delegate = self;
}


- (BOOL) splitViewController:(UISplitViewController *)svc
    shouldHideViewController:(UIViewController *)vc
               inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void) splitViewController:(UISplitViewController *)svc
      willHideViewController:(UIViewController *)aViewController
           withBarButtonItem:(UIBarButtonItem *)barButtonItem
        forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = aViewController.title;
    //barButtonItem.title = @"back";
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void) splitViewController:(UISplitViewController *)svc
      willShowViewController:(UIViewController *)aViewController
   invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}


@end
