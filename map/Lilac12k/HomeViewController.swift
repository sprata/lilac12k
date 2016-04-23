//
//  HomeViewController.swift
//  Lilac12k
//
//  Created by Kaitlin Anderson on 2/4/16.
//  Copyright © 2016 codemysource. All rights reserved.
//

import UIKit
import Foundation
import Darwin
class HomeViewController : UIViewController{

    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var days: UILabel!
    @IBOutlet weak var hours: UILabel!
    @IBOutlet weak var minutes: UILabel!

    @IBOutlet weak var welcomeMessage: UILabel!

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var startButton: UIButton!
    var timer = NSTimer();
    
    
    
    @IBOutlet weak var Schedule: UIButton!
    @IBOutlet weak var Parking: UIButton!
    @IBOutlet weak var TrainingTips: UIButton!
    @IBOutlet weak var Registration: UIButton!
    @IBOutlet weak var Bloomsday40: UIButton!
    @IBOutlet weak var FAQ: UIButton!
    
    @IBAction func Schedule(sender: AnyObject) {
        if let url = NSURL(string: "http://bloomsdayrun.org/race-information/weekend-schedule") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func Parking(sender: AnyObject) {
        if let url = NSURL(string: "http://www.downtownspokane.org/documents/ParkingMap2010.pdf") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func TrainingTips(sender: AnyObject) {
        if let url = NSURL(string: "http://bloomsdayrun.org/training/training-program") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func Registration(sender: AnyObject) {
        if let url = NSURL(string: "http://bloomsdayrun.org/registration/register-online") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func Bloomsday40(sender: AnyObject) {
        if let url = NSURL(string: "http://bloomsdayrun.org/40th-year-video") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func FAQ(sender: AnyObject) {
        if let url = NSURL(string: "http://bloomsdayrun.org/faq") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    
    override func viewDidLoad() {
        print("HOMEVIEWCONTROLLER")

        timer = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: #selector(HomeViewController.update), userInfo: nil, repeats: true)

        super.viewDidLoad()
        
        setCountdownText()
        
        self.scroller.contentSize.height = 4000;

    }
    
    func setCountdownText() {
        let bloomsdayDate = 1462118400.0 //9:00 AM, May 1, 2016 (4:00 PM UTC)
        let timeLeft = Int( bloomsdayDate - NSDate().timeIntervalSince1970 )
        // s / (60*60*24) is whole days, then take remainder and divide by 3600 to get hours, then find minutes
        let (d,h,m) = (timeLeft / (3600*24), (timeLeft % (3600*24)) / 3600, (timeLeft % 3600) / 60)
        days.text = String(format: "%02d", max(d,0))
        hours.text = String(format: "%02d", max(h,0))
        minutes.text = String(format: "%02d", max(m,0))
    }
    
    
    override func viewDidLayoutSubviews() {
        scroller.scrollEnabled = true
    }

    func update() {
        //Update countdown each minute
        setCountdownText()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
        // Test the offset and calculate the current page after scrolling ends
        
    }
    
}