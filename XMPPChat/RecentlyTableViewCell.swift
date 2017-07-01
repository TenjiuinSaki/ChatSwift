//
//  RecentlyTableViewCell.swift
//  XMPPChat
//
//  Created by HKMac on 2017/7/1.
//  Copyright © 2017年 张玉飞. All rights reserved.
//

import UIKit
import XMPPFramework

class RecentlyTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    var model: XMPPMessageArchiving_Contact_CoreDataObject? = nil {
        didSet {
            guard let contact = model else {
                return
            }
            nameLabel.text = contact.bareJidStr
            messageLabel.text = contact.mostRecentMessageBody
            timeLabel.text = contact.mostRecentMessageTimestamp.description
            let data = XMPPStreamManager.shareManager.vCardAvatar.photoData(for: contact.bareJid)
            if let data = data {
                avatar.image = UIImage(data: data)
            }
        }
    }
}
