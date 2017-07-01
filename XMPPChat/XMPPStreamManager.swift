//
//  XMPPStreamManager.swift
//  XMPPChat
//
//  Created by HKMac on 2017/6/20.
//  Copyright © 2017年 张玉飞. All rights reserved.
//

import UIKit
import XMPPFramework
import UserNotifications

class XMPPStreamManager:NSObject {
    static let shareManager = XMPPStreamManager()
    

    let xmppStream = XMPPStream()!
    
    /// 自动重连
    lazy var reconnect: XMPPReconnect = {
        let reconnect = XMPPReconnect(dispatchQueue: DispatchQueue.main)!
        reconnect.reconnectTimerInterval = 2
        return reconnect
    }()
    
    /// 心跳检查
    lazy var autoPing: XMPPAutoPing = {
        let autoPing = XMPPAutoPing(dispatchQueue: DispatchQueue.main)!
        autoPing.pingInterval = 3
        return autoPing
    }()
    
    
    /// 好友管理
    lazy var roster: XMPPRoster = {
        let roster = XMPPRoster(rosterStorage: XMPPRosterCoreDataStorage.sharedInstance(), dispatchQueue: DispatchQueue.global())!
        // 不清除用户数据
        roster.autoClearAllUsersAndResources = false
        // 不允许自动加为好友
        roster.autoAcceptKnownPresenceSubscriptionRequests = false
        
        return roster
    }()
    
    
    /// 消息管理
    lazy var messageArchiving: XMPPMessageArchiving = {
        var messageArchiving = XMPPMessageArchiving(messageArchivingStorage: XMPPMessageArchivingCoreDataStorage.sharedInstance(), dispatchQueue: DispatchQueue.global())!
        
        return messageArchiving
    }()
    
    /// 个人资料
    let vCard = XMPPvCardTempModule(vCardStorage: XMPPvCardCoreDataStorage.sharedInstance(), dispatchQueue: DispatchQueue.main)!
    
    /// 指定用户资料
    lazy var vCardAvatar: XMPPvCardAvatarModule = { [unowned self] in
        let vCardAvatar = XMPPvCardAvatarModule(vCardTempModule: self.vCard, dispatchQueue: DispatchQueue.main)!
        return vCardAvatar
    }()
    
    let serverAddr = "localhost"
    
    /// 密码
    var password = ""
    
    /// 设置流
    func setStream() {
        // 设置属性
        xmppStream.hostName = serverAddr
        xmppStream.hostPort = 5222
        // 设置代理 多播代理
        xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        
    }
    
    
    /// 激活组件
    func activate() {
        reconnect.activate(xmppStream)
//        autoPing.activate(xmppStream)
        
        roster.addDelegate(self, delegateQueue: DispatchQueue.global())
        roster.activate(xmppStream)
        
        messageArchiving.activate(xmppStream)
        
        vCard.activate(xmppStream)
        vCardAvatar.activate(xmppStream)
    }
    
    override init() {
        super.init()
        setStream()
    }
    // 连接服务器并且连接
    func loginToServer(user: String, password: String) {
        self.password = password
        let myJid = XMPPJID(user: user, domain: serverAddr, resource: "iphone")
        // 设置myJID
        xmppStream.myJID = myJid
        // 连接服务器
        do {
            try xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
        } catch {}
//        激活功能
        activate()
    }
    
}


extension XMPPStreamManager: XMPPStreamDelegate, XMPPRosterDelegate {
    // MARK: - XMPPStreamDelegate
    func xmppStream(_ sender: XMPPStream!, socketDidConnect socket: GCDAsyncSocket!) {
        
    }
    // 连接是否成功
    func xmppStreamDidConnect(_ sender: XMPPStream!) {
        print("连接上服务器")
        // 密码认证
        do {
            try xmppStream.authenticate(withPassword: password)
        } catch  {}
        
        // 注册
//        xmppStream.register(withPassword: password)
    }
    
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream!) {
        //设置出席状态
        let presence = XMPPPresence()!
        let showNode = DDXMLNode.element(withName: "show", stringValue: "dnd") as! DDXMLNode
        let statusNode = DDXMLNode.element(withName: "status", stringValue: "别来烦我！！") as! DDXMLNode
        
        presence.addChild(showNode)
        presence.addChild(statusNode)
        
        xmppStream.send(presence)
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceive message: XMPPMessage!) {
//        print(message.body())
        
//        let content = UNMutableNotificationContent()
//        content.title = "新消息"
//        content.subtitle = "new message"
//        content.body = message.body()
//        
//        let noti = UNNotificationRequest(identifier: "noti", content: content, trigger: nil)
//        
//        UNUserNotificationCenter.current().add(noti, withCompletionHandler: nil)
    }
    
    // MARK: - XMPPRosterDelegate
    
}

