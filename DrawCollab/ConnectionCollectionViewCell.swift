//
//  ConnectionCollectionViewCell.swift
//  DrawCollab
//
//  Created by Felix Hedlund on 08/04/16.
//  Copyright © 2016 Felix Hedlund. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ConnectionCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var statusImage: UIImageView!
    
    var delegate: UIViewController!
    
    var id: String!
    var row: Int!
    var state: MCSessionState!
    var isInGame: Bool!
    var hasSetProfileImage = false
    func setupConnectionCell(_ row: Int, profileColor: UIColor, profileName: String, state: MCSessionState, isInGame: Bool, delegate: UIViewController){
        self.delegate = delegate
        self.state = state
        self.row = row
        self.isInGame = isInGame
        if hasSetProfileImage{
            profileButton.imageView?.image = profileButton.imageView?.image?.maskWithColor(profileColor)
        }else{
            setProfileCircleWithColor(profileColor)
        }
        self.profileName.text = profileName
        switch state{
        case MCSessionState.connected:
            statusImage.image = UIImage(named: "added")
        case MCSessionState.connecting:
            statusImage.image = UIImage(named: "TimeGlass")
        case MCSessionState.notConnected:
            if isInGame{
                statusImage.image = UIImage(named: "disconnected")
            }else{
                statusImage.image = UIImage(named: "add")
            }
        }
        statusImage.isHidden = false
        checkBlack(profileColor)
        
    }
    
    func setupCurrentProfileCell(_ row: Int, profileColor: UIColor, profileName: String){
        
        
        self.row = row
        self.profileName.text = profileName
        if hasSetProfileImage{
            profileButton.setImage(profileButton.imageView!.image!.maskWithColor(profileColor), for: UIControlState())
        }else{
            setProfileCircleWithColor(profileColor)
        }
        statusImage.isHidden = true
        checkBlack(profileColor)
    }
    fileprivate func setProfileCircleWithColor(_ color: UIColor){
        var image = UIImage(named: "whiteCircle")
        image = image!.maskWithColor(color)
        profileButton.setImage(image, for: UIControlState())
        hasSetProfileImage = true
    }
    
    fileprivate func checkBlack(_ color: UIColor){
        let colors = color.cgColor.components
        
        if colors?[0] == 0.0 && colors?[1] == 0.0 && colors?[2] == 0.0{
            profileImage.image = profileImage.image?.maskWithColor(UIColor.white)
        }else{
            profileImage.image =  profileImage.image?.maskWithColor(UIColor.black)
        }
    }
    
    
    @IBAction func didPressProfile(_ sender: AnyObject) {
//        if !isInGame{
//            if state == MCSessionState.NotConnected{
//                (UIApplication.sharedApplication().delegate as! AppDelegate).mcManager.sendJoinRequest(row)
//            }else{
//                if state == MCSessionState.Connected || state == MCSessionState.Connecting{
//                    let alert = UIAlertController(title: "Disconnect Peer", message: "Are you sure you want to remove this peer?", preferredStyle: .Alert)
//                    let action = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
//                        alert.dismissViewControllerAnimated(true, completion: { () -> Void in
//                        })
//                    }
//                    let action2 = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (action) -> Void in
//                        (UIApplication.sharedApplication().delegate as! AppDelegate).mcManager.removePeer((UIApplication.sharedApplication().delegate as! AppDelegate).mcManager.peers[self.row].id)
//                        alert.dismissViewControllerAnimated(true, completion: nil)
//                    }
//                    alert.addAction(action)
//                    alert.addAction(action2)
//                    self.delegate.presentViewController(alert, animated: true, completion: nil)
//
//                }
//                
//            }
//        }
    }
}
