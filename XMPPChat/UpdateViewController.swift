//
//  UpdateViewController.swift
//  XMPPChat
//
//  Created by HKMac on 2017/7/1.
//  Copyright © 2017年 张玉飞. All rights reserved.
//

import UIKit
enum UpdateType: Int {
    case nickname
    case desc
}

class UpdateViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    var type: UpdateType = .nickname
    
    
    let myvCardTemp = XMPPStreamManager.shareManager.vCard.myvCardTemp!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        switch type {
        case .nickname:
            title = "修改昵称"
        case .desc:
            title = "个性签名"
        }
    }

    @IBAction func update(_ sender: Any) {
        switch type {
        case .nickname:
            myvCardTemp.nickname = textField.text
        case .desc:
            myvCardTemp.desc = textField.text
        }
        XMPPStreamManager.shareManager.vCard.updateMyvCardTemp(myvCardTemp)
        navigationController?.popViewController(animated: true)
    }

    

}
