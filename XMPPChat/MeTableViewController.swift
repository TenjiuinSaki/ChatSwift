//
//  MeTableViewController.swift
//  XMPPChat
//
//  Created by HKMac on 2017/7/1.
//  Copyright © 2017年 张玉飞. All rights reserved.
//

import UIKit
import XMPPFramework

class MeTableViewController: UITableViewController {
    @IBOutlet weak var name: UILabel!

    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    let manager = XMPPStreamManager.shareManager
    var myvCardTemp: XMPPvCardTemp!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myvCardTemp = manager.vCard.myvCardTemp
        manager.vCard.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        update()
    }

    func update() {
        
        
        avatar.image = UIImage(data: myvCardTemp.photo!)
        
        name.text = manager.xmppStream.myJID.bare()
        
        nickname.text = myvCardTemp.nickname
        
        descLabel.text = myvCardTemp.desc
    }
    
   
}

extension MeTableViewController: XMPPvCardTempModuleDelegate {
    func xmppvCardTempModuleDidUpdateMyvCard(_ vCardTempModule: XMPPvCardTempModule!) {
        
        myvCardTemp = vCardTempModule.myvCardTemp!
        
        update()
    }
}
