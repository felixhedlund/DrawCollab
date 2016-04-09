//
//  ConnectionCollectionViewCell.swift
//  DrawCollab
//
//  Created by Felix Hedlund on 08/04/16.
//  Copyright © 2016 Felix Hedlund. All rights reserved.
//

import UIKit

class ConnectionCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    var id: String!
    var isHost: Bool!
    var row: Int!
    func setupConnectionCell(row: Int, profileImage: UIImage?, profileName: String, isHost: Bool){
        self.row = row
        self.isHost = isHost
        if let image = profileImage{
            self.profileButton.setImage(image, forState: .Normal)
        }
        self.profileName.text = profileName
    }
    @IBAction func didPressProfile(sender: AnyObject) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).mcManager.sendJoinRequest(row)
    }
    
}
