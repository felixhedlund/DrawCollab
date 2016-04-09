//
//  MCManager.swift
//  DrawCollab
//
//  Created by Felix Hedlund on 06/04/16.
//  Copyright © 2016 Felix Hedlund. All rights reserved.
//

import MultipeerConnectivity

protocol SearchForMultiPeerHostDelegate{
    func peersChanged()
}


func == (lhs: Peer, rhs: Peer) -> Bool {
    if let id1 = lhs.id{
        if let id2 = rhs.id{
            return id1 == id2
        }
    }
    return false
}

func < (lhs: Peer, rhs: Peer) -> Bool {
    return lhs.id == rhs.id
}
class Peer: Comparable{
    var id: MCPeerID!
    var displayName: String!
    var image: UIImage?
    var state: MCSessionState!
    init(id: MCPeerID, displayName: String, image: UIImage?, state: MCSessionState){
        self.state = state
        self.id = id
        self.displayName = displayName
        if let i = image{
            self.image = i
        }
    }
    
    func updateState(state: MCSessionState){
        self.state = state
    }
    
    func updateImage(image: UIImage){
        self.image = image
    }
}

class MCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate {
    var peerID: MCPeerID?
    var session: MCSession?
    var browser: MCNearbyServiceBrowser?
    var advertiser: MCAdvertiserAssistant?
    var arrConnectedDevices: NSMutableArray!
    
    var discoveryImageStringEncoded: String?
    var delegate: SearchForMultiPeerHostDelegate?
    var peers: [Peer]!
    override init(){
        super.init()
    }
    
    func resetManager(){
        if let a = advertiser{
            a.stop()
        }
        if let b = browser{
            b.stopBrowsingForPeers()
        }
        if let s = session{
            s.disconnect()
        }
        delegate = nil
        
    }
    
    func setupPeerAndSessionWithDisplayNameAndImage(displayName: String, imageStringEncoded: String?){
        peers = [Peer]()
        self.discoveryImageStringEncoded = imageStringEncoded
        arrConnectedDevices = NSMutableArray()
        peerID = MCPeerID(displayName: displayName)
        session = MCSession(peer: peerID!)
        session!.delegate = self
    }
    
//    func setupMCBrowser(){
//        if let s = session{
//            browser = MCBrowserViewController(serviceType: "drawCollab", session: s)
//        }
//    }
    
    
    //Host
    func searchForPeers(){
        if let id = peerID{
            browser = MCNearbyServiceBrowser(peer: id, serviceType: "drawCollab")
            browser?.delegate = self
            browser?.startBrowsingForPeers()
        }
        
    }

    //Join
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
    
    func sendJoinRequest(rowForPeer: Int){
        let peer = self.peers[rowForPeer].id
        browser?.invitePeer(peer, toSession: self.session!, withContext: nil, timeout: 30)
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
//        var image: UIImage? = nil
//        if let i = info{
//            if let discImageString = i["discoveryImageString"]{
//                if let data = NSData(base64EncodedString: discImageString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters){
//                    if let i = UIImage(data: data){
//                        image = i
//                    }
//                }
//            }
//        }
        let displayName = peerID.displayName
        let peer = Peer(id: peerID, displayName: displayName, image: nil, state: MCSessionState.NotConnected)
        if self.peers.count > 0{
            
            //If peer exist exchange it
            
            self.peers.append(peer)
        }else{
            self.peers.append(peer)
        }
        
        if let del = delegate{
            del.peersChanged()
        }
        
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        var index = 0
        for peer in peers{
            if peer.id == peerID{
                peers.removeAtIndex(index)
                break
            }
            index += 1
        }
        if let del = delegate{
            del.peersChanged()
        }
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        //let dictionary = ["peerID": peerID, "state": state.rawValue]
        let peer = Peer(id: peerID, displayName: peerID.displayName, image: nil, state: state)
        if peers.count == 0{
            self.peers.append(peer)
        }else{
            var wasFound = false
            for p in peers{
                if p == peer{
                    p.updateState(state)
                    wasFound =  true
                    break
                }
            }
            if !wasFound{
                self.peers.append(peer)
            }
        }
        delegate?.peersChanged()
//        NSNotificationCenter.defaultCenter().postNotificationName("MCDidChangeStateNotification", object: nil, userInfo: dictionary)
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
