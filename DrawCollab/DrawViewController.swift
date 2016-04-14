//
//  ViewController.swift
//  DrawingTest
//
//  Created by Felix Hedlund on 04/04/16.
//  Copyright © 2016 Felix Hedlund. All rights reserved.
//

import UIKit
import MultipeerConnectivity
class DrawViewController: UIViewController, UIPopoverPresentationControllerDelegate, ColorPickerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, SearchForMultiPeerHostDelegate, ErasorPickerDelegate, UICollectionViewDelegateFlowLayout {
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
    
    
    var appDelegate: AppDelegate!
    
    
    
    
    var lastPoint: CGPoint?
    
    
    
    var lastBrushImagePoint: CGPoint?
    var mouseSwiped = false
    

    var brushSize: Float = 20.0
    var erasorSize: Float = 30
    var brushImage = UIImage(named: "brush")
    
    var penButtonIsEnabled = true

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //appDelegate.mcManager.removeAllNonConnectedPeers()
        
        //self.collectionView.registerNib(UINib(nibName: "ConnectionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "connectionCell")
//        self.collectionView.delegate = self
//        self.collectionView.dataSource = self
        self.setNeedsStatusBarAppearanceUpdate()
        
        let penImage = UIImage(named: "pencil")
        self.penButton.setImage(penImage!.maskWithColor(UIColor(red: self.appDelegate.mcManager.redColor, green: appDelegate.mcManager.greenColor, blue: appDelegate.mcManager.blueColor, alpha: appDelegate.mcManager.opacity)), forState: .Normal)
        self.didPressPen(penButton)
        self.view.bringSubviewToFront(brushImageView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.rotated), name: UIDeviceOrientationDidChangeNotification, object: nil)

        if let image = self.appDelegate.mcManager.lastMainDrawImage{
            self.mainImage.image = image
        }
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func rotated()
    {
        
        dispatch_async(dispatch_get_main_queue(),{
            self.collectionView.reloadData()
        })
        
    }

    override func viewWillAppear(animated: Bool) {
        self.view.layoutSubviews()
        appDelegate.mcManager.delegate = self

    }
    
    override func viewWillDisappear(animated: Bool) {
        //self.appDelegate.mcManager.lastMainDrawImage = mainImage.image
    }
    
    func newMainImageWasReceived() {
        self.mainImage.image = self.appDelegate.mcManager.lastMainDrawImage
    }
    
    func peersChanged(){
        dispatch_async(dispatch_get_main_queue(),{
            self.collectionView.reloadData()
        })
        
        
        
    }
    
    func startGameWasReceived() {
        
    }
    func imageWasReceived(image: UIImage, peer: Peer){
        dispatch_async(dispatch_get_main_queue(),{
            UIGraphicsBeginImageContext(self.mainImage.frame.size)
            self.mainImage.image?.drawInRect(CGRectMake(0, 0, self.background.frame.size.width, self.background.frame.size.height), blendMode: CGBlendMode.Normal, alpha: 1)
            image.drawInRect(CGRectMake(0, 0, self.background.frame.size.width, self.background.frame.size.height), blendMode: CGBlendMode.Normal, alpha: CGFloat(peer.opacity))
            self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.appDelegate.mcManager.lastMainDrawImage = self.mainImage.image
        })
        
    }
    func stringWasReceived(receivedString: NSString){
        print("String was received inGame: \(receivedString)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setBrushImageViewPosition(){
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !penButtonIsEnabled{
            brushImage = UIImage(named: "square")
            brushImageView.image = brushImage
            brushImageViewWidth.constant = CGFloat(erasorSize*1.2)
        }else{
            brushImage = UIImage(named: "brush")
            brushImageViewWidth.constant = CGFloat(brushSize*1.2)
            //brushImageView.image = brushImage?.maskWithColor(UIColor(red: red, green: green, blue: blue, alpha: opacity))
        }
        
        
        brushImageView.alpha = CGFloat(appDelegate.mcManager.opacity)
        mouseSwiped = false
        let touch = touches.first
        lastPoint = touch?.locationInView(self.background)
        lastBrushImagePoint = touch?.locationInView(self.view)
        setBrushImageViewPosition()
    }
    
    
    
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        mouseSwiped = true
        if let touch = touches.first{
            if let last = lastPoint{
                let currentPoint = touch.locationInView(self.background)
                UIGraphicsBeginImageContext(self.background.frame.size)
                self.drawImage.image?.drawInRect(CGRect(x: 0, y: 0, width: self.background.frame.size.width, height: self.background.frame.size.height))
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), last.x, last.y)
                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y)
                if !penButtonIsEnabled{
                    CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Square)
                    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), CGFloat(erasorSize))
                }else{
                    CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Round)
                    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), CGFloat(brushSize))
                }
                
                
                if !penButtonIsEnabled{
                    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1, 1, 1, 1)
                }else{
                    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), appDelegate.mcManager.redColor, appDelegate.mcManager.greenColor, appDelegate.mcManager.blueColor, appDelegate.mcManager.opacity)
                }
                CGContextSetBlendMode(UIGraphicsGetCurrentContext(), CGBlendMode.Normal)
                CGContextStrokePath(UIGraphicsGetCurrentContext())
                self.drawImage.image = UIGraphicsGetImageFromCurrentImageContext()
                if !penButtonIsEnabled{
                    self.drawImage.alpha = 1.0
                }else{
                    self.drawImage.alpha = appDelegate.mcManager.opacity
                }
                UIGraphicsEndImageContext()
                lastPoint = currentPoint
                
                
                lastBrushImagePoint = touch.locationInView(self.view)
                setBrushImageViewPosition()
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let last = lastPoint{
            if !mouseSwiped{
                UIGraphicsBeginImageContext(self.background.frame.size)
                self.drawImage.image?.drawInRect(CGRect(x: 0, y: 0, width: self.background.frame.size.width, height: self.background.frame.size.height))
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), last.x, last.y)
                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), last.x, last.y)
                if !penButtonIsEnabled{
                    CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Square)
                    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), CGFloat(erasorSize))
                }else{
                    CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Round)
                    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), CGFloat(brushSize))
                }
                
                if !penButtonIsEnabled{
                    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1, 1, 1, 1)
                }else{
                    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), appDelegate.mcManager.redColor, appDelegate.mcManager.greenColor, appDelegate.mcManager.blueColor, appDelegate.mcManager.opacity)
                }
                CGContextSetBlendMode(UIGraphicsGetCurrentContext(), CGBlendMode.Normal)
                CGContextStrokePath(UIGraphicsGetCurrentContext())
                CGContextFlush(UIGraphicsGetCurrentContext())
                self.drawImage.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
        }
        UIGraphicsBeginImageContext(self.mainImage.frame.size)
        self.mainImage.image?.drawInRect(CGRectMake(0, 0, self.background.frame.size.width, self.background.frame.size.height), blendMode: CGBlendMode.Normal, alpha: 1)
        if !penButtonIsEnabled{
            self.drawImage.image?.drawInRect(CGRectMake(0, 0, self.background.frame.size.width, self.background.frame.size.height), blendMode: CGBlendMode.Normal, alpha: 1.0)
        }else{
            CGContextSetAlpha(UIGraphicsGetCurrentContext(), appDelegate.mcManager.opacity)
            self.drawImage.image?.drawInRect(CGRectMake(0, 0, self.background.frame.size.width, self.background.frame.size.height), blendMode: CGBlendMode.Normal, alpha: appDelegate.mcManager.opacity) //opacity
        }
        self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext()
        self.appDelegate.mcManager.lastMainDrawImage = self.mainImage.image
        
        if let i = drawImage.image{
            self.appDelegate.mcManager.sendDrawImageToPeers(i)
        }
        
        self.drawImage.image = nil
        UIGraphicsEndImageContext()
        brushImageView.image = nil
        
    }
    @IBAction func didPressExit(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didPressPen(sender: AnyObject) {
        penButtonIsEnabled = true
        penMarker.backgroundColor = UIColor(white: 1, alpha: 0.50)
        erasorMarker.backgroundColor = UIColor(white: 1, alpha: 0.10)
        self.didPressColor()
        
        if let connectedPeers = self.appDelegate.mcManager.partyTime?.connectedPeers as? [MCPeerID]{
            appDelegate.mcManager.sendProfileColor(connectedPeers)
        }
//        penButton.enabled = false
//        erasorButton.enabled = true
    }
    @IBAction func didPressPattern(sender: AnyObject) {
        let patternPicker = UIStoryboard(name: "Modals", bundle: nil).instantiateViewControllerWithIdentifier("pattern") as! PatternPickerViewController
        patternPicker.modalPresentationStyle = .Popover
        
        var maxSize: CGFloat = 0.0
        let screenRect = UIScreen.mainScreen().bounds
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
            popoverController.permittedArrowDirections = .Any
            popoverController.delegate = self
        }
        
        presentViewController(patternPicker, animated: true, completion: nil)
    }
    
    @IBAction func didPressErasor(sender: AnyObject) {
        if let connectedPeers = self.appDelegate.mcManager.partyTime?.connectedPeers as? [MCPeerID]{
            appDelegate.mcManager.sendErasor(connectedPeers)
        }
        
        
        erasorMarker.backgroundColor = UIColor(white: 1, alpha: 0.50)
        penMarker.backgroundColor = UIColor(white: 1, alpha: 0.10)
        penButtonIsEnabled = false
        
        
        let erasorPicker = UIStoryboard(name: "Modals", bundle: nil).instantiateViewControllerWithIdentifier("erasor") as! ErasorPickerViewController
        erasorPicker.previousSize = erasorSize
        erasorPicker.delegate = self
        erasorPicker.modalPresentationStyle = .Popover
        erasorPicker.preferredContentSize = CGSize(width: 265, height: 70)
        if let popoverController = erasorPicker.popoverPresentationController{
            popoverController.sourceView = self.erasorMarker
            popoverController.sourceRect = erasorButton.frame
            popoverController.permittedArrowDirections = .Any
            popoverController.delegate = self
        }
        
        presentViewController(erasorPicker, animated: true, completion: nil)
    }
    
    func erasorSizeWasPicked(erasorSize: Float) {
        self.erasorSize = erasorSize
    }
    
    @IBOutlet weak var toolbarStackView: UIStackView!
    
    func didPressColor() {
        // initialise color picker view controller
        let colorPickerVc = UIStoryboard(name: "Modals", bundle: nil).instantiateViewControllerWithIdentifier("sbColorPicker") as! ColorPickerViewController
            //storyboard?.instantiateViewControllerWithIdentifier("sbColorPicker") as! ColorPickerViewController
        colorPickerVc.previousColor = UIColor(red: appDelegate.mcManager.redColor, green: appDelegate.mcManager.greenColor, blue: appDelegate.mcManager.blueColor, alpha: appDelegate.mcManager.opacity)
        colorPickerVc.previousBrushSize = brushSize
        // set modal presentation style
        colorPickerVc.modalPresentationStyle = .Popover
        
        // set max. size
        colorPickerVc.preferredContentSize = CGSizeMake(265, 400)
        
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
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.Any
            
            // set popover delegate self
            popoverController.delegate = self
        }
        
        //show color popover
        presentViewController(colorPickerVc, animated: true, completion: nil)

    }
    
    
    // MARK: Color picker delegate functions
    // called by color picker after color selected.
    func colorPickerDidColorSelected(selectedUIColor selectedUIColor: UIColor, brushSize: CGFloat) {
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
            self.penButton.setImage(penImage!.maskWithColor(selectedUIColor), forState: .Normal)
            if let connectedPeers = self.appDelegate.mcManager.partyTime?.connectedPeers as? [MCPeerID]{
                appDelegate.mcManager.sendProfileColor(connectedPeers)
            }
            
            self.collectionView.reloadData()
        }
        
        
    }
    
    

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        print(collectionView.frame.size.height)
        var size: CGFloat = 0.0
        
        if self.view.frame.height < self.view.frame.width{
            size = collectionView.frame.size.width * 0.8
        }else{
            size = collectionView.frame.size.height * 0.8
        }
       return CGSize(width: size, height: size)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.mcManager.peers.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("connectionCell", forIndexPath: indexPath) as! ConnectionCollectionViewCell
        if indexPath.row == 0{
            var name = ""
            let userDefaults = NSUserDefaults.standardUserDefaults()
            if let n = userDefaults.stringForKey("HostName"){
                name = n
            }
            cell.setupCurrentProfileCell(indexPath.row, profileColor: UIColor(red: appDelegate.mcManager.redColor, green: appDelegate.mcManager.greenColor, blue: appDelegate.mcManager.blueColor, alpha: 1), profileName: name)
        }else{
            let peer = appDelegate.mcManager.peers[indexPath.row - 1]
            let color = peer.color
            cell.setupConnectionCell(indexPath.row, profileColor: color, profileName: peer.displayName, state: peer.state, isInGame: true, delegate: self)
        }
        
        return cell
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle{
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: Popover delegate functions
    // Override iPhone behavior that presents a popover as fullscreen.
    // i.e. now it shows same popover box within on iPhone & iPad
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // show popover box for iPhone and iPad both
        return UIModalPresentationStyle.None
    }
}

