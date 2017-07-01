//
//  DetailTableViewController.swift
//  XMPPChat
//
//  Created by HKMac on 2017/7/1.
//  Copyright © 2017年 张玉飞. All rights reserved.
//

import UIKit
import XMPPFramework

class DetailTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var name: UILabel!
    
    let manager = XMPPStreamManager.shareManager
    var myvCardTemp = XMPPStreamManager.shareManager.vCard.myvCardTemp!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.vCard.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        update()
    }

    func update() {
        
        
        avatar.image = UIImage(data: myvCardTemp.photo!)
        
        name.text = manager.xmppStream.myJID.bare()
        
        nickname.text = myvCardTemp.nickname
        
        descLabel.text = myvCardTemp.desc
    }
 
    @IBAction func pickImage(_ sender: Any) {
        
        let picker = UIImagePickerController()
        
        picker.allowsEditing = true
        
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
    }
    
    /// 选中图片
    ///
    /// - Parameters:
    ///   - picker: 控制器
    ///   - info: 详情
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // 获取图片
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        // 转换二进制
        let data = UIImageJPEGRepresentation(image, 0.2)
        // 更新头像
        myvCardTemp.photo = data
        manager.vCard.updateMyvCardTemp(myvCardTemp)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row < 2 {
            performSegue(withIdentifier: "update_segue", sender: indexPath.row)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let des = segue.destination as! UpdateViewController
        des.type = UpdateType(rawValue: sender as! Int)!
    }
}

extension DetailTableViewController: XMPPvCardTempModuleDelegate {
    func xmppvCardTempModuleDidUpdateMyvCard(_ vCardTempModule: XMPPvCardTempModule!) {
        
        myvCardTemp = vCardTempModule.myvCardTemp!
        
        update()
    }
}
