//
//  videocontroller.swift
//  Lilac12k
//
//  Created by Kaitlin Anderson on 4/22/16.
//  Copyright © 2016 codemysource. All rights reserved.
//

import UIKit
import WebKit

class videocontroller: UIViewController{
    

    @IBOutlet weak var webView: UIWebView!
    
    
    let url = "https://www.bloomsdayrun.org/40th-year-video"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        webView!.loadRequest(request)
    }
}
