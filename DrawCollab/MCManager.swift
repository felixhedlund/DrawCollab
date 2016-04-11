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
    func imageWasReceived(image: UIImage, peer: MCPeerID)
    func stringWasReceived(receivedString: NSString)
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
    var deviceID: String!
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
    
    var discoveryImageData: NSData?
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
    
    func removeAllNonConnectedPeers(){
        for p in peers{
            if p.state != MCSessionState.Connected{
                let index = peers.indexOf(p)
                peers.removeAtIndex(index!)
            }
        }
    }
    
    func setupPeerAndSessionWithDisplayNameAndImage(displayName: String, imageData: NSData?){
        peers = [Peer]()
        self.discoveryImageData = imageData
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
    
    func removePeer(peer: MCPeerID){
        var index = 0
        for p in peers{
            if p.id == peer{
                peers.removeAtIndex(index)
            }
            index += 1
        }
        delegate?.peersChanged()
    }
    
    func disconnectFromHost(){
        if let d = delegate{
            self.peers.removeAll()
            self.resetManager()
            self.advertiseSelf(true)
            self.delegate = d
            d.peersChanged()
        }
        
    }
    
    func sendStartGameRequest(){
        let connectedPeers = session?.connectedPeers
        if connectedPeers?.count > 0{
            let startString = "StartGame"
            let data = startString.dataUsingEncoding(NSUTF8StringEncoding)
            
            do {
                try session?.sendData(data!, toPeers: connectedPeers!, withMode: .Reliable)
            } catch {
                print("Could not send start game")
            }
        }
    }
    
    func sendJoinRequest(rowForPeer: Int){
        let peer = self.peers[rowForPeer].id
        browser?.invitePeer(peer, toSession: self.session!, withContext: nil, timeout: 30)
    }
    
    func sendProfileImageToPeer(peer: MCPeerID){
        if let imageData = discoveryImageData{
            do {
               try self.session?.sendData(imageData, toPeers: [peer], withMode: MCSessionSendDataMode.Unreliable)
            } catch {
               print("Could not send imageData")
            }
        }
        
        
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
    
    func changePeerImage(image: UIImage, peer: MCPeerID){
        for p in peers{
            if p.id == peer{
                p.updateImage(image)
                break
            }
        }
        delegate?.peersChanged()
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
    
    func sendDrawImageToPeers(image: UIImage, peerToAvoid: MCPeerID?){
        let data = UIImagePNGRepresentation(image)
        
        
        
        if let d = data{
            if let s = session{
                var peers = [MCPeerID]()
                for peer in s.connectedPeers{
                    if let p = peerToAvoid{
                        if p == peer{
                            break
                        }else{
                            peers.append(peer)
                        }
                    }else{
                        peers.append(peer)
                    }
                }
                for host in peers{
                    do {
                        try s.sendData(d, toPeers: [host], withMode: .Unreliable)
                    } catch {
                        print("Could not send draw imageData")
                    }
                    
                }
            }
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
        if state == MCSessionState.Connected{
            self.sendProfileImageToPeer(peerID)
        }
        delegate?.peersChanged()
//        NSNotificationCenter.defaultCenter().postNotificationName("MCDidChangeStateNotification", object: nil, userInfo: dictionary)
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        if let drawController = delegate as? DrawViewController{
            let image = UIImage(data: data)
            if let i = image{
                self.delegate?.imageWasReceived(i, peer: peerID)
                if drawController.isHost{
                    self.sendDrawImageToPeers(i, peerToAvoid: peerID)
                }
            }
        }else{
            let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
            var isString = false
            if let string = dataString{
                if string == "StartGame"{
                    self.delegate?.stringWasReceived(string)
                    isString = true
                }
            }
            if !isString{
                let image = UIImage(data: data)
                if let i = image{
                    self.delegate?.imageWasReceived(i, peer: peerID)
                }
            }
        }
        
        
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
}
