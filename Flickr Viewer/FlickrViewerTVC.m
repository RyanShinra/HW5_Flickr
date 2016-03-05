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
#import <Foundation/Foundation.h>

@interface FlickrViewerTVC ()
- (void) fetchTopPhotos;

@property (nonatomic, strong) NSArray<NSDictionary*>* recentPhotos;
@end

@implementation FlickrViewerTVC

- (IBAction)  fetchTopPhotos
{
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
        
        if (self.presentationURL) {
            self.recentPhotos = [FlickrPhotos photosInfoAtURL:self.presentationURL];
        }
        else{
            self.recentPhotos = [FlickrPhotos recentPhotosInfo];
        }

        
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
        return 1;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.recentPhotos) {
        return self.recentPhotos.count;
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FlickrCell"
                                                            forIndexPath:indexPath];
    
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




#pragma mark - Table View Delegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self prepareImageViewController: self.splitViewController.viewControllers[1]
                      toDisplayPhoto: self.recentPhotos[indexPath.row]];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSString* segueName = [segue identifier];
    
    if ([segueName isEqualToString:@"transitionToImageViewController"]) {
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
                    [self prepareImageViewController:destIVC toDisplayPhoto:selectedPhoto];
                }
            }
        }
    }
}


- (void) prepareImageViewController: (ImageViewController*) destIVC toDisplayPhoto:(NSDictionary*) selectedPhoto
{
    
    //Get the recent photos Array
    NSUserDefaults* myDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray<NSDictionary*>* recentPhotos = [[NSMutableArray alloc] initWithArray: [myDefaults arrayForKey:@"RecentPhotos"]];
    
    //Search the recent photos array for the photo just selected
    __block bool found = NO;
    __block NSDictionary* matchingPhotoInfo = nil;
    [recentPhotos enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj[FLICKR_PHOTO_ID] == selectedPhoto[FLICKR_PHOTO_ID]){
            found = YES;
            *stop = YES;
            matchingPhotoInfo = obj;
        }
    }];
    
    
    //This will either be the item already in the history for this item
    // or a new one based on the selected photo
    NSMutableDictionary* newHistoryItem = nil;
    
    //This will be either the matching photo just found or the oldest one in the collection (or nil)
    __block NSDictionary* historyItemToRemove = nil;
    //Let's stash a date time into the dictionary so we can use it when we fish it out of the NSUserDefaults
    NSDate* nowNow = [NSDate dateWithTimeIntervalSinceNow:0];
    
    __block NSDate* oldestTime = nowNow;
    
    
    if (found) {
        //The thing that comes out of the defaults is immutable, so we have to make a copy (how C++ of us)
        newHistoryItem = [[NSMutableDictionary alloc]initWithDictionary:matchingPhotoInfo];
        historyItemToRemove = matchingPhotoInfo;
    }
    else{
        //This hasn't been stored before, so let's make a new one
        newHistoryItem = [NSMutableDictionary dictionaryWithDictionary: selectedPhoto];
        
        //OK, let's find the oldest one, if there are more than 30
        if ([recentPhotos count] >= 30) {
            //Loop over all the items comparing the time they were put into the array
            [recentPhotos enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDate* objDate = obj[@"accessDateTime"];
                //The dictionary may not actually have this field, so we must check
                if (objDate) {
                    //Perversely, we don't know if the type was modified since it was stored
                    if ([objDate isKindOfClass:[NSDate class]]) {
                        //Ok, we finally know that we have a NSDate to check
                        //Time intervals in the past should be negative, so older times are more negative
                        if ([objDate timeIntervalSinceNow] < [oldestTime timeIntervalSinceNow]) {
                            oldestTime = objDate;
                            historyItemToRemove = obj;
                        }//end if this is the oldest thing
                        
                    }//end if this is a date
                    else{
                        //This thing has been corrupted, it might as well be the thing we get rid of
                        historyItemToRemove = obj;
                        *stop = YES;
                    }//end else this is corrupted
                }//end if there is a date object
                else{
                    historyItemToRemove = obj;
                    *stop = YES;
                }//end else there isn't a date object we should remove it
            }];//end enumeration block
        }//end if there were 30+ photos
    }//end if this was found or not
    
    if (historyItemToRemove) {
        [recentPhotos removeObject:historyItemToRemove];
    }
    
    //new history item needs its timestamp
    //Technically, adding a new key/value pair to the dictionary will change it from the version
    // returned by Flickr, but since we don't have to sent it back to flickr and we're not modifying
    // any of those keys, we should be ok.
    newHistoryItem[@"accessDateTime"] = nowNow;
    
    //Finally, we can add a history item
    [recentPhotos addObject:newHistoryItem];
    
    //now put the array back into the defaults (actualy, we're replacing it)
    [myDefaults setObject:recentPhotos forKey:@"RecentPhotos"];
    
    //Actualy save the data
    [myDefaults synchronize];
    //Get the URL for the photo in "Normal Size"
    NSURL* photoURL = [FlickrFetcher URLforPhoto:selectedPhoto
                                          format:FlickrPhotoFormatLarge];
    
    //Inform the transitioning VC that it will be going to this address
    destIVC.imageLocation = photoURL;
    destIVC.imageViewerNavigation.title = [FlickrPhotos photoTitle:selectedPhoto];

}


@end
