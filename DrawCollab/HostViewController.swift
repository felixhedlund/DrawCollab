//
//  HostViewController.swift
//  DrawCollab
//
//  Created by Felix Hedlund on 08/04/16.
//  Copyright © 2016 Felix Hedlund. All rights reserved.
//

import UIKit
import MultipeerConnectivity
class HostViewController: UIViewController, SearchForMultiPeerHostDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var hostNameLabel: UILabel!
    @IBOutlet weak var hostProfilePicture: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var searchForPeersActivityIndicator: UIActivityIndicatorView!
    
    var name: String!
    var image: UIImage!
    var appDelegate: AppDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.setupHost()
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        appDelegate.mcManager.setupPeerAndSessionWithDisplayNameAndImage(name, imageData: imageData)
        searchForPeersActivityIndicator.startAnimating()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        appDelegate.mcManager.delegate = self
        appDelegate.mcManager.searchForPeers()
    }
    
    func setupWithHostNamePicture(name: String, image: UIImage){
        self.name = name
        self.image = image
    }
    
    private func setupHost(){
        hostNameLabel.text = name
        self.hostProfilePicture.image = image
    }
    
    @IBAction func didPressStartGame(sender: AnyObject) {
        appDelegate.mcManager.sendStartGameRequest()
        
        let drawController = UIStoryboard(name: "Draw", bundle: nil).instantiateViewControllerWithIdentifier("Draw") as! DrawViewController
        drawController.isHost = true
        self.presentViewController(drawController, animated: true, completion: nil)
        //self.navigationController?.pushViewController(drawController, animated: true)
        
    }
    func stringWasReceived(receivedString: NSString) {
        
    }
    
    func imageWasReceived(image: UIImage, peer: MCPeerID){
        let roundedImage = UIImage.roundedRectImageFromImage(image, imageSize: image.size, cornerRadius: image.size.width/2)
        appDelegate.mcManager.changePeerImage(roundedImage, peer: peer)
    }
    
    func peersChanged() {
        dispatch_async(dispatch_get_main_queue(),{
            
            if self.appDelegate.mcManager.peers.count > 0{
                self.infoLabel.text = "Press a profile to add friend..."
            }else{
                self.infoLabel.text = "Searching for nearby profiles..."
            }
            self.collectionView.reloadData()
            
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
        cell.setupConnectionCell(indexPath.row, profileImage: image, profileName: peer.displayName, isHost: true, state: peer.state, isInGame: false)
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
