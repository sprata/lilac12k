//
//  UserInformation.swift
//  test
//
//  Created by Sarah Prata on 1/26/16.
//  Copyright © 2016 codemysource. All rights reserved.
//

import Foundation


public class UserInformation {
    var completionHandler:((Float)->Void)!
    public static let sharedInstance = UserInformation()
    var name : NSString
    var token : NSString
    var friends : NSDictionary
    var friendNames : [String]
    var friendIDs : [String]
    var userIDsArray : [String] //Array of all userIDs. First one will be User, rest will be friends.
    var accesstoken : NSString
    var currentPersonTrackingByIndex : Int //0 is self
    var isUserBeingTrackedArray : [Bool]
    var isPinAdded : [Bool]
    var isRunnerTransmittingData : Bool
    var countOfRunners = 0;
    
    private init()
    {
        self.name = "test"
        self.token = "test"
        self.friends = [String: String]()
        self.friendNames = [String]()
        self.friendIDs = [String]()
        self.accesstoken = "test"
        self.currentPersonTrackingByIndex = 0 //0 is self
        self.isUserBeingTrackedArray = [Bool]()
        self.isPinAdded = [Bool]()
        self.userIDsArray = [String]()
        self.isRunnerTransmittingData = true
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me?fields=id,name,friends.limit(250)", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                
                self.name = result.valueForKey("name") as! NSString
                self.token = result.valueForKey("id") as! NSString
                self.accesstoken = FBSDKAccessToken.currentAccessToken().tokenString
                self.countOfRunners += 1; //the user is at least there
                self.friends = result.valueForKey("friends") as! NSDictionary
                self.isUserBeingTrackedArray.append(true)
                self.isPinAdded.append(false)
                self.userIDsArray.append(self.token as String)
                self.friendNames.append(self.name  as String)
                let data : NSArray = self.friends.objectForKey("data") as! NSArray
                for i in 0..<data.count {
                    let valueDict : NSDictionary = data[i] as! NSDictionary
                    let id = valueDict.objectForKey("id") as! String
                    let name = valueDict.objectForKey("name") as! String
                    self.friendNames.append(name)
                    self.friendIDs.append(id)
                    self.isUserBeingTrackedArray.append(false)
                    self.isPinAdded.append(false)
                    self.userIDsArray.append(id)
                    self.countOfRunners += 1; //each friend is a runner
                }
                
                let facebookID = self.token
                let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: "https://graph.facebook.com/\(facebookID)/picture?type=large&return_ssl_resources=1")!) { data, response, error in
                }
                task.resume()
                FacebookImages.sharedInstance
            }
        })
    }
    
    func refresh()
    {
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me?fields=id,name,friends.limit(250)", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                if(self.name.containsString("test"))
                {
                    //need to retrieve self information
                    self.name = result.valueForKey("name") as! NSString
                    self.token = result.valueForKey("id") as! NSString
                    self.accesstoken = FBSDKAccessToken.currentAccessToken().tokenString
                    //may want to +=, switched to = incase multiple refresh requests
                    self.countOfRunners = 1; //the user is at least there
                    self.friends = result.valueForKey("friends") as! NSDictionary
                    self.isUserBeingTrackedArray.append(true)
                    self.userIDsArray.append(self.token as String)
                    let data : NSArray = self.friends.objectForKey("data") as! NSArray
                    for i in 0...data.count-1 {
                        let valueDict : NSDictionary = data[i] as! NSDictionary
                        let id = valueDict.objectForKey("id") as! String
                        let name = valueDict.objectForKey("name") as! String
                        self.friendNames.append(name)
                        self.friendIDs.append(id)
                        self.isUserBeingTrackedArray.append(false)
                        self.userIDsArray.append(id)
                        self.countOfRunners += 1; //each friend is a runner
                    }
                    
                    let facebookID = self.token
                    let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: "https://graph.facebook.com/\(facebookID)/picture?type=large&return_ssl_resources=1")!) { data, response, error in
                    }
                    task.resume()
                    FacebookImages.sharedInstance
                    
                }
                else{
                    //see if there are any new friends
                    self.friends = result.valueForKey("friends") as! NSDictionary
                    let data : NSArray = self.friends.objectForKey("data") as! NSArray
                    print("Data Count:", data.count, "Friend Count:", self.countOfRunners-1)
                    if(data.count > self.countOfRunners-1) //add a case for less than
                    {
                        for i in (self.countOfRunners-1)...data.count-1 {//for i in 0...data.count-1 {
                            let valueDict : NSDictionary = data[i] as! NSDictionary
                            let id = valueDict.objectForKey("id") as! String
                            let name = valueDict.objectForKey("name") as! String
                            print(name, " : ", id)
                            self.friendNames.append(name)
                            self.friendIDs.append(id)
                            self.isUserBeingTrackedArray.append(false)
                            self.userIDsArray.append(id)
                            self.countOfRunners += 1; //each friend is a runner
                            FacebookImages.sharedInstance.addToFacebookImages(valueDict.objectForKey("id") as! String)
                        }
                    }
                    
                }
            }
        })
    }
    
    func checkWhoIsBeingTracked(personBeingTracked : Int) -> NSString{
        if(personBeingTracked == 0) {
            return name
        }else
        {
            return friendNames[personBeingTracked-1]
        }
        
    }
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    
}