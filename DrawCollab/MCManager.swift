//
//  MCManager.swift
//  DrawCollab
//
//  Created by Felix Hedlund on 06/04/16.
//  Copyright © 2016 Felix Hedlund. All rights reserved.
//

import MultipeerConnectivity

class MCManager: NSObject, MCSessionDelegate {
    var peerID: MCPeerID?
    var session: MCSession?
    var browser: MCBrowserViewController?
    var advertiser: MCAdvertiserAssistant?
    var arrConnectedDevices: NSMutableArray!
    override init(){
        super.init()
    }
    
    func setupPeerAndSessionWithDisplayName(displayName: String){
        arrConnectedDevices = NSMutableArray()
        peerID = MCPeerID(displayName: displayName)
        session = MCSession(peer: peerID!)
        session!.delegate = self
    }
    
    func setupMCBrowser(){
        if let s = session{
            browser = MCBrowserViewController(serviceType: "drawCollab", session: s)
        }
    }
    


    
    func advertiseSelf(shouldAdvertise: Bool){
        if let s = session{
            if shouldAdvertise{
                advertiser = MCAdvertiserAssistant(serviceType: "drawCollab", discoveryInfo: nil, session: s)
                advertiser!.start()
            }else{
                if let a = advertiser{
                    a.stop()
                }
                advertiser = nil
            }
        }
    
    }
    
    
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        let dictionary = ["peerID": peerID, "state": state.rawValue]
        NSNotificationCenter.defaultCenter().postNotificationName("MCDidChangeStateNotification", object: nil, userInfo: dictionary)
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
}
