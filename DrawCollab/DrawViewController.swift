//
//  ViewController.swift
//  DrawingTest
//
//  Created by Felix Hedlund on 04/04/16.
//  Copyright © 2016 Felix Hedlund. All rights reserved.
//

import UIKit
import MultipeerConnectivity
class DrawViewController: UIViewController, UIPopoverPresentationControllerDelegate, ColorPickerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, SearchForMultiPeerHostDelegate, ErasorPickerDelegate, UICollectionViewDelegateFlowLayout, PatternPickerDelegate {
    @IBOutlet weak var penButton: UIButton!
    @IBOutlet weak var erasorButton: UIButton!
    //@IBOutlet weak var colorButton: UIBarButtonItem!
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var drawImage: UIImageView!
    
    @IBOutlet weak var brushImageView: UIImageView!
    @IBOutlet weak var brushImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var brushLeading: NSLayoutConstraint!
    @IBOutlet weak var brushTop: NSLayoutConstraint!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var penMarker: UIView!
    @IBOutlet weak var erasorMarker: UIView!
    
    @IBOutlet weak var patternMarker: UIView!
    @IBOutlet weak var patternButton: UIButton!
    @IBOutlet weak var patternButtonImage: UIImageView!
    
    @IBOutlet weak var patternImage: UIImageView!
    @IBOutlet weak var toolbarButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var exitMarker: UIView!
    
    
    
