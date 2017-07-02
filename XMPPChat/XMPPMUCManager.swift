//
//  XMPPMUCManager.swift
//  XMPPChat
//
//  Created by HKMac on 2017/7/2.
//  Copyright © 2017年 张玉飞. All rights reserved.
//

import UIKit
import XMPPFramework

class XMPPMUCManager: NSObject, XMPPRoomDelegate {
    static let shareManager = XMPPMUCManager()
    
    let muc = XMPPMUC(dispatchQueue: DispatchQueue.main)!
    var roomDict = [XMPPJID: XMPPRoom]()
    let xmppStream = XMPPStreamManager.shareManager.xmppStream
    override init() {
        super.init()
        
        muc.addDelegate(self, delegateQueue: DispatchQueue.main)
        muc.activate(xmppStream)
    }
    
    func joinOrCreateRoom(roomjid: XMPPJID, nickname: String) {
        let room = XMPPRoom(roomStorage: XMPPRoomCoreDataStorage.sharedInstance(), jid: roomjid, dispatchQueue: DispatchQueue.main)!
        
        room.addDelegate(self, delegateQueue: DispatchQueue.main)
        room.activate(xmppStream)
        roomDict[roomjid] = room
        
        // 房间如果存在则加入，不存在创建并加入
        room.join(usingNickname: nickname, history: nil)
    }
    
    func xmppRoomDidCreate(_ sender: XMPPRoom!) {
        // 配置房间
        
        sender.configureRoom(usingOptions: nil)
        
    }
    
    func xmppRoomDidJoin(_ sender: XMPPRoom!) {
        
        let jid = XMPPJID(user: "wangwu", domain: "localhost", resource: nil)
        sender.inviteUser(jid, withMessage: "11234")
    }
}
