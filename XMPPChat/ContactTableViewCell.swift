//
//  ContactTableViewCell.swift
//  XMPPChat
//
//  Created by HKMac on 2017/6/22.
//  Copyright © 2017年 张玉飞. All rights reserved.
//

import UIKit
import XMPPFramework

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var header: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    var model: XMPPUserCoreDataStorageObject? = nil {
        didSet {
            guard let model = model else {
                return
            }
            name.text = model.displayName
            let data = XMPPStreamManager.shareManager.vCardAvatar.photoData(for: model.jid)
            if let data = data {
                header.image = UIImage(data: data)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
