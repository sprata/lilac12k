//
//  vgbcontroller.swift
//  Lilac12k
//
//  Created by Kaitlin Anderson on 4/21/16.
//  Copyright © 2016 codemysource. All rights reserved.
//

import UIKit
import WebKit

class vgbcontroller: UIViewController{
 
    @IBOutlet weak var containerView: UIView!
   
    @IBOutlet weak var webView: UIWebView!

let url = "https://app.virtualeventbags.com/lilac-bloomsday-run/spokane-2016"

override func viewDidLoad() {
    super.viewDidLoad()
    
    let requestURL = NSURL(string:url)
    let request = NSURLRequest(URL: requestURL!)
    webView!.loadRequest(request)
}
}



/* 
 @IBAction func GoodieBag(sender: AnyObject) {
 if let url = NSURL(string: "https://app.virtualeventbags.com/lilac-bloomsday-run/spokane-2016") {
 UIApplication.sharedApplication().openURL(url)
 }
 }
 
 @IBAction func Results(sender: AnyObject) {
 if let url = NSURL(string: "http://bloomsdayrun.org/results/all-finishers") {
 UIApplication.sharedApplication().openURL(url)
 }
 }
 
 @IBAction func Facebook(sender: AnyObject) {
 if let url = NSURL(string: "http://www.facebook.com") {
 UIApplication.sharedApplication().openURL(url)
 }
 }
 
 @IBAction func Sponsors(sender: AnyObject) {
 if let url = NSURL(string: "https://www.bloomsdayrun.org/sponsors/bloomsday-sponsors") {
 UIApplication.sharedApplication().openURL(url)
 }
 }
 
 @IBAction func RacePhotos(sender: AnyObject) {
 if let url = NSURL(string: "https://www.bloomsdayrun.org/race-photos") {
 UIApplication.sharedApplication().openURL(url)
 }
 }
 */