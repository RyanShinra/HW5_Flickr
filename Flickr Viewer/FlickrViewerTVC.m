//
//  FlickrViewerTVCTableViewController.m
//  Flickr Viewer
//
//  Created by Ryan Osterday on 11/14/15.
//  Copyright © 2015 Ryan Osterday. All rights reserved.
//

#import "FlickrViewerTVC.h"
#import "FlickrFetcher.h"
#import "FlickrPhotos.h"
#import "ImageViewController.h"

@interface FlickrViewerTVC ()
- (void) fetchTopPhotos;
@property (nonatomic, strong) NSArray<NSDictionary*>* recentPhotos;
@end

@implementation FlickrViewerTVC

- (IBAction)  fetchTopPhotos
{
    //TODO: Add refresh control
//    
//    NSURL* urlForTopPlaces = [FlickrFetcher URLforTopPlaces];
//
//    NSData* topPlacesJson = [NSData dataWithContentsOfURL:urlForTopPlaces];
//    NSDictionary* topPlacesDict = [NSJSONSerialization JSONObjectWithData:topPlacesJson options:0 error:NULL];
//   // NSLog(@"%@", topPlacesDict);
    //
    
    
    dispatch_queue_t backgroundQ = dispatch_queue_create("Fetching Recent Photo Info Queue", NULL);
    [self.refreshControl beginRefreshing];
    dispatch_async (backgroundQ, ^{
        
        self.recentPhotos = [FlickrPhotos recentPhotosInfo];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
            //[self.view setNeedsDisplay];
        });
    });
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    [self fetchTopPhotos];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    if (self.recentPhotos) {
#warning I need to figure this out
        return 1;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    
    if (self.recentPhotos) {
        return self.recentPhotos.count;
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FlickrCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSString* photoTitle = [FlickrPhotos photoTitle: self.recentPhotos[indexPath.row]];
    cell.textLabel.text = photoTitle;
    NSString* photoDescription = [FlickrPhotos photoDescription:self.recentPhotos[indexPath.row]];
    cell.detailTextLabel.text = photoDescription;
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController* destVC = [segue destinationViewController];
    if ([destVC isKindOfClass:[ImageViewController class]]) {
        ImageViewController* destIVC = (ImageViewController*) destVC;

        if ([sender isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell* sourceCell = (UITableViewCell*) sender;
            
            //TODO: If this section gets unwieldy, we should move it to its own funciton
            {
                //We have to ask the table which row was tapped...
                NSInteger selectedRow = [[self.tableView indexPathForCell:sourceCell]row];
                
                //fetch the photo meta data out of the array
                NSDictionary* selectedPhoto = self.recentPhotos[selectedRow];
                
                //Get the URL for the photo in "Normal Size"
                NSURL* photoURL = [FlickrFetcher URLforPhoto:selectedPhoto
                                                      format:FlickrPhotoFormatLarge];
                
                //Inform the transitioning VC that it will be going to this address
                destIVC.imageLocation = photoURL;
                
            }
        }
    }
    
}


@end
