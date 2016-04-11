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
    
    @IBOutlet weak var statusImage: UIImageView!
    
    var id: String!
    var isHost: Bool!
    var row: Int!
    var state: MCSessionState!
    var isInGame: Bool!
    func setupConnectionCell(row: Int, profileImage: UIImage?, profileName: String, isHost: Bool, state: MCSessionState, isInGame: Bool){
        self.state = state
        self.row = row
        self.isHost = isHost
        self.isInGame = isInGame
        if let image = profileImage{
            self.profileButton.setImage(image, forState: .Normal)
        }
        self.profileName.text = profileName
        switch state{
        case MCSessionState.Connected:
            statusImage.image = UIImage(named: "added")
        case MCSessionState.Connecting:
            statusImage.image = UIImage(named: "TimeGlass")
        case MCSessionState.NotConnected:
            if isInGame{
                statusImage.image = UIImage(named: "disconnected")
            }else{
                if isHost{
                    statusImage.image = UIImage(named: "add")
                }else{
                    statusImage.image = UIImage(named: "disconnected")
                }
            }
        }
    }
    @IBAction func didPressProfile(sender: AnyObject) {
        if !isInGame{
            if self.isHost == true{
                (UIApplication.sharedApplication().delegate as! AppDelegate).mcManager.sendJoinRequest(row)
            }else{
                if state == MCSessionState.Connected || state == MCSessionState.Connecting{
                    (UIApplication.sharedApplication().delegate as! AppDelegate).mcManager.disconnectFromHost()
                }else{
                    (UIApplication.sharedApplication().delegate as! AppDelegate).mcManager.removePeer((UIApplication.sharedApplication().delegate as! AppDelegate).mcManager.peers[row].id)
                }
                
            }
        }
    }
}
