//
//  trainingtips.swift
//  Lilac12k
//
//  Created by Chauncy Cullitan on 4/22/16.
//  Copyright © 2016 codemysource. All rights reserved.
//


import UIKit
import WebKit

class trainingtipscontroller: UIViewController{
    
    
    @IBOutlet weak var webView: UIWebView!

    let url = "https://www.bloomsdayrun.org/training/training-program"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        webView!.loadRequest(request)
    }
}
