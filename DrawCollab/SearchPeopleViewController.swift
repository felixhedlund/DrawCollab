//
//  HostViewController.swift
//  DrawCollab
//
//  Created by Felix Hedlund on 08/04/16.
//  Copyright © 2016 Felix Hedlund. All rights reserved.
//

import UIKit
import MultipeerConnectivity
class SearchPeopleViewController: UIViewController, SearchForMultiPeerHostDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var hostNameLabel: UILabel!
    @IBOutlet weak var hostProfilePicture: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var searchForPeersActivityIndicator: UIActivityIndicatorView!
    
    var name: String!
    var profileColor: UIColor!
    var redColor: CGFloat!
    var greenColor: CGFloat!
    var blueColor: CGFloat!
    
    
    var appDelegate: AppDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.setupHost()
        appDelegate.mcManager.setupPeerAndSessionWithDisplayNameAndImage(name)
        searchForPeersActivityIndicator.startAnimating()
        //appDelegate.mcManager
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        appDelegate.mcManager.delegate = self
        self.peersChanged()
    }
    
    func setupWithHostNameColor(name: String, color: UIColor){
        self.name = name
        self.profileColor = color
    }
    
    private func setupHost(){
        hostNameLabel.text = name
        self.hostProfilePicture.backgroundColor = profileColor
    }
    
    @IBAction func didPressStartGame(sender: AnyObject) {
        appDelegate.mcManager.sendStartGameRequest()
        
        let drawController = UIStoryboard(name: "Draw", bundle: nil).instantiateViewControllerWithIdentifier("Draw") as! DrawViewController
        self.presentViewController(drawController, animated: true, completion: nil)
        //self.navigationController?.pushViewController(drawController, animated: true)
        
    }
    
    func startGameWasReceived() {
        dispatch_async(dispatch_get_main_queue(),{
            let drawController = UIStoryboard(name: "Draw", bundle: nil).instantiateViewControllerWithIdentifier("Draw") as! DrawViewController
            self.presentViewController(drawController, animated: true, completion: nil)
        })
    }
    
    func imageWasReceived(image: UIImage, peer: MCPeerID){
    }
    
    func peersChanged() {
        dispatch_async(dispatch_get_main_queue(),{
            
            if self.appDelegate.mcManager.peers.count > 0{
                self.infoLabel.text = "Press play to start drawing with friends..."
            }else{
                self.infoLabel.text = "Searching for nearby friends..."
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
        let color = peer.color
        cell.setupConnectionCell(indexPath.row, profileColor: color, profileName: peer.displayName, state: peer.state, isInGame: false, delegate: self)
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
