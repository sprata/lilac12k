//
//  photoscontroller.swift
//  Lilac12k
//
//  Created by Kaitlin Anderson on 4/21/16.
//  Copyright © 2016 codemysource. All rights reserved.
//


import UIKit
import WebKit

class photoscontroller: UIViewController{
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var webView: UIWebView!
    
    let url = "https://www.bloomsdayrun.org/race-photos"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        webView!.loadRequest(request)
    }
}