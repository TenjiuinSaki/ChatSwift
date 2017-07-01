//
//  MessageTableViewCell.swift
//  XMPPChat
//
//  Created by HKMac on 2017/6/22.
//  Copyright © 2017年 张玉飞. All rights reserved.
//

import UIKit
import XMPPFramework

class MessageTableViewCell: UITableViewCell {
    
    var model: XMPPMessageArchiving_Message_CoreDataObject? = nil {
        didSet {
            guard let model = model else {
                return
            }
            
            message.text = model.body
            if model.isOutgoing {  //我发送的
                message.textAlignment = .right
                leftImage.isHidden = true
                rightImage.isHidden = false
                
                let data = XMPPStreamManager.shareManager.vCard.myvCardTemp.photo
                if let data = data {
                    rightImage.image = UIImage(data: data)
                }
            } else {                // 发给我的
                message.textAlignment = .left
                leftImage.isHidden = false
                rightImage.isHidden = true
                
                let data = XMPPStreamManager.shareManager.vCardAvatar.photoData(for: model.bareJid)
                if let data = data {
                    leftImage.image = UIImage(data: data)
                }
            }
            
            
            
            
            
            
        }
    }
    
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var message: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
