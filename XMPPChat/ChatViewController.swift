//
//  ChatViewController.swift
//  XMPPChat
//
//  Created by HKMac on 2017/6/22.
//  Copyright © 2017年 张玉飞. All rights reserved.
//

import UIKit
import CoreData
import XMPPFramework

class ChatViewController: UIViewController {

    var userJid: XMPPJID? = nil
    
    var messages = [XMPPMessageArchiving_Message_CoreDataObject]()
    let manager = XMPPStreamManager.shareManager
    
    @IBOutlet weak var tableView: UITableView!
    lazy var fetchController: NSFetchedResultsController<NSFetchRequestResult> = { [unowned self] in
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let context = XMPPMessageArchivingCoreDataStorage.sharedInstance().mainThreadManagedObjectContext!
        
        // 实体
        let entity = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: context)
        fetchRequest.entity = entity
        // 谓词
        let pre = NSPredicate(format: "bareJidStr = %@", self.userJid!.full())
        fetchRequest.predicate = pre

        // 排序
        let sort = NSSortDescriptor(key: "timestamp", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        let fetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "messages")
        
        return fetchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: "messages")

        manager.messageArchiving.addDelegate(self, delegateQueue: DispatchQueue.global())
        manager.vCardAvatar.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillChange(_:)),
            name: .UIKeyboardWillChangeFrame, object: nil)
        
        // Do any additional setup after loading the view.
        let nib = UINib(nibName: "MessageTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "message_cell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 65
        automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        
        fetchController.delegate = self
        do {
            try fetchController.performFetch()
            messages = fetchController.fetchedObjects as! [XMPPMessageArchiving_Message_CoreDataObject]
            tableView.reloadData()
            scrollToBottom()
        } catch {}
    }
    
    

    deinit {
        // 移除通知中心
        NotificationCenter.default.removeObserver(self)
    }
    // 键盘将要显示
    func keyboardWillChange(_ notification: Notification) {

        let info = notification.userInfo

        let duration: Double = info![UIKeyboardAnimationDurationUserInfoKey] as! Double
        let keyFrame: CGRect = info![UIKeyboardFrameEndUserInfoKey] as! CGRect
        let moveY = keyFrame.origin.y - UIScreen.main.bounds.size.height
        UIView.animate(withDuration: duration) {
            self.view.transform = CGAffineTransform(translationX: 0, y: moveY)
        }
    }
    /// 滑动至最底端
    func scrollToBottom() {
        if messages.count > 1 {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
        
    }
}

extension ChatViewController: NSFetchedResultsControllerDelegate {
    
    /// CoreData数据发生变化
    ///
    /// - Parameter controller:
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        messages = fetchController.fetchedObjects as! [XMPPMessageArchiving_Message_CoreDataObject]
        tableView.reloadData()
        scrollToBottom()
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "message_cell", for: indexPath) as! MessageTableViewCell
        cell.model = message
        return cell
    }
}

extension ChatViewController: XMPPMessageArchiveManagementDelegate {
    func xmppMessageArchiveManagement(_ xmppMessageArchiveManagement: XMPPMessageArchiveManagement!, didReceiveMAMMessage message: XMPPMessage!) {
        print(message.body())
    }
}

extension ChatViewController: XMPPvCardAvatarDelegate {
    func xmppvCardAvatarModule(_ vCardTempModule: XMPPvCardAvatarModule!, didReceivePhoto photo: UIImage!, for jid: XMPPJID!) {
        tableView.reloadData()
    }
}

extension ChatViewController: UITextFieldDelegate {
    
    /// 发消息
    ///
    /// - Parameter textField: 文本框
    /// - Returns:
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let message = XMPPMessage(type: "chat", to: userJid)
        message?.addBody(textField.text)
        
        XMPPStreamManager.shareManager.xmppStream.send(message)
        textField.text = ""
        // 收键盘
        textField.endEditing(true)
        return true
    }
}
