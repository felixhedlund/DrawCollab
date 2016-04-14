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
    @IBOutlet weak var profileCircle: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var searchForPeersActivityIndicator: UIActivityIndicatorView!
    
    var name: String!
    var redColor: CGFloat!
    var greenColor: CGFloat!
    var blueColor: CGFloat!
    
    
    var appDelegate: AppDelegate!
    var hasChangedToBlack = false
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        
        appDelegate.mcManager.setupPeerAndSessionWithDisplayNameAndImage(name)
        searchForPeersActivityIndicator.startAnimating()
        //appDelegate.mcManager
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        appDelegate.mcManager.delegate = self
        self.setupHost()
        self.peersChanged()
    }
    
    func setupWithHostNameColor(name: String){
        self.name = name
    }
    
    private func setupHost(){
        hostNameLabel.text = name
        let color = UIColor(red: appDelegate.mcManager.redColor, green: appDelegate.mcManager.greenColor, blue: appDelegate.mcManager.blueColor, alpha: 1)
        self.profileCircle.image = profileCircle.image?.maskWithColor(color)
        checkBlack(color)
    }
    private func checkBlack(color: UIColor){
        let colors = CGColorGetComponents(color.CGColor)
        
        if colors[0] == 0.0 && colors[1] == 0.0 && colors[2] == 0.0 && !hasChangedToBlack{
            profileImage.image = profileImage.image?.maskWithColor(UIColor.whiteColor())
            hasChangedToBlack = true
        }else{
            if hasChangedToBlack{
                profileImage.image =  profileImage.image?.maskWithColor(UIColor.blackColor())
                hasChangedToBlack = false
            }
        }
    }
    
    @IBAction func didPressStartGame(sender: AnyObject) {
        appDelegate.mcManager.sendStartGameRequest()
        
        let drawController = UIStoryboard(name: "Draw", bundle: nil).instantiateViewControllerWithIdentifier("Draw") as! DrawViewController
        self.presentViewController(drawController, animated: true, completion: nil)
        //self.navigationController?.pushViewController(drawController, animated: true)
        
    }
    
    func imageWasReceived(image: UIImage, peer: Peer) {
        
    }
    
    func startGameWasReceived() {
        dispatch_async(dispatch_get_main_queue(),{
            let drawController = UIStoryboard(name: "Draw", bundle: nil).instantiateViewControllerWithIdentifier("Draw") as! DrawViewController
            self.presentViewController(drawController, animated: true, completion: nil)
        })
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
