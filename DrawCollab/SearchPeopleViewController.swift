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
    
    @IBOutlet weak var canvas1WidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var canvas2WidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var canvas3WidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var canvas4WidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var profileWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var canvas1Marker: UIImageView!
    @IBOutlet weak var canvas2Marker: UIImageView!
    @IBOutlet weak var canvas3Marker: UIImageView!
    @IBOutlet weak var canvas4Marker: UIImageView!
    
    
    
    var name: String!
    var redColor: CGFloat!
    var greenColor: CGFloat!
    var blueColor: CGFloat!
    
    
    var appDelegate: AppDelegate!
    var hasChangedToBlack = false
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        UINavigationBar.appearance().tintColor = UIColor.white
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        
        appDelegate.mcManager.setupPeerAndSessionWithDisplayNameAndImage(name)
        appDelegate.mcManager.initializePartyTime()
        searchForPeersActivityIndicator.startAnimating()
        self.setCanvasConstraints()
        
        canvas2Marker.isHidden = true
        canvas3Marker.isHidden = true
        canvas4Marker.isHidden = true
    }
    
    @IBAction func didPressCanvas1(_ sender: AnyObject) {
        canvas2Marker.isHidden = true
        canvas3Marker.isHidden = true
        canvas4Marker.isHidden = true
        canvas1Marker.isHidden = false
        appDelegate.mcManager.disconnectFromParty()
        appDelegate.mcManager.peers.removeAll()
        self.collectionView.reloadData()
        appDelegate.mcManager.currentPartyTime = 0
        appDelegate.mcManager.serviceType = "1canvas1"
        appDelegate.mcManager.initializePartyTime()
        //appDelegate.mcManager.setupPeerAndSessionWithDisplayNameAndImage(name)
        
    }
    @IBAction func didPressCanvas2(_ sender: AnyObject) {
        canvas1Marker.isHidden = true
        canvas3Marker.isHidden = true
        canvas4Marker.isHidden = true
        canvas2Marker.isHidden = false
        appDelegate.mcManager.disconnectFromParty()
        appDelegate.mcManager.peers.removeAll()
        self.collectionView.reloadData()
        appDelegate.mcManager.currentPartyTime = 1
        appDelegate.mcManager.serviceType = "2canvas2"
        appDelegate.mcManager.initializePartyTime()
        //appDelegate.mcManager.setupPeerAndSessionWithDisplayNameAndImage(name)
    }
    @IBAction func didPressCanvas3(_ sender: AnyObject) {
        canvas2Marker.isHidden = true
        canvas1Marker.isHidden = true
        canvas4Marker.isHidden = true
        canvas3Marker.isHidden = false
        appDelegate.mcManager.disconnectFromParty()
        appDelegate.mcManager.peers.removeAll()
        self.collectionView.reloadData()
        appDelegate.mcManager.currentPartyTime = 2
        appDelegate.mcManager.serviceType = "3canvas3"
        appDelegate.mcManager.initializePartyTime()
        //appDelegate.mcManager.setupPeerAndSessionWithDisplayNameAndImage(name)
    }
    @IBAction func didPressCanvas4(_ sender: AnyObject) {
        canvas2Marker.isHidden = true
        canvas3Marker.isHidden = true
        canvas1Marker.isHidden = true
        canvas4Marker.isHidden = false
        appDelegate.mcManager.disconnectFromParty()
        appDelegate.mcManager.peers.removeAll()
        self.collectionView.reloadData()
        appDelegate.mcManager.currentPartyTime = 3
        appDelegate.mcManager.serviceType = "4canvas4"
        appDelegate.mcManager.initializePartyTime()
        //appDelegate.mcManager.setupPeerAndSessionWithDisplayNameAndImage(name)
    }
    
    fileprivate func setCanvasConstraints(){
        let size = appDelegate.sizes.canvasButtonWidth
        canvas1WidthConstraint.constant = size!
        canvas2WidthConstraint.constant = size!
        canvas3WidthConstraint.constant = size!
        canvas4WidthConstraint.constant = size!
        profileWidthConstraint.constant = appDelegate.sizes.welcomeButtonsWidth
        
    }
    override func viewWillAppear(_ animated: Bool) {
        appDelegate.mcManager.delegate = self
        self.setupHost()
        self.peersChanged()
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func rotated(){
        DispatchQueue.main.async(execute: {
            self.collectionView.reloadData()
        })
    }
    
    func setupWithHostNameColor(_ name: String){
        self.name = name
    }
    
    fileprivate func setupHost(){
        hostNameLabel.text = name
        let color = UIColor(red: appDelegate.mcManager.redColor, green: appDelegate.mcManager.greenColor, blue: appDelegate.mcManager.blueColor, alpha: 1)
        self.profileCircle.image = profileCircle.image?.maskWithColor(color)
        checkBlack(color)
    }
    fileprivate func checkBlack(_ color: UIColor){
        let colors = color.cgColor.components
        
        if colors?[0] == 0.0 && colors?[1] == 0.0 && colors?[2] == 0.0 && !hasChangedToBlack{
            profileImage.image = profileImage.image?.maskWithColor(UIColor.white)
            hasChangedToBlack = true
        }else{
            if hasChangedToBlack{
                profileImage.image =  profileImage.image?.maskWithColor(UIColor.black)
                hasChangedToBlack = false
            }
        }
    }
    
    @IBAction func didPressStartGame(_ sender: AnyObject) {
        appDelegate.mcManager.sendStartGameRequest()
        
        let drawController = UIStoryboard(name: "Draw", bundle: nil).instantiateViewController(withIdentifier: "Draw") as! DrawNavigationViewController
        self.present(drawController, animated: true, completion: nil)
        //self.navigationController?.pushViewController(drawController, animated: true)
        
    }
    
    func newMainImageWasReceived() {
        //
    }
    
    func imageWasReceived(_ image: UIImage, peer: Peer){
        if let mainImage = self.appDelegate.mcManager.lastMainDrawImage{
            DispatchQueue.main.async(execute: {
                UIGraphicsBeginImageContext(mainImage.size)
                mainImage.draw(in: CGRect(x: 0, y: 0, width: mainImage.size.width, height: mainImage.size.height), blendMode: CGBlendMode.normal, alpha: 1)
                image.draw(in: CGRect(x: 0, y: 0, width: mainImage.size.width, height: mainImage.size.height), blendMode: CGBlendMode.normal, alpha: CGFloat(peer.opacity))
                self.appDelegate.mcManager.lastMainDrawImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            })
        }
    }
    
    func startGameWasReceived() {
        DispatchQueue.main.async(execute: {
            let drawController = UIStoryboard(name: "Draw", bundle: nil).instantiateViewController(withIdentifier: "Draw") as! DrawNavigationViewController
            self.present(drawController, animated: true, completion: nil)
        })
    }
    
    
    func peersChanged() {
        DispatchQueue.main.async(execute: {
            
            if self.appDelegate.mcManager.peers.count > 0{
                
                self.infoLabel.text = NSLocalizedString("Press play to start drawing with friends...", comment: "")
            }else{
                self.infoLabel.text = NSLocalizedString("Searching for nearby friends...", comment: "")
            }
            self.collectionView.reloadData()
            
        })
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {

        return CGSize(width: appDelegate.sizes.canvasButtonWidth*1.5, height: appDelegate.sizes.canvasButtonWidth*1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.mcManager.peers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "connectionCell", for: indexPath) as! ConnectionCollectionViewCell
        let peer = appDelegate.mcManager.peers[(indexPath as NSIndexPath).row]
        let color = peer.color
        cell.setupConnectionCell(indexPath.row, profileColor: color!, profileName: peer.displayName, state: peer.state, isInGame: false, delegate: self)
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
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