    var appDelegate: AppDelegate!
    var lastPoint: CGPoint?
    var path = UIBezierPath()
    var pts: [CGPoint] = [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 0),CGPoint(x: 0, y: 0),CGPoint(x: 0, y: 0),CGPoint(x: 0, y: 0)]
    var ctr = 0
    var lastBrushImagePoint: CGPoint?
    var mouseSwiped = false
    var brushSize: Float = 20.0
    var erasorSize: Float = 30
    var brushImage = UIImage(named: "brush")
    
    var penButtonIsEnabled = true

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate

        self.setNeedsStatusBarAppearanceUpdate()
        
        let penImage = UIImage(named: "pencil")
        self.penButton.setImage(penImage!.maskWithColor(UIColor(red: self.appDelegate.mcManager.redColor, green: appDelegate.mcManager.greenColor, blue: appDelegate.mcManager.blueColor, alpha: appDelegate.mcManager.opacity)), for: UIControlState())
        //self.didPressPen(penButton)
        penButtonIsEnabled = true
        penMarker.backgroundColor = UIColor(white: 1, alpha: 0.50)
        erasorMarker.backgroundColor = UIColor(white: 1, alpha: 0.10)
        
        
        setPatternImage()
        
        self.view.bringSubview(toFront: brushImageView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

        if let image = self.appDelegate.mcManager.lastMainDrawImage{
            self.mainImage.image = image
        }
        
        toolbarButtonWidthConstraint.constant = appDelegate.sizes.toolbarButtonSize
        patternMarker.layer.cornerRadius = appDelegate.sizes.toolbarButtonSize/2
        erasorMarker.layer.cornerRadius = appDelegate.sizes.toolbarButtonSize/2
        penMarker.layer.cornerRadius = appDelegate.sizes.toolbarButtonSize/2
        exitMarker.layer.cornerRadius = appDelegate.sizes.toolbarButtonSize/2
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func rotated()
    {
        
        DispatchQueue.main.async(execute: {
            self.collectionView.reloadData()
        })
        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.view.layoutSubviews()
        appDelegate.mcManager.delegate = self

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.appDelegate.mcManager.lastMainDrawImage = mainImage.image
    }
    
    func didChangePattern() {
        self.setPatternImage()
        if let connectedPeers = self.appDelegate.mcManager.partyTimes[appDelegate.mcManager.currentPartyTime]?.connectedPeers as? [MCPeerID]{
            appDelegate.mcManager.sendProfileColor(connectedPeers)
        }
    }
    
    func setPatternImage(){
        if appDelegate.mcManager.patternNumber == 0{
            patternImage.isHidden = true
            patternButtonImage.isHidden = true
        }else{
            switch appDelegate.mcManager.patternNumber{
            case 1:
                patternImage.image = UIImage(named: patternImages[0])
                patternButtonImage.image = UIImage(named: patternButtonImages[0])
            case 2:
                patternImage.image = UIImage(named: patternImages[1])
                patternButtonImage.image = UIImage(named: patternButtonImages[1])
            default:
                patternImage.image = UIImage(named: patternImages[0])
                patternButtonImage.image = UIImage(named: patternButtonImages[0])
            }
            patternImage.isHidden = false
            patternButtonImage.isHidden = false
        }
    }
    
    func newMainImageWasReceived() {
        self.mainImage.image = self.appDelegate.mcManager.lastMainDrawImage
    }
    
    func peersChanged(){
        setPatternImage()
        DispatchQueue.main.async(execute: {
            self.collectionView.reloadData()
        })
        
        
        
    }
    
    func startGameWasReceived() {
        
    }
    func imageWasReceived(_ image: UIImage, peer: Peer){
        DispatchQueue.main.async(execute: {
            UIGraphicsBeginImageContext(self.mainImage.frame.size)
            self.mainImage.image?.draw(in: CGRect(x: 0, y: 0, width: self.background.frame.size.width, height: self.background.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1)
            image.draw(in: CGRect(x: 0, y: 0, width: self.background.frame.size.width, height: self.background.frame.size.height), blendMode: CGBlendMode.normal, alpha: CGFloat(peer.opacity))
            self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.appDelegate.mcManager.lastMainDrawImage = self.mainImage.image
        })
        
    }
    func stringWasReceived(_ receivedString: NSString){
        print("String was received inGame: \(receivedString)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setBrushImageViewPosition(){
        if let point = lastBrushImagePoint{
            //brushImageView.center = point
            brushLeading.constant = -20 + point.x - brushImageView.frame.size.width/2
            
            if self.view.frame.width > self.view.frame.height{
                brushTop.constant = point.y - brushImageView.frame.size.width/2
            }else{
                brushTop.constant = -20 + point.y - brushImageView.frame.size.width/2 //- 44
            }
            
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !penButtonIsEnabled{
            brushImage = UIImage(named: "square")
            brushImageView.image = brushImage
            brushImageViewWidth.constant = CGFloat(erasorSize*1.2)
            drawImage.alpha = 1.0
        }else{
            brushImage = UIImage(named: "brush")
            brushImageViewWidth.constant = CGFloat(brushSize*1.2)
            drawImage.alpha = appDelegate.mcManager.opacity
            //brushImageView.image = brushImage?.maskWithColor(UIColor(red: red, green: green, blue: blue, alpha: opacity))
        }
        
        
        brushImageView.alpha = CGFloat(appDelegate.mcManager.opacity)
        mouseSwiped = false
        let touch = touches.first
        lastPoint = touch?.location(in: self.background)
        pts[0] = lastPoint!
        lastBrushImagePoint = touch?.location(in: self.view)
        setBrushImageViewPosition()
    }
    
    
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if penButtonIsEnabled{
            self.movePencil(touches, withEvent: event)
        }else{
            self.moveErasor(touches, withEvent: event)
        }
    }
    
    fileprivate func movePencil(_ touches: Set<UITouch>, withEvent event: UIEvent?){
        mouseSwiped = true
        if let touch = touches.first{
            ctr += 1
            pts[ctr] = touch.location(in: self.background)
            lastPoint = pts[ctr]
            if ctr == 4{
                //let currentPoint = touch.locationInView(self.background)
                UIGraphicsBeginImageContext(self.background.frame.size)
                self.drawImage.image?.draw(in: CGRect(x: 0, y: 0, width: self.background.frame.size.width, height: self.background.frame.size.height))
                
                pts[3] = CGPoint(x: (pts[2].x + pts[4].x)/2.0, y: (pts[2].y + pts[4].y)/2.0)
                
                let currentContext = UIGraphicsGetCurrentContext()
                
                currentContext?.move(to: CGPoint(x: pts[0].x, y: pts[0].y))
                
                currentContext?.addCurve(to: CGPoint(x: pts[3].x, y: pts[3].y), control1: CGPoint(x: pts[1].x, y: pts[1].y), control2: CGPoint(x: pts[2].x, y: pts[2].y))
//                CGContextAddCurveToPoint(UIGraphicsGetCurrentContext(), pts[1].x, pts[1].y, pts[2].x, pts[2].y, pts[3].x, pts[3].y)
                //CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y)
                if !penButtonIsEnabled{
                    currentContext?.setLineCap(CGLineCap.square)
                    currentContext?.setLineWidth(CGFloat(erasorSize))
                }else{
                    currentContext?.setLineCap(CGLineCap.round)
                    currentContext?.setLineWidth(CGFloat(brushSize))
                }
                
                
                if !penButtonIsEnabled{
                    currentContext?.setStrokeColor(red: 1, green: 1, blue: 1, alpha: 1)
                }else{
                    currentContext?.setStrokeColor(red: appDelegate.mcManager.redColor, green: appDelegate.mcManager.greenColor, blue: appDelegate.mcManager.blueColor, alpha: 1)
                }
                currentContext?.setBlendMode(CGBlendMode.normal)
                currentContext?.strokePath()
                self.drawImage.image = UIGraphicsGetImageFromCurrentImageContext()
                if !penButtonIsEnabled{
                    self.drawImage.alpha = 1.0
                }else{
                    self.drawImage.alpha = appDelegate.mcManager.opacity
                }
                UIGraphicsEndImageContext()
                
                pts[0] = pts[3]
                pts[1] = pts[4]
                ctr = 1
                
                lastBrushImagePoint = touch.location(in: self.view)
                setBrushImageViewPosition()
            }
        }
    }
    
    fileprivate func moveErasor(_ touches: Set<UITouch>, withEvent event: UIEvent?){
        mouseSwiped = true
        if let touch = touches.first{
            if let last = lastPoint{
                let currentPoint = touch.location(in: self.background)
                UIGraphicsBeginImageContext(self.background.frame.size)
                self.drawImage.image?.draw(in: CGRect(x: 0, y: 0, width: self.background.frame.size.width, height: self.background.frame.size.height))
                
                UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: last.x, y: last.y))
                UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: currentPoint.x, y: currentPoint.y))
                if !penButtonIsEnabled{
                    UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.square)
                    UIGraphicsGetCurrentContext()?.setLineWidth(CGFloat(erasorSize))
                }else{
                    UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.round)
                    UIGraphicsGetCurrentContext()?.setLineWidth(CGFloat(brushSize))
                }
                
                
                if !penButtonIsEnabled{
                    UIGraphicsGetCurrentContext()?.setStrokeColor(red: 1, green: 1, blue: 1, alpha: 1)
                }else{
                    UIGraphicsGetCurrentContext()?.setStrokeColor(red: appDelegate.mcManager.redColor, green: appDelegate.mcManager.greenColor, blue: appDelegate.mcManager.blueColor, alpha: 1)
                }
                UIGraphicsGetCurrentContext()?.setBlendMode(CGBlendMode.normal)
                UIGraphicsGetCurrentContext()?.strokePath()
                self.drawImage.image = UIGraphicsGetImageFromCurrentImageContext()
                if !penButtonIsEnabled{
                    self.drawImage.alpha = 1.0
                }else{
                    self.drawImage.alpha = appDelegate.mcManager.opacity
                }
                UIGraphicsEndImageContext()
                
                lastBrushImagePoint = touch.location(in: self.view)
                setBrushImageViewPosition()
                lastPoint = currentPoint
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let last = lastPoint{
            if !mouseSwiped{
                UIGraphicsBeginImageContext(self.background.frame.size)
                self.drawImage.image?.draw(in: CGRect(x: 0, y: 0, width: self.background.frame.size.width, height: self.background.frame.size.height))
                UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: last.x, y: last.y))
                UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: last.x, y: last.y))
                if !penButtonIsEnabled{
                    UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.square)
                    UIGraphicsGetCurrentContext()?.setLineWidth(CGFloat(erasorSize))
                }else{
                    UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.round)
                    UIGraphicsGetCurrentContext()?.setLineWidth(CGFloat(brushSize))
                }
                
                if !penButtonIsEnabled{
                    UIGraphicsGetCurrentContext()?.setStrokeColor(red: 1, green: 1, blue: 1, alpha: 1)
                }else{
                    UIGraphicsGetCurrentContext()?.setStrokeColor(red: appDelegate.mcManager.redColor, green: appDelegate.mcManager.greenColor, blue: appDelegate.mcManager.blueColor, alpha: appDelegate.mcManager.opacity)
                }
                UIGraphicsGetCurrentContext()?.setBlendMode(CGBlendMode.normal)
                UIGraphicsGetCurrentContext()?.strokePath()
                UIGraphicsGetCurrentContext()?.flush()
                self.drawImage.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
        }
        UIGraphicsBeginImageContext(self.mainImage.frame.size)
        self.mainImage.image?.draw(in: CGRect(x: 0, y: 0, width: self.background.frame.size.width, height: self.background.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1)
        if !penButtonIsEnabled{
            self.drawImage.image?.draw(in: CGRect(x: 0, y: 0, width: self.background.frame.size.width, height: self.background.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
        }else{
            UIGraphicsGetCurrentContext()?.setAlpha(appDelegate.mcManager.opacity)
            self.drawImage.image?.draw(in: CGRect(x: 0, y: 0, width: self.background.frame.size.width, height: self.background.frame.size.height), blendMode: CGBlendMode.normal, alpha: appDelegate.mcManager.opacity) //opacity
        }
        self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext()
        self.appDelegate.mcManager.lastMainDrawImage = self.mainImage.image
        
        if let i = drawImage.image{
            self.appDelegate.mcManager.sendDrawImageToPeers(i)
        }
        
        self.drawImage.image = nil
        UIGraphicsEndImageContext()
        brushImageView.image = nil
        
        self.path.removeAllPoints()
        ctr = 0
        
    }
    @IBAction func didPressExit(_ sender: AnyObject) {
        NotificationCenter.default.removeObserver(self)
        self.navigationController?.dismiss(animated: true, completion: nil)
        //self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didPressPen(_ sender: AnyObject) {
        penButtonIsEnabled = true
        penMarker.backgroundColor = UIColor(white: 1, alpha: 0.50)
        erasorMarker.backgroundColor = UIColor(white: 1, alpha: 0.10)
        self.didPressColor()
        
        if let connectedPeers = self.appDelegate.mcManager.partyTimes[appDelegate.mcManager.currentPartyTime]?.connectedPeers as? [MCPeerID]{
            appDelegate.mcManager.sendProfileColor(connectedPeers)
        }
        path.lineWidth = CGFloat(brushSize)
//        penButton.enabled = false
//        erasorButton.enabled = true
    }
    @IBAction func didPressPattern(_ sender: AnyObject) {
        let patternPicker = UIStoryboard(name: "Modals", bundle: nil).instantiateViewController(withIdentifier: "pattern") as! PatternPickerViewController
        patternPicker.modalPresentationStyle = .popover
        patternPicker.delegate = self
        var maxSize: CGFloat = 0.0
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        if screenWidth < screenHeight{
            maxSize = screenWidth
        }else{
            maxSize = screenHeight
        }
        
        patternPicker.preferredContentSize = CGSize(width: maxSize, height: 70)
        if let popoverController = patternPicker.popoverPresentationController{
            popoverController.sourceView = self.patternMarker
            popoverController.sourceRect = patternButton.frame
            popoverController.permittedArrowDirections = [.down, .right]
            popoverController.delegate = self
        }
        
        present(patternPicker, animated: true, completion: nil)
    }
    
    @IBAction func didPressErasor(_ sender: AnyObject) {
        if let connectedPeers = self.appDelegate.mcManager.partyTimes[appDelegate.mcManager.currentPartyTime]?.connectedPeers as? [MCPeerID]{
            appDelegate.mcManager.sendErasor(connectedPeers)
        }
        
        
        erasorMarker.backgroundColor = UIColor(white: 1, alpha: 0.50)
        penMarker.backgroundColor = UIColor(white: 1, alpha: 0.10)
        penButtonIsEnabled = false
        
        
        let erasorPicker = UIStoryboard(name: "Modals", bundle: nil).instantiateViewController(withIdentifier: "erasor") as! ErasorPickerViewController
        erasorPicker.previousSize = erasorSize
        erasorPicker.delegate = self
        erasorPicker.modalPresentationStyle = .popover
        erasorPicker.preferredContentSize = CGSize(width: 265, height: 70)
        if let popoverController = erasorPicker.popoverPresentationController{
            popoverController.sourceView = self.erasorMarker
            popoverController.sourceRect = erasorButton.frame
            popoverController.permittedArrowDirections = .any
            popoverController.delegate = self
        }
        path.lineWidth = CGFloat(erasorSize)
        present(erasorPicker, animated: true, completion: nil)
    }
    
    func erasorSizeWasPicked(_ erasorSize: Float) {
        self.erasorSize = erasorSize
        path.lineWidth = CGFloat(erasorSize)
    }
    
    @IBOutlet weak var toolbarStackView: UIStackView!
    
    func didPressColor() {
        // initialise color picker view controller
        let colorPickerVc = UIStoryboard(name: "Modals", bundle: nil).instantiateViewController(withIdentifier: "sbColorPicker") as! ColorPickerViewController
            //storyboard?.instantiateViewControllerWithIdentifier("sbColorPicker") as! ColorPickerViewController
        colorPickerVc.previousColor = UIColor(red: appDelegate.mcManager.redColor, green: appDelegate.mcManager.greenColor, blue: appDelegate.mcManager.blueColor, alpha: appDelegate.mcManager.opacity)
        colorPickerVc.previousBrushSize = brushSize
        // set modal presentation style
        colorPickerVc.modalPresentationStyle = .popover
        
        // set max. size
        colorPickerVc.preferredContentSize = CGSize(width: 265, height: 400)
        
        // set color picker deleagate to current view controller
        // must write delegate method to handle selected color
        colorPickerVc.colorPickerDelegate = self
        
        // show popover
        if let popoverController = colorPickerVc.popoverPresentationController {
            
            // set source view
            popoverController.sourceView = self.penMarker
            
            // show popover form button
            popoverController.sourceRect = self.penButton.frame
            
            // show popover arrow at feasible direction
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.any
            
            // set popover delegate self
            popoverController.delegate = self
        }
        
        //show color popover
        present(colorPickerVc, animated: true, completion: nil)

    }
    
    
    // MARK: Color picker delegate functions
    // called by color picker after color selected.
    func colorPickerDidColorSelected(selectedUIColor: UIColor, brushSize: CGFloat) {
        // update color value within class variable
        if let rgb = selectedUIColor.rgb(){
            print("red: \(rgb.red)")
            print("green: \(rgb.green)")
            print("blue: \(rgb.blue)")
            self.appDelegate.mcManager.redColor = CGFloat(rgb.red)
            self.appDelegate.mcManager.greenColor = CGFloat(rgb.green)
            self.appDelegate.mcManager.blueColor = CGFloat(rgb.blue)
            self.appDelegate.mcManager.opacity = rgb.alpha
            self.brushSize = Float(brushSize)
            // set preview background to selected color
            let penImage = UIImage(named: "pencil")
            self.penButton.setImage(penImage!.maskWithColor(selectedUIColor), for: UIControlState())
            if let connectedPeers = self.appDelegate.mcManager.partyTimes[appDelegate.mcManager.currentPartyTime]?.connectedPeers as? [MCPeerID]{
                appDelegate.mcManager.sendProfileColor(connectedPeers)
            }
            path.lineWidth = CGFloat(brushSize)
            self.collectionView.reloadData()
        }
        
        
    }
    
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(collectionView.frame.size.height)
        var size: CGFloat = 0.0
        
        if self.view.frame.height < self.view.frame.width{
            size = collectionView.frame.size.width * 0.8
        }else{
            size = collectionView.frame.size.height * 0.8
        }
       return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.mcManager.peers.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "connectionCell", for: indexPath) as! ConnectionCollectionViewCell
        if (indexPath as NSIndexPath).row == 0{
            var name = ""
            let userDefaults = UserDefaults.standard
            if let n = userDefaults.string(forKey: "HostName"){
                name = n
            }
            cell.setupCurrentProfileCell((indexPath as NSIndexPath).row, profileColor: UIColor(red: appDelegate.mcManager.redColor, green: appDelegate.mcManager.greenColor, blue: appDelegate.mcManager.blueColor, alpha: 1), profileName: name)
        }else{
            let peer = appDelegate.mcManager.peers[(indexPath as NSIndexPath).row - 1]
            let color = peer.color
            cell.setupConnectionCell(indexPath.row, profileColor: color!, profileName: peer.displayName, state: peer.state, isInGame: true, delegate: self)
        }
        
        return cell
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
    // MARK: Popover delegate functions
    // Override iPhone behavior that presents a popover as fullscreen.
    // i.e. now it shows same popover box within on iPhone & iPad
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // show popover box for iPhone and iPad both
        return UIModalPresentationStyle.none
    }
}

