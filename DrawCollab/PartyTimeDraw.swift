//
//  PartyTime.swift
//  DrawCollab
//
//  Created by Felix Hedlund on 12/04/16.
//  Copyright © 2016 Felix Hedlund. All rights reserved.
//

import Foundation
import PartyTime

protocol SearchForMultiPeerHostDelegate{
    func peersChanged()
    func imageWasReceived(image: UIImage, peer: MCPeerID)
    func startGameWasReceived()
    //func stringWasReceived(receivedString: NSString)
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
        self.image = image//UIImage.roundedRectImageFromImage(image, imageSize: image.size, cornerRadius: image.size.height/2)
    }
}

class PartyTimeDraw: NSObject, PLPartyTimeDelegate{
    var peerID: MCPeerID?
    var session: MCSession?
    var browser: MCNearbyServiceBrowser?
    var advertiser: MCNearbyServiceAdvertiser?
    var arrConnectedDevices: NSMutableArray!
    
    var tempImage: UIImage!
    var discoveryImage: UIImage? {
        get {
            return tempImage
        }
        set{

            tempImage = self.resizeImage(newValue!, newWidth: 100)
            //tempImage = UIImage.roundedRectImageFromImage(tempImage, imageSize: tempImage.size, cornerRadius: tempImage.size.height/2)
        }
    }
    var delegate: SearchForMultiPeerHostDelegate?
    var peers: [Peer]!
    var timeStarted: NSDate!
    
    
    var partyTime: PLPartyTime?
    override init(){
        
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

    
    func setupPeerAndSessionWithDisplayNameAndImage(displayName: String){
        peers = [Peer]()
        if let _ = partyTime{
            
        }else{
            partyTime = PLPartyTime(serviceType: "drawCollab", displayName: displayName)
        }
        
        partyTime!.delegate = self
        partyTime!.joinParty()
    }
    
    func disconnectFromParty(){
        if peers != nil{
            peers.removeAll()
        }
        if let p = partyTime{
            p.leaveParty()
        }
        
        
    }
    
    let kPROFILE_IMAGE = "kPROFILE_IMAGE"
    let kSTART_GAME = "kSTART_GAME"
    let kDRAW_IMAGE = "kDRAW_IMAGE"
    
    func partyTime(partyTime: PLPartyTime!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        if let dic = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDictionary{
            if let _ = dic.objectForKey(kSTART_GAME){
                self.delegate?.startGameWasReceived()
            }else if let imageData = dic.objectForKey(kPROFILE_IMAGE) as? NSData{
                var i: UIImage? = UIImage(data: imageData)
                for peer in self.peers{
                    if peer.id == peerID{
                        peer.updateImage(i!)
                        break
                    }
                }
                i = nil
                self.delegate?.peersChanged()
            }else if let imageData = dic.objectForKey(kDRAW_IMAGE) as? NSData{
                let image = UIImage(data: imageData)
                self.delegate?.imageWasReceived(image!, peer: peerID)
            }
        }
        
    }
    
    func partyTime(partyTime: PLPartyTime!, failedToJoinParty error: NSError!) {
        
    }
    
    func sendStartGameRequest(){
        if let p = partyTime{
            let dic = [kSTART_GAME:"StartGame"]
            let data = NSKeyedArchiver.archivedDataWithRootObject(dic)
            do {
                var sendArray = [MCPeerID]()
                for peer in self.peers{
                    sendArray.append(peer.id)
                }
                try p.sendData(data, toPeers: sendArray, withMode: .Reliable)
            } catch {
                print("Could not send image")
            }
        }
    }
    
    func sendDrawImageToPeers(image: UIImage){
        if let p = partyTime{
            let imageData = UIImagePNGRepresentation(image)
            let dic = [kDRAW_IMAGE: imageData!]
            let data = NSKeyedArchiver.archivedDataWithRootObject(dic)
            do {
                var sendArray = [MCPeerID]()
                for peer in self.peers{
                    sendArray.append(peer.id)
                }
                try p.sendData(data, toPeers: sendArray, withMode: .Reliable)
                
            } catch {
                print("Could not send image")
            }
        }
    }
    
    func sendImage(image: UIImage, key: String, peer: MCPeerID?){
            if let p = partyTime{
                var imageData: NSData!
                if key == kPROFILE_IMAGE{
                    imageData = UIImagePNGRepresentation(image)
                }else{
                    imageData = UIImagePNGRepresentation(image)
                }
                
                let dic = [key: imageData!]
                let data = NSKeyedArchiver.archivedDataWithRootObject(dic)
                do {
                    if let singlePeer = peer{
                        try p.sendData(data, toPeers: [singlePeer], withMode: .Reliable)
                    }else{
                        var sendArray = [MCPeerID]()
                        for peer in self.peers{
                            sendArray.append(peer.id)
                        }
                        try p.sendData(data, toPeers: sendArray, withMode: .Reliable)
                    }
                } catch {
                    print("Could not send image")
                }
            }
        
        
    }
    
    func partyTime(partyTime: PLPartyTime!, peer: MCPeerID!, changedState state: MCSessionState, currentPeers: [AnyObject]!) {
        let p = Peer(id: peer, displayName: peer.displayName, image: nil, state: state)
        if !peers.contains(p){
            self.peers.append(p)
        }else{
            var index = 0
            for element in peers{
                if element.id == peer{
                    if state == MCSessionState.NotConnected{
                        peers.removeAtIndex(index)
                    }else{
                        element.updateState(state)
                    }
                    break
                }
                index += 1
            }
        }
        
        if state == MCSessionState.Connected{
            if let image = discoveryImage{
                self.sendImage(image, key: kPROFILE_IMAGE, peer: peer)
            }
        }
        delegate?.peersChanged()
        
    }
    
    func partyTime(partyTime: PLPartyTime!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func partyTime(partyTime: PLPartyTime!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func partyTime(partyTime: PLPartyTime!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {

    }
    
}