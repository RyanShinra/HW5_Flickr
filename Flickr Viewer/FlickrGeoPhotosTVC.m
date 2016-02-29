//
//  FlickrGeoPhotosTVC.m
//  Flickr Viewer
//
//  Created by Ryan Osterday on 1/10/16.
//  Copyright © 2016 Ryan Osterday. All rights reserved.
//

#import "FlickrGeoPhotosTVC.h"
#import "SortedGeoPlaces.h"
#import "FlickrFetcher.h"
#import "FlickrPhotos.h"
#import "ImageViewController.h"
#import "FlickrViewerTVC.h"

@interface FlickrGeoPhotosTVC ()
@property SortedGeoPlaces* geoPlaces;
@end

@implementation FlickrGeoPhotosTVC


- (IBAction)fetchGeoSortedPhotos:(id)sender
{
    //Do the fetching on a background Queue
    dispatch_queue_t backgroundQ = dispatch_queue_create("Geo Sorted Flickr Fetching", NULL);
    
    //Start the refresh indicator
    [self.refreshControl beginRefreshing];
    
    dispatch_async(backgroundQ, ^{
        NSArray<FlickrTopPlace*>* topPlacesArray = [FlickrPhotos topPlaces];
        self.geoPlaces = [[SortedGeoPlaces alloc] initWithTopPlacesArray:topPlacesArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
        });
    });
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self fetchGeoSortedPhotos:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.geoPlaces) {
        return self.geoPlaces.numberOfCountries;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.geoPlaces) {
        if (section >= 0) {
            return[self.geoPlaces numberOfPlacesInCountryIndex:section];
        }
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FlickrGeoCell" forIndexPath:indexPath];
    FlickrTopPlace* topPlaceForCell = [self.geoPlaces topPlaceAtCountryIndex:indexPath.section atPlaceIndex:indexPath.row];
    // Configure the cell...
    cell.textLabel.text = topPlaceForCell.placeName;
    

    //TOOD: This is obviously only for English (This whole thing is only for English)
    if (topPlaceForCell.numPhotos == 1) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld Photo", topPlaceForCell.numPhotos];
    }
    else {
    //This is kinda odd syntax... but it works.
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld Photos", topPlaceForCell.numPhotos];
    }
    
    if([cell isKindOfClass:[FlickrGeoTableViewCell class]]){
        ((FlickrGeoTableViewCell*)cell).sourcePlace = topPlaceForCell;
    }
    return cell;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.geoPlaces) {
        return [self.geoPlaces countryNameAtIndex:section];
    }
    return nil;
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
    
    id destinationVC = [segue destinationViewController];
    NSString* segueName = [segue identifier];
    
    if ([segueName isEqualToString:@"loadPhotosForLocation"]) {
        if ([destinationVC isKindOfClass: [FlickrViewerTVC class]]) {
            FlickrViewerTVC* postCast =  (FlickrViewerTVC*) destinationVC;
            if ([sender isKindOfClass:[FlickrGeoTableViewCell class]]) {
                FlickrGeoTableViewCell* selectedCell = (FlickrGeoTableViewCell*)sender;

                postCast.presentationURL = [FlickrFetcher URLforPhotosInPlace: selectedCell.sourcePlace.placeId
                                                                  maxResults: selectedCell.sourcePlace.numPhotos];
                postCast.controllerTitle.title = selectedCell.textLabel.text;
                  //maxResults: 50];
            }

        }
    }
}


@end
