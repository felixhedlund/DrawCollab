//
//  JoinViewController.swift
//  DrawCollab
//
//  Created by Felix Hedlund on 08/04/16.
//  Copyright © 2016 Felix Hedlund. All rights reserved.
//

import UIKit
import MultipeerConnectivity
class JoinViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var waitingForHostLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchingForHostsActivityIndicator: UIActivityIndicatorView!
    
    var name: String!
    var image: UIImage!
    var appDelegate: AppDelegate!
    var browser: MCNearbyServiceBrowser!
    override func viewDidLoad() {
        super.viewDidLoad()
        //appDelegate.mcManager.joinDelegate = self
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        navigationController?.setNavigationBarHidden(false, animated: true)
        profileName.text = name
        self.profileImageView.image = image
        waitingForHostLabel.hidden = false
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var imageString: String? = nil
        let imageData = UIImageJPEGRepresentation(image, 1)
        imageString = imageData?.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
        appDelegate.mcManager.setupPeerAndSessionWithDisplayNameAndImage(name, imageStringEncoded: imageString)
        
        appDelegate.mcManager.advertiseSelf(true)
        searchingForHostsActivityIndicator.startAnimating()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    func setupWithProfileNamePicture(name: String, image: UIImage){
        self.name = name
        self.image = image
    }
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
        //return appDelegate.mcManager.peers.count
    }
    
    
    //TODO
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("connectionCell", forIndexPath: indexPath) as! ConnectionCollectionViewCell
        let peer = appDelegate.mcManager.peers[indexPath.row]
        var image = UIImage(named: "profile")
        if let i = peer.image{
            image = i
        }
        //cell.setupConnectionCell(image, profileName: peer.displayName, isHost: true)
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
