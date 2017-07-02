//
//  RecentlyViewController.swift
//  XMPPChat
//
//  Created by HKMac on 2017/7/1.
//  Copyright © 2017年 张玉飞. All rights reserved.
//

import UIKit
import XMPPFramework

class RecentlyViewController: UITableViewController {

    var contacts = [XMPPMessageArchiving_Contact_CoreDataObject]()
    let manager = XMPPStreamManager.shareManager
    
    lazy var fetchController: NSFetchedResultsController<NSFetchRequestResult> = { [unowned self] in
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let context = XMPPMessageArchivingCoreDataStorage.sharedInstance().mainThreadManagedObjectContext!
        
        // 实体
        let entity = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Contact_CoreDataObject", in: context)
        fetchRequest.entity = entity
        
        // 排序
        let sort = NSSortDescriptor(key: "mostRecentMessageTimestamp", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        let fetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "recently")
        
        return fetchController
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: "recently")
        
        manager.messageArchiving.addDelegate(self, delegateQueue: DispatchQueue.global())
        manager.vCardAvatar.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView()
        
        fetchController.delegate = self
        do {
            try fetchController.performFetch()
            contacts = fetchController.fetchedObjects as! [XMPPMessageArchiving_Contact_CoreDataObject]
            tableView.reloadData()
        } catch {}
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contact_cell", for: indexPath) as! RecentlyTableViewCell
        let contact = contacts[indexPath.row]
        cell.model = contact
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "chat_segue", sender: indexPath)
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let row = (sender as! NSIndexPath).row
        let contact = contacts[row]
        
        let des = segue.destination as! ChatViewController
        des.title = contact.bareJidStr
        des.userJid = contact.bareJid
    }

    @IBAction func addRoom(_ sender: Any) {
        let jid = XMPPJID(user: "ios", domain: "iosserver.localhost", resource: nil)
        XMPPMUCManager.shareManager.joinOrCreateRoom(roomjid: jid!, nickname: "lisi")
    }
}

// MARK: - 好友更改头像
extension RecentlyViewController: XMPPvCardAvatarDelegate {
    func xmppvCardAvatarModule(_ vCardTempModule: XMPPvCardAvatarModule!, didReceivePhoto photo: UIImage!, for jid: XMPPJID!) {
        tableView.reloadData()
    }
}

extension RecentlyViewController: NSFetchedResultsControllerDelegate {
    
    /// CoreData数据发生变化
    ///
    /// - Parameter controller:
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        contacts = fetchController.fetchedObjects as! [XMPPMessageArchiving_Contact_CoreDataObject]
        tableView.reloadData()
    }
}
