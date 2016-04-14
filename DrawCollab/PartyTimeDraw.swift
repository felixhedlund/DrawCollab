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
    func imageWasReceived(image: UIImage, peer: Peer)
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
    var color: UIColor!
    var state: MCSessionState!
    var deviceID: String!
    var opacity: Float!
    
    init(id: MCPeerID, displayName: String, state: MCSessionState){
        self.state = state
        self.id = id
        self.displayName = displayName
        self.color = UIColor.whiteColor()
        opacity = 1.0
    }
    
    func updateState(state: MCSessionState){
        self.state = state
    }
    
    func updateColor(color: UIColor, opacity: CGFloat){
        self.color = color
        self.opacity = Float(opacity)
    }
    
    func updateOpacity(opacity: Float){
        self.opacity = opacity
    }
}

class PartyTimeDraw: NSObject, PLPartyTimeDelegate{
    var peerID: MCPeerID?
    var session: MCSession?
    var browser: MCNearbyServiceBrowser?
    var advertiser: MCNearbyServiceAdvertiser?
    var arrConnectedDevices: NSMutableArray!
    
    var tempImage: UIImage!
    
    var redColor: CGFloat!
    var greenColor: CGFloat!
    var blueColor: CGFloat!
    var opacity: CGFloat = 1.0
    
    var delegate: SearchForMultiPeerHostDelegate?
    var peers: [Peer]!
    var timeStarted: NSDate!
    var lastMainDrawImage: UIImage?
    
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
    
    //let kPROFILE_IMAGE = "kPROFILE_IMAGE"
    let kPROFILE_COLOR = "kPROFILE_COLOR"
    let kSTART_GAME = "kSTART_GAME"
    let kDRAW_IMAGE = "kDRAW_IMAGE"
    
    func partyTime(partyTime: PLPartyTime!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        if let dic = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDictionary{
            if let _ = dic.objectForKey(kSTART_GAME){
                self.delegate?.startGameWasReceived()
            }else if let _ = dic.objectForKey(kPROFILE_COLOR){
                var c = UIColor.whiteColor()
                let colorString = dic[kPROFILE_COLOR] as! String
                let colorArray = colorString.characters.split{$0 == "%"}.map(String.init)
                
                var redColor:CGFloat = 1.0
                var greenColor:CGFloat = 1.0
                var blueColor:CGFloat = 1.0
                var opacity:CGFloat = 1.0
                let numberFormatter = NSNumberFormatter()
                numberFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
                
                if let n = numberFormatter.numberFromString(colorArray[0]){
                    redColor = CGFloat(n)
                }
                if let n = numberFormatter.numberFromString(colorArray[1]){
                    greenColor = CGFloat(n)
                }
                if let n = numberFormatter.numberFromString(colorArray[2]){
                    blueColor = CGFloat(n)
                }
                if let n = numberFormatter.numberFromString(colorArray[3]){
                    opacity = CGFloat(n)
                }
                
                c = UIColor(red: redColor, green: greenColor, blue: blueColor, alpha: 1)
                
                for peer in self.peers{
                    if peer.id == peerID{
                        peer.updateColor(c, opacity: opacity)
                        break
                    }
                }
                self.delegate?.peersChanged()
            }else if let imageData = dic.objectForKey(kDRAW_IMAGE) as? NSData{
                let image = UIImage(data: imageData)
                for peer in self.peers{
                    if peer.id == peerID{
                        self.delegate?.imageWasReceived(image!, peer: peer)
                        break
                    }
                }
                
            }
        }
        
    }
    
    func partyTime(partyTime: PLPartyTime!, failedToJoinParty error: NSError!) {
        
    }
    
    func sendProfileColor(peers: [MCPeerID]){
        if let p = partyTime{
            let colorString: String = "\(redColor)%\(greenColor)%\(blueColor)%\(opacity)"
            let dic = [kPROFILE_COLOR: colorString]
            let data = NSKeyedArchiver.archivedDataWithRootObject(dic)
            do {
                try p.sendData(data, toPeers: peers, withMode: .Reliable)
            } catch {
                print("Could not send image")
            }
        }
    }
    
    func sendNewProfileColor(){
        if let p = partyTime{
            let colorString: String = "\(redColor)%\(greenColor)%\(blueColor)%"
            let dic = [kPROFILE_COLOR: colorString]
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
                imageData = UIImagePNGRepresentation(image)
                
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
        let p = Peer(id: peer, displayName: peer.displayName, state: state)
        if !peers.contains(p){
            if state != MCSessionState.NotConnected{
                self.peers.append(p)
            }
            
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
            self.sendProfileColor([peer])
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