    //
//  FlickrPhotoHistoryTVC.swift
//  Flickr Viewer
//
//  Created by Ryan Osterday on 2/26/16.
//  Copyright © 2016 Ryan Osterday. All rights reserved.
//

import UIKit
import Foundation

class FlickrPhotoHistoryTVC: FlickrViewerTVC {

    var sortedHistory: Array<NSDictionary> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.beginRefreshing()
        readDefaultsForUser()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        viewDidLoad()
    }
    
    @IBAction func didRefreshControll(sender: UIRefreshControl, forEvent event: UIEvent)
    {
        sender.beginRefreshing()
        readDefaultsForUser()
        self.tableView.reloadData()
        sender.endRefreshing()
        
    }

    func readDefaultsForUser()
    {
        //We need to clear the array
        self.sortedHistory.removeAll(keepCapacity: true)
        
        //TODO: We will want to promote this to its own class soon
        let myDefaults = NSUserDefaults.standardUserDefaults()
        if let recentPhotos: Array<AnyObject> = myDefaults.arrayForKey("RecentPhotos"){
            for curPhotoInfo in recentPhotos{
                if let curPhotoInfoAsNSDictionary = curPhotoInfo as? NSDictionary{
                    let curPhotoKeys = curPhotoInfoAsNSDictionary.allKeys
                    let hasDateTimeKey = curPhotoKeys.contains({ (x:AnyObject) -> Bool in
                        if let xString = x as? String{
                            return xString == "accessDateTime"
                        }
                        return false
                    })//End closure and call for contains
                    
                    //If it has a key (and we're still inside the "if it's a dictionary" block)
                    if hasDateTimeKey{
                        self.sortedHistory.append(curPhotoInfoAsNSDictionary)
                    }
                }//end if if let typecast block to NSDictionary
            }//end for loop over all the recentPhotos
        }//end if let unwrap from arrayForKey call
        
        self.sortedHistory.sortInPlace { (left:NSDictionary, right:NSDictionary) -> Bool in
            if let leftDate = left["accessDateTime"] as? NSDate{
                if let rightDate = right["accessDateTime"] as? NSDate{
                    return leftDate.timeIntervalSinceNow > rightDate.timeIntervalSinceNow
                }
                return false
            }
            return false
        }//end sort in place
    }//End function
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sortedHistory.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PhotoHistoryCell", forIndexPath: indexPath)

            // Configure the cell...
        cell.textLabel?.text = self.sortedHistory[indexPath.row][FLICKR_PHOTO_TITLE] as? String
        if(cell.textLabel?.text == nil)
        {
            cell.textLabel?.text = "Untitled"
        }
        if let lastAccessDate:NSDate = self.sortedHistory[indexPath.row]["accessDateTime"] as? NSDate{
            let myDateFormatter : NSDateFormatter = NSDateFormatter.init()
            myDateFormatter.timeStyle = NSDateFormatterStyle.LongStyle
            myDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
            let lastAccessDateString = myDateFormatter.stringFromDate(lastAccessDate)
            
            cell.detailTextLabel?.text = "Last Accessed: " + lastAccessDateString
            
        }
        
        
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if let detailViewAsIVC = self.splitViewController?.viewControllers[1] as? ImageViewController{
            self.prepareImageViewController(detailViewAsIVC, toDisplayPhoto: self.sortedHistory[indexPath.row] as [NSObject : AnyObject])
        }
        self.viewDidLoad()
        self.tableView.reloadData()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    /// MARK: - Navigation
    //TODO: Consider Replacing this by inheriting from FlickrViewerTVC
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowPhotoForHistoryItem"{
            
            if let sendingCell = sender as? UITableViewCell{
                if let selectedIndex = self.tableView.indexPathForCell(sendingCell)?.row{
                    let selectedHistory: NSDictionary = self.sortedHistory[selectedIndex]
                    if let segueDestination: ImageViewController = segue.destinationViewController as? ImageViewController{
                        segueDestination.imageLocation = FlickrFetcher.URLforPhoto( selectedHistory as [NSObject : AnyObject], format: FlickrPhotoFormatLarge)
                    }
                }//end if let selectedIndex from indexpath.row
            }//end if let sendingCell is kind of class UITableViewCell
        }//end if segue is showPhotoHistoryItem
    }//end function prepareForSegue
    
    
    }
