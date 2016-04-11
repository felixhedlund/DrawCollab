//
//  JoinViewController.swift
//  DrawCollab
//
//  Created by Felix Hedlund on 08/04/16.
//  Copyright © 2016 Felix Hedlund. All rights reserved.
//

import UIKit
import MultipeerConnectivity
class JoinViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SearchForMultiPeerHostDelegate {

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
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        appDelegate.mcManager.setupPeerAndSessionWithDisplayNameAndImage(name, imageData: imageData)
        searchingForHostsActivityIndicator.startAnimating()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        appDelegate.mcManager.delegate = self
        appDelegate.mcManager.advertiseSelf(true)
    }
    
    func stringWasReceived(receivedString: NSString) {
        if receivedString == "StartGame"{
            let drawController = UIStoryboard(name: "Draw", bundle: nil).instantiateViewControllerWithIdentifier("Draw") as! DrawViewController
            drawController.isHost = false
            self.presentViewController(drawController, animated: true, completion: nil)
        }
    }
    
    func setupWithProfileNamePicture(name: String, image: UIImage){
        self.name = name
        self.image = image
    }
    
    func imageWasReceived(image: UIImage, peer: MCPeerID){
        let roundedImage = UIImage.roundedRectImageFromImage(image, imageSize: image.size, cornerRadius: image.size.width/2)
        appDelegate.mcManager.changePeerImage(roundedImage, peer: peer)
    }
    
    func peersChanged() {
        dispatch_async(dispatch_get_main_queue(),{
            self.collectionView.reloadData()
            var foundConnectedHost = false
            for peer in self.appDelegate.mcManager.peers{
                if peer.state == MCSessionState.Connected{
                    foundConnectedHost = true
                    break
                }
            }
            if foundConnectedHost == true{
                self.waitingForHostLabel.hidden = false
                self.infoLabel.hidden = true
                self.searchingForHostsActivityIndicator.stopAnimating()
            }else{
                self.infoLabel.hidden = false
                self.waitingForHostLabel.hidden = true
                self.searchingForHostsActivityIndicator.startAnimating()
            }
        })
    }
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.mcManager.peers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("connectionCell", forIndexPath: indexPath) as! ConnectionCollectionViewCell
        let peer = appDelegate.mcManager.peers[indexPath.row]
        var image = UIImage(named: "profile")
        if let i = peer.image{
            image = i
        }
        cell.setupConnectionCell(indexPath.row, profileImage: image, profileName: peer.displayName, isHost: false, state: peer.state, isInGame: false)
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
