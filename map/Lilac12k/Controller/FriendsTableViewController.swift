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
    var numFriendsBeingTracked = 0;
    var data : [String] = [] //["San Francisco","New York","San Jose","Chicago","Los Angeles","Austin","Seattle"]

    var filtered:[String] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    var searchActive : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.scrollEnabled = true
        self.tableView.bounces = true;
        self.view.bringSubviewToFront(tableView)
        
        //Count how many users are being tracked
        numFriendsBeingTracked = 0;
        for i in 0..<UserInformation.sharedInstance.isUserBeingTrackedArray.count
        {
            if(UserInformation.sharedInstance.isUserBeingTrackedArray[i])
            {
                numFriendsBeingTracked += 1;
            }
        }
        /*for i in 0..<UserInformation.sharedInstance.friendNames.count{
            data[i] = UserInformation.sharedInstance.friendNames[i]
        }*/
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
            //Currently no friends
            ToastView.showToastInParentView(self.view, withText: "Please check your network connection. \nUnable to retrieve friend information.", withDuration: 5.0)
        }
        return UserInformation.sharedInstance.countOfRunners;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:FriendsPageCell = (self.tableView.dequeueReusableCellWithIdentifier("FriendCell"))! as! FriendsPageCell
        cell.CellName.text = UserInformation.sharedInstance.friendNames[indexPath.row] as String
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        cell.CellImage.image = FacebookImages.sharedInstance.dictionaryOfProfilePictures[UserInformation.sharedInstance.userIDsArray[indexPath.row]]
        cell.TrackerSwitch.tag = indexPath.row;
        cell.TrackerSwitch.on = UserInformation.sharedInstance.isUserBeingTrackedArray[indexPath.row];
        cell.TrackerSwitch.addTarget(self, action: #selector(FriendsTableViewController.stateChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        return cell
    }
    
    //Disable tracker switches if over 5 runners selected
    func stateChanged(TrackerSwitch: UISwitch!)
    {
        numFriendsBeingTracked = 0;
        for i in 0..<UserInformation.sharedInstance.isUserBeingTrackedArray.count
        {
            if(UserInformation.sharedInstance.isUserBeingTrackedArray[i])
            {
                numFriendsBeingTracked += 1;
            }
        }
        if( numFriendsBeingTracked >= 5 && TrackerSwitch.on == true )
        {
            UserInformation.sharedInstance.isUserBeingTrackedArray[TrackerSwitch.tag] = false
            TrackerSwitch.on = false
            ToastView.showToastInParentView(self.view, withText: "Sorry, you can't track over 5 runners at once", withDuration: 1.0)
            print("Can't have more than 5 runners");
        }
        else{
            if (TrackerSwitch.on == true){
                numFriendsBeingTracked += 1;
                UserInformation.sharedInstance.isUserBeingTrackedArray[TrackerSwitch.tag] = true
                if(TrackerSwitch.tag == 0 ) {
                    //print(UserInformation.sharedInstance.name, "  ",UserInformation.sharedInstance.isUserBeingTrackedArray[TrackerSwitch.tag])
                } else {
                    //print(UserInformation.sharedInstance.friendNames[TrackerSwitch.tag-1], "  ",UserInformation.sharedInstance.isUserBeingTrackedArray[TrackerSwitch.tag])
                }
            } else {
                numFriendsBeingTracked -= 1;
                UserInformation.sharedInstance.isUserBeingTrackedArray[TrackerSwitch.tag] = false
                if (TrackerSwitch.tag == 0 ) {
                    //print(UserInformation.sharedInstance.name, "  ",UserInformation.sharedInstance.isUserBeingTrackedArray[TrackerSwitch.tag])
                } else {
                    //print(UserInformation.sharedInstance.friendNames[TrackerSwitch.tag-1], "  ",UserInformation.sharedInstance.isUserBeingTrackedArray[TrackerSwitch.tag])
                }
            }
            //On switch changes, notify user with ToastView (Frameworks/ToastView)
            if (TrackerSwitch.tag == 0) { //toggled yourself
                if (UserInformation.sharedInstance.isUserBeingTrackedArray[TrackerSwitch.tag]) {
                    let green = UIColor.init(red: 94/255, green: 128/255, blue: 83/255, alpha: 1)
                    ToastView.showToastInParentView(self.view, withText: "You are now in runner mode.", withDuration: 1.0, withColor: green)
                } else {
                    let blue = UIColor.init(red: 83/255, green: 116/255, blue: 128/255, alpha: 1)
                    ToastView.showToastInParentView(self.view, withText: "You are now in spectator mode.", withDuration: 1.0, withColor: blue)
                }
            } else { //toggled a friend
                var name = "yourself"
                if (TrackerSwitch.tag > 0) {
                    name = UserInformation.sharedInstance.friendNames[TrackerSwitch.tag ];
                }
                var action = "deselected"
                if (UserInformation.sharedInstance.isUserBeingTrackedArray[TrackerSwitch.tag]) {
                    action = "selected"
                }
                ToastView.showToastInParentView(self.view, withText: "You " + action + " " + name + ".", withDuration: 1.0)
            }
        }
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
    
    //search bar
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        filtered = data.filter({ (text) -> Bool in
            let tmp: NSString = text
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }

    
    
    
    
}