//
//  ViewController.swift
//  XMPPChat
//
//  Created by HKMac on 2017/6/20.
//  Copyright © 2017年 张玉飞. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let manager = XMPPStreamManager.shareManager
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manager.loginToServer(user: "lisi", password: "123")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

