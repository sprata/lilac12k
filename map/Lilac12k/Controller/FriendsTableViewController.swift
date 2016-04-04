//
//  FriendsTableViewController.swift
//  Lilac12k
//
//  Created by Sarah Prata on 2/1/16.
//  Copyright © 2016 codemysource. All rights reserved.
//

import Foundation
//@IBOutlet var tableView: UITableView!

class FriendsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var friendImages = [UIImage]()
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.scrollEnabled = true
        self.tableView.bounces = true;
        self.view.bringSubviewToFront(tableView)
        
        //refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(FriendsTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl)
        //end of refresh
        //later feature:
        //adjustSwitches()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(UserInformation.sharedInstance.countOfRunners == 0) //either no friends or network error
        {
            print("Currently no friends")
            ToastView.showToastInParentView(self.view, withText: "Please check your network connection. \nUnable to retrieve friend information.", withDuration: 10.0)
        }
        return UserInformation.sharedInstance.countOfRunners;//UserInformation.sharedInstance.friendNames.count+1;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:FriendsPageCell = (self.tableView.dequeueReusableCellWithIdentifier("FriendCell"))! as! FriendsPageCell
        if(indexPath.row == 0) {
            cell.CellName.text = UserInformation.sharedInstance.name as String
            cell.TrackerSwitch.tag = 0
            let imageView = UIImageView()
            imageView.contentMode = .ScaleAspectFit
            cell.CellImage.image = FacebookImages.sharedInstance.profilePic
            cell.TrackerSwitch.addTarget(self, action: #selector(FriendsTableViewController.stateChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
            cell.TrackerSwitch.on = true
            UserInformation.sharedInstance.isUserBeingTrackedArray[0] = true
        } else {
            cell.CellName.text = UserInformation.sharedInstance.friendNames[indexPath.row-1] as String
            let imageView = UIImageView()
            imageView.contentMode = .ScaleAspectFit
            cell.CellImage.image = FacebookImages.sharedInstance.dictionaryOfProfilePictures[UserInformation.sharedInstance.userIDsArray[indexPath.row]]
            cell.TrackerSwitch.tag = indexPath.row
            cell.TrackerSwitch.addTarget(self, action: #selector(FriendsTableViewController.stateChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
            
        }
        return cell
    }
    
    //Disable tracker switches if over 5 runners selected
    //TODO: Test that this works for 5 friends
    //TODO: Verify the loop works even for non-visible cells (i.e. screen overflow)
    func adjustSwitches() {
        var count = 0;
        //count number selected
        for row in 0..<self.tableView.numberOfRowsInSection(0) {
            let indexPath = NSIndexPath(forRow: row, inSection: 0)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! FriendsPageCell
            if (cell.TrackerSwitch.on) {
                count += 1;
            }
        }
        
        //if tracking 5, disable the currently-off switches
        for row in 0..<self.tableView.numberOfRowsInSection(0) {
            let indexPath = NSIndexPath(forRow: row, inSection: 0)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! FriendsPageCell
            if (count >= 5) {
                if (!cell.TrackerSwitch.on) {
                    cell.TrackerSwitch.enabled = false
                }
            } else {
                cell.TrackerSwitch.enabled = true;
            }
        }
    }
    
    func stateChanged(TrackerSwitch: UISwitch!)
    {
        //print("Switch Changed")
        if (TrackerSwitch.on == true){
            ///Not best implementation, but simple
            UserInformation.sharedInstance.isUserBeingTrackedArray[TrackerSwitch.tag] = true
            if(TrackerSwitch.tag == 0 ) {
                print(UserInformation.sharedInstance.name, "  ",UserInformation.sharedInstance.isUserBeingTrackedArray[TrackerSwitch.tag])
            } else {
                print(UserInformation.sharedInstance.friendNames[TrackerSwitch.tag-1], "  ",UserInformation.sharedInstance.isUserBeingTrackedArray[TrackerSwitch.tag])
            }
        } else {
            UserInformation.sharedInstance.isUserBeingTrackedArray[TrackerSwitch.tag] = false
            if (TrackerSwitch.tag == 0 ) {
                print(UserInformation.sharedInstance.name, "  ",UserInformation.sharedInstance.isUserBeingTrackedArray[TrackerSwitch.tag])
            } else {
                print(UserInformation.sharedInstance.friendNames[TrackerSwitch.tag-1], "  ",UserInformation.sharedInstance.isUserBeingTrackedArray[TrackerSwitch.tag])
            }
        }
        //On switch changes, notify user with ToastView (Frameworks/ToastView)
        var name = "yourself"
        if (TrackerSwitch.tag > 0) {
            name = UserInformation.sharedInstance.friendNames[TrackerSwitch.tag - 1];
        }
        var action = "deselected"
        if (UserInformation.sharedInstance.isUserBeingTrackedArray[TrackerSwitch.tag]) {
            action = "selected"
        }
        ToastView.showToastInParentView(self.view, withText: "You " + action + " " + name + ".", withDuration: 1.0)
        //Don't track >5 friends -> later feature
        ///adjustSwitches()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! FriendsPageCell
        if (cell.TrackerSwitch.enabled == false) {
            ToastView.showToastInParentView(self.view, withText: "Sorry, you can't track over 5 runners at once", withDuration: 1.0)
        }
    }
    
    
    
    func refresh(sender:AnyObject)
    {
        UserInformation.sharedInstance.refresh()
        // Updating data here...
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
        self.refreshControl?.endRefreshing()
    }
    
    
}