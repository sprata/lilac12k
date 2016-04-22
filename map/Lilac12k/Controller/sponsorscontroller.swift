//
//  sponsorscontroller.swift
//  Lilac12k
//
//  Created by Kaitlin Anderson on 4/21/16.
//  Copyright © 2016 codemysource. All rights reserved.
//


import UIKit
import WebKit

class sponsorscontroller: UIViewController{
    
    @IBOutlet weak var containerView: UIView!
    
   
    @IBOutlet weak var webView: UIWebView!
    
    let url = "https://www.bloomsdayrun.org/sponsors/bloomsday-sponsors"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        webView!.loadRequest(request)
    }
}