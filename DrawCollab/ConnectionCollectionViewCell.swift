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
    func setupConnectionCell(row: Int, profileImage: UIImage?, profileName: String, isHost: Bool, state: MCSessionState){
        self.state = state
        self.row = row
        self.isHost = isHost
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
            statusImage.image = UIImage(named: "add")
        default:
            statusImage.image = UIImage(named: "add")
        }
    }
    @IBAction func didPressProfile(sender: AnyObject) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).mcManager.sendJoinRequest(row)
    }
    
}
