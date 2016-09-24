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
    func imageWasReceived(_ image: UIImage, peer: Peer)
    func startGameWasReceived()
    func newMainImageWasReceived()
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
        self.color = UIColor.white
        opacity = 1.0
    }
    
    func updateState(_ state: MCSessionState){
        self.state = state
    }
    
    func updateColor(_ color: UIColor, opacity: CGFloat){
        self.color = color
        self.opacity = Float(opacity)
    }
    
    func updateOpacity(_ opacity: Float){
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
    var patternNumber: Int = 0
    var serviceType = "1canvas1"
    
    var delegate: SearchForMultiPeerHostDelegate?
    var peers: [Peer]!
    var timeStarted: Date!
    var lastMainDrawImage: UIImage?
    
    var partyTimes = [PLPartyTime?]()
    var currentPartyTime = 0
    override init(){
        
    }
    
    func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func initializePartyTime(){
        partyTimes[currentPartyTime]!.delegate = self
        for p in partyTimes{
            if p?.connected == true{
                p?.leaveParty()
            }
        }
        partyTimes[currentPartyTime]!.joinParty()
    }

    
    func setupPeerAndSessionWithDisplayNameAndImage(_ displayName: String){
        peers = [Peer]()
        if partyTimes.count == 0{
            partyTimes.insert(PLPartyTime(serviceType: "1canvas1", displayName: displayName), at: 0)
            partyTimes.insert(PLPartyTime(serviceType: "2canvas2", displayName: displayName), at: 1)
            partyTimes.insert(PLPartyTime(serviceType: "3canvas3", displayName: displayName), at: 2)
            partyTimes.insert(PLPartyTime(serviceType: "4canvas4", displayName: displayName), at: 3)
        }
    }
    
    
    
    func disconnectFromParty(){
        serviceType = "1canvas1"
        currentPartyTime = 0
        if peers != nil{
            peers.removeAll()
        }
        
        for p in partyTimes{
            if p?.connected == true{
                p?.leaveParty()
            }
        }
        
    }
    
    //let kPROFILE_IMAGE = "kPROFILE_IMAGE"
    let kPROFILE_COLOR = "kPROFILE_COLOR"
    let kSTART_GAME = "kSTART_GAME"
    let kDRAW_IMAGE = "kDRAW_IMAGE"
    let kMAIN_IMAGE = "kMAIN_IMAGE"
    
    
    
    func partyTime(_ partyTime: PLPartyTime!, didReceive data: Data!, fromPeer peerID: MCPeerID!) {
        if let dic = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSDictionary{
            if let _ = dic.object(forKey: kSTART_GAME){
                self.delegate?.startGameWasReceived()
            }else if let _ = dic.object(forKey: kPROFILE_COLOR){
                var c = UIColor.white
                let colorString = dic[kPROFILE_COLOR] as! String
                let colorArray = colorString.characters.split{$0 == "%"}.map(String.init)
                
                var redColor:CGFloat = 1.0
                var greenColor:CGFloat = 1.0
                var blueColor:CGFloat = 1.0
                var opacity:CGFloat = 1.0
                let numberFormatter = NumberFormatter()
                numberFormatter.locale = Locale(identifier: "en_US_POSIX")
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                
                if let n = numberFormatter.number(from: colorArray[0]){
                    redColor = CGFloat(n)
                }
                if let n = numberFormatter.number(from: colorArray[1]){
                    greenColor = CGFloat(n)
                }
                if let n = numberFormatter.number(from: colorArray[2]){
                    blueColor = CGFloat(n)
                }
                if let n = numberFormatter.number(from: colorArray[3]){
                    opacity = CGFloat(n)
                }
                
                if let n = numberFormatter.number(from: colorArray[4]){
                    patternNumber = Int(n)
                }
                
                c = UIColor(red: redColor, green: greenColor, blue: blueColor, alpha: 1)
                
                for peer in self.peers{
                    if peer.id == peerID{
                        peer.updateColor(c, opacity: opacity)
                        break
                    }
                }
                self.delegate?.peersChanged()
            }else if let imageData = dic.object(forKey: kDRAW_IMAGE) as? Data{
                let image = UIImage(data: imageData)
                for peer in self.peers{
                    if peer.id == peerID{
                        self.delegate?.imageWasReceived(image!, peer: peer)
                        break
                    }
                }
                
            }else if let imageData = dic.object(forKey: kMAIN_IMAGE) as? Data{
                let image = UIImage(data: imageData)
                if self.lastMainDrawImage == nil{
                    self.lastMainDrawImage = image
                    self.delegate?.newMainImageWasReceived()
                }
            }
        }
        
    }
    
    func partyTime(_ partyTime: PLPartyTime!, failedToJoinParty error: Error!) {
        
    }
    
    func sendProfileColor(_ peers: [MCPeerID]){
        if let p = partyTimes[currentPartyTime]{
            let colorString: String = "\(redColor!)%\(greenColor!)%\(blueColor!)%\(opacity)%\(patternNumber)"
            let dic = [kPROFILE_COLOR: colorString]
            let data = NSKeyedArchiver.archivedData(withRootObject: dic)
            do {
                try p.send(data, toPeers: peers, with: .reliable)
            } catch {
                print("Could not send image")
            }
        }
    }
    
    func sendErasor(_ peers: [MCPeerID]){
        if let p = partyTimes[currentPartyTime]{
            let colorString: String = "\(redColor!)%\(greenColor!)%\(blueColor!)%\(1.0)%\(patternNumber)"
            let dic = [kPROFILE_COLOR: colorString]
            let data = NSKeyedArchiver.archivedData(withRootObject: dic)
            do {
                try p.send(data, toPeers: peers, with: .reliable)
            } catch {
                print("Could not send image")
            }
        }
    }
    
//    func sendNewProfileColor(){
//        if let p = partyTime{
//            let colorString: String = "\(redColor)%\(greenColor)%\(blueColor)%\(opacity)%\(patternNumber)"
//            let dic = [kPROFILE_COLOR: colorString]
//            let data = NSKeyedArchiver.archivedDataWithRootObject(dic)
//            do {
//                var sendArray = [MCPeerID]()
//                for peer in self.peers{
//                    sendArray.append(peer.id)
//                }
//                try p.sendData(data, toPeers: sendArray, withMode: .Reliable)
//            } catch {
//                print("Could not send image")
//            }
//        }
//    }
    
    func sendStartGameRequest(){
        if let p = partyTimes[currentPartyTime]{
            let dic = [kSTART_GAME:"StartGame"]
            let data = NSKeyedArchiver.archivedData(withRootObject: dic)
            do {
                var sendArray = [MCPeerID]()
                for peer in self.peers{
                    sendArray.append(peer.id)
                }
                try p.send(data, toPeers: sendArray, with: .reliable)
            } catch {
                print("Could not send image")
            }
        }
    }
    
    func sendDrawImageToPeers(_ image: UIImage){
        if let p = partyTimes[currentPartyTime]{
            let imageData = UIImagePNGRepresentation(image)
            let dic = [kDRAW_IMAGE: imageData!]
            let data = NSKeyedArchiver.archivedData(withRootObject: dic)
            do {
                var sendArray = [MCPeerID]()
                for peer in self.peers{
                    sendArray.append(peer.id)
                }
                try p.send(data, toPeers: sendArray, with: .reliable)
                
            } catch {
                print("Could not send image")
            }
        }
    }
    
    func sendMainImageToPeer(_ image: UIImage, peer: MCPeerID){
        if let p = partyTimes[currentPartyTime]{
            let imageData = UIImagePNGRepresentation(image)
            let dic = [kMAIN_IMAGE: imageData!]
            let data = NSKeyedArchiver.archivedData(withRootObject: dic)
            do {
                try p.send(data, toPeers: [peer], with: .reliable)
                
            } catch {
                print("Could not send image")
            }
        }
    }
    
    func sendImage(_ image: UIImage, key: String, peer: MCPeerID?){
            if let p = partyTimes[currentPartyTime]{
                var imageData: Data!
                imageData = UIImagePNGRepresentation(image)
                
                let dic = [key: imageData!]
                let data = NSKeyedArchiver.archivedData(withRootObject: dic)
                do {
                    if let singlePeer = peer{
                        try p.send(data, toPeers: [singlePeer], with: .reliable)
                    }else{
                        var sendArray = [MCPeerID]()
                        for peer in self.peers{
                            sendArray.append(peer.id)
                        }
                        try p.send(data, toPeers: sendArray, with: .reliable)
                    }
                } catch {
                    print("Could not send image")
                }
            }
        
        
    }
    
    func partyTime(_ partyTime: PLPartyTime!, peer: MCPeerID!, changedState state: MCSessionState, currentPeers: [Any]!) {
            let p = Peer(id: peer, displayName: peer.displayName, state: state)
            if !peers.contains(p){
                if state != MCSessionState.notConnected{
                    self.peers.append(p)
                    print("Added peer: \(peer.displayName)")
                }
                
            }else{
                var index = 0
                for element in peers{
                    if element.id == peer{
                        if state == MCSessionState.notConnected{
                            print("Removed peer: \(peer.displayName)")
                            peers.remove(at: index)
                        }else{
                            element.updateState(state)
                        }
                        break
                    }
                    index += 1
                }
            }
            
            if state == MCSessionState.connected{
                self.sendProfileColor([peer])
                if let mainImage = self.lastMainDrawImage{
                    self.sendMainImageToPeer(mainImage, peer: peer)
                }
            }
            delegate?.peersChanged()
    }
    
    func partyTime(_ partyTime: PLPartyTime!, didReceive stream: InputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func partyTime(_ partyTime: PLPartyTime!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, with progress: Progress!) {
        
    }
    func partyTime(_ partyTime: PLPartyTime!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, at localURL: URL!, withError error: Error!) {
        
    }
    
}
