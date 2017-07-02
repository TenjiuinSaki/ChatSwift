//
//  ContactViewController.swift
//  XMPPChat
//
//  Created by HKMac on 2017/6/22.
//  Copyright © 2017年 张玉飞. All rights reserved.
//

import UIKit
import CoreData
import XMPPFramework

class ContactViewController: UITableViewController {
    
    var contacts = [XMPPUserCoreDataStorageObject]()
    let manager = XMPPStreamManager.shareManager
    
    lazy var fetchController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let context = XMPPRosterCoreDataStorage.sharedInstance().mainThreadManagedObjectContext!
        // 实体
        let entity = NSEntityDescription.entity(forEntityName: "XMPPUserCoreDataStorageObject", in: context)
        fetchRequest.entity = entity
        // 谓词
        let pre = NSPredicate(format: "subscription = %@", "both")
        fetchRequest.predicate = pre
        // 排序
        let sort = NSSortDescriptor(key: "displayName", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        let fetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "contacts")
        
        return fetchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: "contacts")

        // Do any additional setup after loading the view.
        manager.roster.addDelegate(self, delegateQueue: DispatchQueue.global())
        
        let nib = UINib(nibName: "ContactTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "contact_cell")
        tableView.rowHeight = 85
        tableView.tableFooterView = UIView()
        
        fetchController.delegate = self
        do {
            try fetchController.performFetch()
            contacts = fetchController.fetchedObjects as! [XMPPUserCoreDataStorageObject]
            tableView.reloadData()
        } catch {}
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contact = contacts[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "contact_cell", for: indexPath) as! ContactTableViewCell
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
        des.title = contact.displayName
        des.userJid = contact.jid
        
    }
    
    @IBAction func segueBack(segue: UIStoryboardSegue) {
        let sou = segue.source
        print(sou.title ?? "no title")
    }
    
    /// 添加好友
    ///
    /// - Parameter sender:
    @IBAction func addFriend(_ sender: UIBarButtonItem) {
        let jid = XMPPJID(user: "wangwu", domain: "localhost", resource: "ios")
        manager.roster.addUser(jid, withNickname: "加好友")
    }
    /// 删除好友
    ///
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contact = contacts[indexPath.row]
            manager.roster.removeUser(contact.jid)
        }
    }
}

extension ContactViewController: NSFetchedResultsControllerDelegate {
    
    /// CoreData数据发生变化
    ///
    /// - Parameter controller:
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        contacts = fetchController.fetchedObjects as! [XMPPUserCoreDataStorageObject]
        tableView.reloadData()
    }
}

extension ContactViewController: XMPPRosterDelegate {
    func xmppRoster(_ sender: XMPPRoster!, didReceivePresenceSubscriptionRequest presence: XMPPPresence!) {
        // 同意添加对方为好友
        let jid = XMPPJID(user: "wangwu", domain: "localhost", resource: "ios")
        manager.roster.acceptPresenceSubscriptionRequest(from: jid, andAddToRoster: true)
    }
}
