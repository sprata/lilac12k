//
//  NewRunViewController.swift
//  Lilac12k
//

import UIKit
import CoreData
import CoreLocation
import HealthKit
import MapKit


class IBNewRunViewController: UIViewController {
    @IBOutlet var transmitButton: UIButton!
    @IBOutlet var centerButton: UIButton!
    var isTransmitOn:Bool = true
    var isCenterOn:Bool = true
    
    var managedObjectContext : NSManagedObjectContext?
    var run:Run!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    var startOnFlag: Bool = false
    @IBOutlet weak var mapView: MKMapView!
    
    //t
    var Annotation: AttractionAnnotation!
    var updateTimer = 0
    var boundary: [CLLocationCoordinate2D] = []
    var boundaryPointsCount: NSInteger = 0
    var midCoordinate: CLLocationCoordinate2D!
    var overlayTopLeftCoordinate: CLLocationCoordinate2D!
    var overlayTopRightCoordinate: CLLocationCoordinate2D!
    var overlayBottomLeftCoordinate: CLLocationCoordinate2D!
    var overlayBottomRightCoordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(overlayBottomLeftCoordinate.latitude,
                overlayTopRightCoordinate.longitude)
        }
    }
    
    var overlayBoundingMapRect: MKMapRect {
        get {
            let topLeft = MKMapPointForCoordinate(overlayTopLeftCoordinate)
            let topRight = MKMapPointForCoordinate(overlayTopRightCoordinate)
            let bottomLeft = MKMapPointForCoordinate(overlayBottomLeftCoordinate)
            
            return MKMapRectMake(topLeft.x,
                topLeft.y,
                fabs(topLeft.x-topRight.x),
                fabs(topLeft.y - bottomLeft.y))
        }
    }
    
    var name: String?
    // t
    
    var level1: MKOverlayLevel!
    @IBOutlet var recordRun: UIButton!
    
    var seconds = 0.0
    var distance = 0.0
    var flagStartLocation = true
    var notStartLocation = false
    var smallestYbound = 190.0
    var smallestXbound = 190.0
    var largestYbound = -190.0
    var largestXbound = -190.0
    var centerBound = CLLocationCoordinate2D()
    
    var runners = 0;
    var currentRunner = 1;
    var runnerDictionary = [String: Int]()
    struct runnerCoordinates {
        var runnerID : String
        //var coords : Array<CLLocationCoordinate2D> = []
        var lastCoordinate : CLLocationCoordinate2D
    }
    var arrayOfRunnerCoordinates = [String: runnerCoordinates]()
    var dictionaryOfLastAnnotations = [String: AttractionAnnotation]()
    var runnerImageLoaded = false
    var friendsRunning = 0
    lazy var locationManager : CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .Fitness
        _locationManager.requestAlwaysAuthorization()
        //Movement threshold for new events
        _locationManager.distanceFilter = 10.0
        
        return _locationManager
    }()
    
    lazy var locations = [CLLocation]()
    lazy var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDel.managedObjectContext
        transmitButton.addTarget(self, action: #selector(IBNewRunViewController.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        centerButton.addTarget(self, action: #selector(IBNewRunViewController.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        initUI()
        
        //t
        let filename = "MagicMountain"
        let filePath = NSBundle.mainBundle().pathForResource(filename, ofType: "plist")
        let properties = NSDictionary(contentsOfFile: filePath!)
        
        let midPoint = CGPointFromString(properties!["midCoord"] as! String)
        midCoordinate = CLLocationCoordinate2DMake(CLLocationDegrees(midPoint.x), CLLocationDegrees(midPoint.y - 0.015))
        
        let overlayTopLeftPoint = CGPointFromString(properties!["overlayTopLeftCoord"] as! String)
        overlayTopLeftCoordinate = CLLocationCoordinate2DMake(CLLocationDegrees(overlayTopLeftPoint.x),
            CLLocationDegrees(overlayTopLeftPoint.y))
        
        let overlayTopRightPoint = CGPointFromString(properties!["overlayTopRightCoord"] as! String)
        overlayTopRightCoordinate = CLLocationCoordinate2DMake(CLLocationDegrees(overlayTopRightPoint.x),
            CLLocationDegrees(overlayTopRightPoint.y))
        
        let overlayBottomLeftPoint = CGPointFromString(properties!["overlayBottomLeftCoord"] as! String)
        overlayBottomLeftCoordinate = CLLocationCoordinate2DMake(CLLocationDegrees(overlayBottomLeftPoint.x),
            CLLocationDegrees(overlayBottomLeftPoint.y))
        
        let boundaryPoints = properties!["boundary"] as! NSArray
        boundaryPointsCount = boundaryPoints.count
        boundary = []
        
        for i in 0...boundaryPointsCount-1 {
            let p = CGPointFromString(boundaryPoints[i] as! String)
            boundary += [CLLocationCoordinate2DMake(CLLocationDegrees(p.x), CLLocationDegrees(p.y))]
        }
        
        let latDelta = overlayTopLeftCoordinate.latitude -
            overlayBottomRightCoordinate.latitude
        
        // think of a span as a tv size, measure from one corner to another
        let span = MKCoordinateSpanMake(fabs(latDelta), 0.075)
        let region = MKCoordinateRegionMake(midCoordinate, span)
        
        mapView.region = region
        addOverlay()
        addAttractionPins()
        
        
        //self.userPin(userCoords.last!, name: UserInformation.sharedInstance.name as String, indexNumber: String(UserInformation.sharedInstance.token))
        
        //t
    }
    
    //t
    //    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        //if (annotation is MKUserLocation) {
        //    return nil
        //}
        //else {
        let annotationView = AttractionAnnotationView(annotation: annotation, reuseIdentifier: "Attraction")
        annotationView.canShowCallout = true
        return annotationView
        //}
    }
    //t
    
    //t
    func addAttractionPins() {
        let filePath = NSBundle.mainBundle().pathForResource("MagicMountainAttractions", ofType: "plist")
        let attractions = NSArray(contentsOfFile: filePath!)
        for attraction in attractions! {
            let point = CGPointFromString(attraction["location"] as! String)
            let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(point.x), CLLocationDegrees(point.y))
            let title = attraction["name"] as! String
            let typeRawValue: Int? = Int(attraction["type"] as! String)
            let type = AttractionType(rawValue: typeRawValue!)!
            let subtitle = attraction["subtitle"] as! String
            let annotation = AttractionAnnotation(coordinate: coordinate, title: title, subtitle: subtitle, type: type)
            mapView.addAnnotation(annotation)
        }
    }
    //t
    
    //t
    func addOverlay() {
        let overlay = RunMapOverlay(track: self)
        mapView.addOverlay(overlay)
    }
    //t
    
    func initUI()
    {
        timeLabel.font = UIFont(name: timeLabel.font.fontName, size: 14)
        distanceLabel.font = UIFont(name: distanceLabel.font.fontName, size: 14)
        paceLabel.font = UIFont(name: paceLabel.font.fontName, size: 14)
        timeLabel.text = "00:00:00"
        distanceLabel.text = "--"
        paceLabel.text = "--"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // runnerDictionary must be reinitialized each time the view appears (in case of changes to UserInformation)
        for i in  0..<UserInformation.sharedInstance.userIDsArray.count {
            runnerDictionary[UserInformation.sharedInstance.userIDsArray[i]] = Int(i);
        }
        locationManager.requestAlwaysAuthorization()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //timer.invalidate()
    }
    
    //sprata: maybe put in core data then call here?
    func userPin(coordinates: CLLocationCoordinate2D, name: String, indexNumber: String) {
        let newCoordinate = CLLocationCoordinate2DMake(coordinates.latitude, coordinates.longitude);
        /*
        for annotation in mapView.annotations {
            if annotation.isKindOfClass(AttractionAnnotation) && (annotation as! AttractionAnnotation).type == AttractionType(rawValue: 4)
            {
                (annotation as! AttractionAnnotation).coordinate = newCoordinate
            }
        }
        */
        print("*******************")
        print(name)
        for i in dictionaryOfLastAnnotations {
            print("PPPPPPPPPPPPPP")
            print(i.0)
            if(i.0 == name) {
                i.1.coordinate = newCoordinate
            }
        }
        
    }
    
    func addUserPin(coordinates: CLLocationCoordinate2D, name: String, indexNumber: String) {
        if(dictionaryOfLastAnnotations[name] != nil)
        {
            self.mapView.removeAnnotation(dictionaryOfLastAnnotations[name]!)
        }
        var runnerColor = 0
        if currentRunner%5 == 0 {
            runnerColor = 0
        }else if currentRunner%5 == 1 {
            runnerColor = 1
        }else if currentRunner%5 == 2 {
            runnerColor = 2
        }else if currentRunner%5 == 3 {
            runnerColor = 3
        }else {
            runnerColor = 4
        }
        
        let newCoordinate = CLLocationCoordinate2DMake(coordinates.latitude, coordinates.longitude);
        let title = name
        let typeRawValue: Int? = Int(4)
        let type = AttractionType(rawValue: typeRawValue!)!
        let annotation = AttractionAnnotation(coordinate: newCoordinate, title: title, desc: indexNumber, type: type, color: AttractionColor(rawValue: runnerColor)!)
        mapView.addAnnotation(annotation)
        dictionaryOfLastAnnotations[name] = annotation;
    }
    
    func buttonClicked(sender:UIButton) {
        if (sender.titleLabel!.text == "LIVE-SHARE OFF" || sender.titleLabel!.text == "LIVE-SHARE ON") {
            if self.isTransmitOn == false {
                sender.setTitle("LIVE-SHARE ON", forState: UIControlState.Normal)
                sender.backgroundColor = UIColor(red: 56.0/255.0, green: 134.0/255.0, blue: 121.0/255.0, alpha: 1.0)
                //sender.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                //sender.highlighted = true;
                self.isTransmitOn = true
            } else {
                sender.setTitle("LIVE-SHARE OFF", forState: UIControlState.Normal)
                //sender.backgroundColor = UIColor(red: 0, green: 100, blue: 0, alpha: 1.0)
                sender.backgroundColor = UIColor(red: 14.0/255.0, green: 70.0/255.0, blue: 78.0/255.0, alpha: 1.0)
                //sender.backgroundColor = UIColor(red: 181.0/255.0, green: 101.0/255.0, blue: 166.0/255.0, alpha: 1.0)
                sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                //sender.highlighted = false;
                self.isTransmitOn = false
            }
        } else {
            if self.isCenterOn == false {
                sender.setTitle("CENTER ON", forState: UIControlState.Normal)
                //sender.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                sender.backgroundColor = UIColor(red: 255.0/255.0, green: 89.0/255.0, blue: 89.0/255.0, alpha: 1.0)
                //sender.highlighted = true;
                self.isCenterOn = true
            } else {
                sender.setTitle("CENTER OFF", forState: UIControlState.Normal)
                sender.backgroundColor = UIColor(red: 191.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)
                
                //sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                //sender.highlighted = false;
                self.isCenterOn = false
            }
        }
    }
    
    @IBAction func startAction(sender: UIButton) {
        //If they denied GPS permission, disable start
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways &&
            CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
            ToastView.showToastInParentView(self.view, withText: "Sorry, you must enable GPS permissions to use this app!", withDuration: 2.0)
            return
        }
        
        seconds = 0.0
        distance = 0.0
        runners = 0
        //figure out number of runners:
        for i in 0..<UserInformation.sharedInstance.userIDsArray.count {
            if(UserInformation.sharedInstance.isUserBeingTrackedArray[i]) {
                self.runners += 1;
            }
        }
        //If nobody is running or runnerDictionary hasn't initialized, disable start
        if (self.runners == 0 || UserInformation.sharedInstance.countOfRunners == 0 || runnerDictionary[UserInformation.sharedInstance.userIDsArray[0]] == nil) {
            ToastView.showToastInParentView(self.view, withText: "You must select at least one friend to track!", withDuration: 2.0)
            return
        }
        startButton.removeTarget(self, action: #selector(IBNewRunViewController.startAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        startButton.addTarget(self, action: #selector(IBNewRunViewController.stopAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        startButton.setTitle("STOP", forState: UIControlState.Normal)
        
        locations.removeAll(keepCapacity: false)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(IBNewRunViewController.eachSecond(_:)), userInfo: nil, repeats: true)

        flagStartLocation = false
        startOnFlag = true
        startLocation()
        /*
        if(UserInformation.sharedInstance.isUserBeingTrackedArray[0])
        {
        startLocation()
        }else
        {
        recieveFriendLocationData()
        }*/
    }
    
    @IBAction func stopAction(sender: UIButton)
    {
        
        
        //startButton.setTitle("START", forState: UIControlState.Normal)
        let actionSheetController = UIAlertController (title: "Run Stopped", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        //Add Cancle-Action
        actionSheetController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        //Add Save-Action
        actionSheetController.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: { (actionSheetController) -> Void in
            self.startButton.removeTarget(self, action: #selector(IBNewRunViewController.stopAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.startButton.addTarget(self, action: #selector(IBNewRunViewController.startAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.startButton.setTitle("START", forState: UIControlState.Normal)
            self.startOnFlag = false;
            self.saveRun()
            self.performSegueWithIdentifier("ShowRunDetail", sender: nil)
            self.stopLocation()
        }))
        
        //Add Discard-Action
        actionSheetController.addAction(UIAlertAction(title: "Discard", style: UIAlertActionStyle.Default, handler: { (actionSheetController) -> Void in
            self.startButton.removeTarget(self, action: #selector(IBNewRunViewController.stopAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.startButton.addTarget(self, action: #selector(IBNewRunViewController.startAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.startButton.setTitle("START", forState: UIControlState.Normal)
            self.startOnFlag = false;
            self.stopLocation()
        }))
        
        //present actionSheetController
        presentViewController(actionSheetController, animated: true, completion: nil)
        
        
    }
    
    // MARK: - Location Handler
    func startLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopLocation() {
        locationManager.stopUpdatingLocation()
        seconds = 0.0
        distance = 0.0
        locations.removeAll(keepCapacity: false)
        timer.invalidate()
        
    }
    func eachSecond(timer : NSTimer) {
        if(!UserInformation.sharedInstance.isUserBeingTrackedArray[0] && startOnFlag && updateTimer == 2)
        {
            recieveFriendLocationData()
            updateTimer = 0
        }
        seconds += 1;
        //floor(1.5679999 * 1000) / 1000
        let secondsQuantity =  Int((floor((seconds)*100)/100) % 60)
        let minutesQuantity =  Int(((floor((seconds)*100)/100) / 60) % 60)
        let hoursQuantity =  Int(((floor((seconds)*100)/100) / 60) / 60)
        var secondsText = String(secondsQuantity)
        var minutesText = String(minutesQuantity)
        var hoursText = String(hoursQuantity)
        if secondsQuantity < 10 {
            secondsText = "0" + secondsText
        }
        if minutesQuantity < 10 {
            minutesText = "0" + minutesText
        }
        if hoursQuantity < 10 {
            hoursText = "0" + hoursText
        }
        timeLabel.text =  hoursText + ":" + minutesText + ":" + secondsText
        
        let milesFromMeters = distance * 0.000621371
        let distanceQuantity = HKQuantity(unit: HKUnit.mileUnit(), doubleValue: floor(milesFromMeters * 100)/100)
        distanceLabel.text = distanceQuantity.description
        let paceUnit = HKUnit.minuteUnit().unitDividedByUnit(HKUnit.mileUnit())
        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: floor(((seconds/60.0)/(distance * 0.000621371))*100)/100)
        if(floor(((seconds/60.0)/(distance * 0.000621371))*100)/100 == Double.infinity)
        {
            paceLabel.text = "--"
        }
        else{
            paceLabel.text = paceQuantity.description
        }
        updateTimer += 1;
    }
    
    
    // MARK: - Start log the run
    //TODO implement flag to check if first coordinate (so it doesn't grab random val from DB)
    //SPRATA: Added 2 new functions (for get and post calls) that work based on the userID
    //         need to implement them when we have a better handle on testing runners
    //This locationManager helps you find your friends
    //TRY CATCH NEEDED
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations as [CLLocation] {
            let howRecent = location.timestamp.timeIntervalSinceNow
            if abs(howRecent) < 10 && location.horizontalAccuracy < 20 {
                //var coords = [CLLocationCoordinate2D]()
                let curLocation = location.coordinate // self.locations.last!.coordinate;
                //var prevLocation = curLocation
                //update user distance if selected, transmitting data
                if(self.locations.count > 0 && UserInformation.sharedInstance.isUserBeingTrackedArray[0])
                {
                    distance += location.distanceFromLocation(self.locations.last!)
                    var userCoords = [CLLocationCoordinate2D]()
                    userCoords.append(location.coordinate)
                    isSmallestOrLargestXorY(location.coordinate)
                    dispatch_async(dispatch_get_main_queue(), {
                        //self.mapView.setRegion(region, animated: true)
                        self.currentRunner = self.runnerDictionary[UserInformation.sharedInstance.userIDsArray[0]]!;
                        self.mapView.addOverlay(MKPolyline(coordinates: &userCoords, count: userCoords.count))
                        if !self.runnerImageLoaded {
                            self.addUserPin(userCoords.last!, name: UserInformation.sharedInstance.name as String, indexNumber: String(UserInformation.sharedInstance.token))
                            self.runnerImageLoaded = true
                        }
                        self.userPin(userCoords.last!, name: UserInformation.sharedInstance.name as String, indexNumber: String(UserInformation.sharedInstance.token))
                    })
                    //transmit data if transmit on
                    if(UserInformation.sharedInstance.isRunnerTransmittingData && isTransmitOn)
                    {
                        //locationManager will send at most 1 post request per second
                        self.sendDistanceInformationToServerWithUserID(curLocation.latitude, lon: curLocation.longitude, userID: UserInformation.sharedInstance.userIDsArray[0])
                    }
                }
                //Update distances for everyone else
                recieveFriendLocationData();
                //save location
                self.locations.append(CLLocation(latitude: curLocation.latitude, longitude: curLocation.longitude))
                notStartLocation = true
            }
            recenterMapView();
        }
    }
    
    func recenterMapView()
    {
        dispatch_async(dispatch_get_main_queue(), {
            
            if(!(self.smallestYbound >= 180.0 || self.largestYbound <= -180.0 || self.smallestXbound >= 180.0 || self.smallestXbound <= -180.0) && self.isCenterOn )
            {
                var zoom = 0.01
                if(self.runners > 1)
                {
                    zoom = 0.001
                }
                let span =  MKCoordinateSpanMake(self.largestYbound-self.smallestYbound+0.001, self.largestXbound-self.smallestXbound+zoom)
                let region = MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: (self.smallestYbound+self.largestYbound)/2, longitude: (self.smallestXbound+self.largestXbound)/2), span)
                self.mapView.setRegion(region, animated: true)
            }
            self.resetBounds()
            //let region = MKCoordinateRegionMakeWithDistance(self.centerBound, 500, 500)
            
        })
    }
    
    func recieveFriendLocationData()
    {
        var addedPin = false
        var numberOfFriends = 0;
        
        for var i = 1; i < UserInformation.sharedInstance.userIDsArray.count; i++ {
            if UserInformation.sharedInstance.isUserBeingTrackedArray[i] //self.locations.count > 0 &&
            {
                let x = i
                returnPreviousLocationFromServerByUserID( UserInformation.sharedInstance.userIDsArray[x], userArrayNumber: x, completionClosure: { (success,lat,lon, err, userIDSame) -> Void in
                    // When download completes,control flow goes here.
                    //The logic below should be simplified, but at least now it will print something out
                    if (success == nil && lat == nil && lon == nil) {
                        print("Error!!!!:", err)
                        if((err?.containsString("transmit")) != nil && (err?.containsString("transmit"))!)
                        {
                            dispatch_async(dispatch_get_main_queue(), {
                                let name = UserInformation.sharedInstance.friendNames[x]
                                ToastView.showToastInParentView(self.view, withText: name + " has not transmitted a run.\nMake sure your friend has \"Transmit On\" selected.", withDuration: 4.0)
                            })
                        }
                        else if ((err?.containsString("time")) != nil && (err?.containsString("time"))!)
                        {
                            dispatch_async(dispatch_get_main_queue(), {
                                let name = UserInformation.sharedInstance.friendNames[x]
                                ToastView.showToastInParentView(self.view, withText: name + " has not transmitted recently.\nMake sure your friend has \"Transmit On\" selected.", withDuration: 4.0)
                            })
                        }
                        else if ((err?.containsString("standard")) != nil && (err?.containsString("standard"))!){
                            dispatch_async(dispatch_get_main_queue(), {
                                let name = UserInformation.sharedInstance.friendNames[x]
                                ToastView.showToastInParentView(self.view, withText:  "Something has gone wrong retreiving " + name + "'s location", withDuration:  2.5)
                            })
                        }
                        else {
                            dispatch_async(dispatch_get_main_queue(), {
                                let name = UserInformation.sharedInstance.friendNames[x]
                                ToastView.showToastInParentView(self.view, withText:  name + "is not transmitting their position", withDuration:  1.5)
                            })
                        }
                        
                    } else if ( success != nil && lat == nil && lon == nil ) {
                        dispatch_async(dispatch_get_main_queue(), {
                            let name = UserInformation.sharedInstance.friendNames[x]
                            ToastView.showToastInParentView(self.view, withText:  name + "is not transmitting position", withDuration:  2.5)
                        })
                    } else if (success != nil) {
                        if(!self.flagStartLocation){ //make sure not first run
                            self.isSmallestOrLargestXorY(CLLocationCoordinate2D(latitude: lat!,longitude: lon!))
                            self.arrayOfRunnerCoordinates[userIDSame!] = runnerCoordinates(runnerID: userIDSame!, lastCoordinate: CLLocationCoordinate2DMake(lat!, lon!))
                            
                            //Required to change the visual within a thread
                            dispatch_async(dispatch_get_main_queue(), {
                                self.currentRunner = self.runnerDictionary[userIDSame!]!;
                                //print("Current Runner:", self.currentRunner, " lastCoord", self.arrayOfRunnerCoordinates[userIDSame!]?.lastCoordinate)
                                var lC = self.arrayOfRunnerCoordinates[userIDSame!]!.lastCoordinate
                                
                                for trackedFriends in UserInformation.sharedInstance.isUserBeingTrackedArray {
                                    if trackedFriends.boolValue == true {
                                        numberOfFriends += 1;
                                    }
                                }
                                print(self.friendsRunning)
                                self.mapView.addOverlay(MKPolyline(coordinates: &lC, count: 1))
                                
                                if(UserInformation.sharedInstance.isPinAdded[x] == false) {
                                    self.addUserPin(lC, name: UserInformation.sharedInstance.friendNames[x], indexNumber: userIDSame!)
                                    UserInformation.sharedInstance.isPinAdded[x] = true
                                }
                                self.userPin(lC, name: UserInformation.sharedInstance.friendNames[x], indexNumber: userIDSame!)
                                //self.addUserPin(lC, name: UserInformation.sharedInstance.friendNames[x-1], indexNumber: userIDSame!)
                            })
                            //note after appended!
                            ////prevLocation.latitude = lat!
                            ////prevLocation.longitude = lon!
                        }else if(self.notStartLocation) {
                            print("------------First time, set lat&lon different")
                            ////prevLocation.latitude = lat!
                            ////prevLocation.longitude = lon!
                            self.flagStartLocation = false
                        } else {
                            print("First time, set lat&lon different")
                            ////prevLocation.latitude = lat!
                            ////prevLocation.longitude = lon!
                        }
                        // set this to false after first for loop
                    } else {
                        // download fail
                        print("Something went wrong in locationManager()")
                    }
                })

            }
        }
        recenterMapView();
        if(addedPin) {
            self.friendsRunning = numberOfFriends
        }
    }

    /**
     * Sends runner's location to server by using their user ID. (don't need to use user ID since always same runner, but whatevs. Implemented with a closure
     */
    func sendDistanceInformationToServerWithUserID( lat: Double, lon: Double, userID: String)
    {
        // print("\n\nSending RUNNER INFORMATION")
        let postHeaders = [
            "access-token": UserInformation.sharedInstance.accesstoken as String,
        ]
        
        let request2 = NSMutableURLRequest(URL: NSURL(string: "http://52.33.234.200:8080/api/runner/?latitude=\(lat)&longitude=\(lon)&timestamp=\(NSDate().timeIntervalSince1970)&id=\(userID)")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request2.HTTPMethod = "POST"
        request2.allHTTPHeaderFields = postHeaders
        
        let session2 = NSURLSession.sharedSession()
        let dataTask2 = session2.dataTaskWithRequest(request2, completionHandler: { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            if (error != nil) {
                print(error)
            } else {
                //let httpResponse = response as? NSHTTPURLResponse
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            }
        })
        
        dataTask2.resume()
    }
    
    /**
     * Returns runner's previous location from server by using their user ID. Implemented with a closure
     */
    func returnPreviousLocationFromServerByUserID(userID: String, userArrayNumber: Int, completionClosure: (success:Bool?, lat:Double?, lon:Double?, err:String?, userIDSame:String?) -> Void ) -> (latitude: Double, longitude: Double, userIDSame: String) {
        var latFromServer = "0.0";
        var lonFromServer = "0.0";
        var timeFromServer = 0.0;
        let headers = [
            "access-token": UserInformation.sharedInstance.accesstoken as String
        ]
        let request = NSMutableURLRequest(URL: NSURL(string: "http://52.33.234.200:8080/api/runner/?id=\(userID)")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                completionClosure(success: nil, lat: nil, lon: nil, err: "standard", userIDSame: nil)
                print(error)
            } else {
                do {
                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary {
                        latFromServer = jsonResult["Latitude"] as! String
                        lonFromServer = jsonResult["Longitude"] as! String
                        timeFromServer = jsonResult["Timestamp"] as! Double //Double(jsonResult["Timestamp"] as! String)!
                        let timeDifference = abs(timeFromServer - NSDate().timeIntervalSince1970)
                        //TODO: 3 hours seems longer then necessary; choose a smaller delta
                        if timeDifference < 172800// at the moment the buffer is 48 hours, change to 10800 (3 hours) for race day
                        {
                            print("time difference is ok!")
                            completionClosure(success: true, lat: Double(latFromServer), lon: Double(lonFromServer), err: nil, userIDSame: userID)
                        }else //else we should probably stop tracking them if its been that long...
                        {
                            //TODO BUGCHECK!!!!!
                            print("TIMEFROMSERVER:", timeFromServer)
                            print("TIMEINTERVALSINCE1970:", NSDate().timeIntervalSince1970)
                            print("time difference is too big :( ", timeDifference)
                           // let name = UserInformation.sharedInstance.friendNames[userArrayNumber]
                        // ToastView.showToastInParentView(self.view, withText: name + " has not transmitted recently. Make sure your friend has \"Transmit On\" selected.", withDuration: 1.0)
                            self.runners -= 1
                            UserInformation.sharedInstance.isUserBeingTrackedArray[userArrayNumber] = false
                            //success with nil lat/lon implies the runner has no recently defined position
                            completionClosure(success: nil, lat: nil, lon: nil, err: "time",userIDSame: userID)
                        }
                        
                    } else {
                        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding) // No error thrown, but not NSDictionary
                        print("Error could not parse JSON: \(jsonStr)")
                    }
                } catch let parseError {
                    print("CATCH")
                    print(parseError) // Log the error thrown by `JSONObjectWithData`
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: '\(jsonStr)'")
                    if((jsonStr?.containsString("Get non-friend or nonexistent user")) != nil)
                    {
                        self.runners -= 1 //set back the number of runners
                        //stop tracking the user
                        UserInformation.sharedInstance.isUserBeingTrackedArray[userArrayNumber] = false
                        // let name = UserInformation.sharedInstance.friendNames[userArrayNumber]
                        // ToastView.showToastInParentView(self.view, withText: "Cannot track " + name + "\nMake sure your friend has logged in to the app.", withDuration: 1.0)
                        //TODO notify the user that their friend is not on the app... not sure how that would happen
                    }else //if no location information for user (need to find command for that)
                    {
                        // let name = UserInformation.sharedInstance.friendNames[userArrayNumber]
                        // ToastView.showToastInParentView(self.view, withText: name + " has not transmitted a run. Make sure your friend has \"Transmit On\" selected.", withDuration: 1.0)
                        self.runners -= 1
                        UserInformation.sharedInstance.isUserBeingTrackedArray[userArrayNumber] = false
                        //TODO notify the user that their friend has not attempted to be tracked yet
                    }
                    completionClosure(success: nil, lat: nil, lon: nil, err: "transmit", userIDSame: userID)
                }
            }
            
        })
        
        dataTask.resume()
        return(Double(latFromServer)!, Double(lonFromServer)!, userID)
        
    }
    /**
     *Used to center the map by finding the smallest and largest coordinates at each interval
     */
    
    func isSmallestOrLargestXorY(co : CLLocationCoordinate2D) -> Bool
    {
        if(co.latitude < smallestYbound)
        {
            smallestYbound = co.latitude
        }
        if(co.latitude > largestYbound)
        {
            largestYbound = co.latitude
        }
        if(co.longitude < smallestXbound)
        {
            smallestXbound = co.longitude
        }
        if(co.longitude > largestXbound)
        {
            largestXbound = co.longitude
        }
        return true
    }
    
    func resetBounds()
    {
        smallestYbound = 190.0
        smallestXbound = 190.0
        largestYbound = -190.0
        largestXbound = -190.0
    }
    
    // MARK: - Save the run
    func saveRun()
    {
        let savedRun = NSEntityDescription.insertNewObjectForEntityForName("Run", inManagedObjectContext: managedObjectContext!) as! Run
        savedRun.distance = distance
        savedRun.duration = seconds
        savedRun.timestamp = NSDate()
        
        var savedLocations = [Location]()
        for location in locations {
            let savedLocation = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedObjectContext!) as! Location
            savedLocation.timestamp = location.timestamp
            savedLocation.latitude = location.coordinate.latitude
            savedLocation.longitude = location.coordinate.longitude
            savedLocations.append(savedLocation)
        }
        savedRun.locations = NSOrderedSet(array: savedLocations)
        run = savedRun
        
        //handle errors
        //        var error : NSError?
        //        let success = managedObjectContext!.save()
        
        do {
            try managedObjectContext!.save()
        } catch {
            print("Could not save the run!")
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let detailViewController = segue.destinationViewController as? IBRunDetailViewController {
            detailViewController.run = run
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension IBNewRunViewController : CLLocationManagerDelegate {
    
}

extension IBNewRunViewController : MKMapViewDelegate {
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        //t
        if overlay is RunMapOverlay {
            let magicMountainImage = UIImage(named: "track")
            let overlayView = RunMapOverlayView(overlay: overlay, overlayImage: magicMountainImage!)
            
            return overlayView
        }
        //t
        let polyline = overlay as! MKPolyline
        
        let renderer = MKPolylineRenderer(polyline: polyline)
        
        if currentRunner%5 == 0 {
            renderer.strokeColor = UIColor(red: 250/255, green: 121/255, blue: 33/255, alpha: 1.0)
        }else if currentRunner%5 == 1 {
            renderer.strokeColor = UIColor(red: 91/255, green: 192/255, blue: 235/255, alpha: 1.0)
        }else if currentRunner%5 == 2 {
            renderer.strokeColor = UIColor(red: 155/255, green: 197/255, blue: 61/255, alpha: 1.0)
        }else if currentRunner%5 == 3 {
            renderer.strokeColor = UIColor(red: 229/255, green: 89/255, blue: 52/255, alpha: 1.0)
        }else {
            renderer.strokeColor = UIColor(red: 253/255, green: 231/255, blue: 76/255, alpha: 1.0)
        }
        renderer.lineWidth = 5

        return renderer
    }
}