//
//  ViewController.swift
//  DrawingTest
//
//  Created by Felix Hedlund on 04/04/16.
//  Copyright © 2016 Felix Hedlund. All rights reserved.
//

import UIKit
import MultipeerConnectivity
class DrawViewController: UIViewController, UIPopoverPresentationControllerDelegate, ColorPickerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, SearchForMultiPeerHostDelegate {
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
    
    
    
    var appDelegate: AppDelegate!
    var lastPoint: CGPoint?
    var lastBrushImagePoint: CGPoint?
    var mouseSwiped = false
    
    var red: CGFloat!
    var green: CGFloat!
    var blue: CGFloat!
    var opacity: CGFloat = 1.0
    var brushSize: Float = 10.0
    
    var brushImage = UIImage(named: "brush")
    
    var penButtonIsEnabled = true
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //appDelegate.mcManager.removeAllNonConnectedPeers()
        red = appDelegate.mcManager.redColor
        green = appDelegate.mcManager.greenColor
        blue = appDelegate.mcManager.blueColor
        let penImage = UIImage(named: "pencil")
        self.penButton.setImage(penImage!.maskWithColor(UIColor(red: red, green: green, blue: blue, alpha: opacity)), forState: .Normal)
        self.didPressPen(penButton)
        self.view.bringSubviewToFront(brushImageView)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
   

    override func viewWillAppear(animated: Bool) {
        appDelegate.mcManager.delegate = self
    }
    
    func peersChanged(){
        dispatch_async(dispatch_get_main_queue(),{
            self.collectionView.reloadData()
        })
        
        
        
    }
    
    func startGameWasReceived() {
        
    }
    func imageWasReceived(image: UIImage, peer: MCPeerID){
        dispatch_async(dispatch_get_main_queue(),{
            UIGraphicsBeginImageContext(self.mainImage.frame.size)
            self.mainImage.image?.drawInRect(CGRectMake(0, 0, self.background.frame.size.width, self.background.frame.size.height), blendMode: CGBlendMode.Normal, alpha: 1)
            image.drawInRect(CGRectMake(0, 0, self.background.frame.size.width, self.background.frame.size.height), blendMode: CGBlendMode.Normal, alpha: 1)
            self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext()
            self.drawImage.image = nil
            UIGraphicsEndImageContext()
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
        }else{
            brushImage = UIImage(named: "brush")
            //brushImageView.image = brushImage?.maskWithColor(UIColor(red: red, green: green, blue: blue, alpha: opacity))
        }
        
        brushImageViewWidth.constant = CGFloat(brushSize*1.2)
        brushImageView.alpha = CGFloat(opacity)
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
                }else{
                    CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Round)
                }
                
                CGContextSetLineWidth(UIGraphicsGetCurrentContext(), CGFloat(brushSize))
                if !penButtonIsEnabled{
                    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1, 1, 1, 1)
                }else{
                    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity)
                }
                CGContextSetBlendMode(UIGraphicsGetCurrentContext(), CGBlendMode.Normal)
                CGContextStrokePath(UIGraphicsGetCurrentContext())
                self.drawImage.image = UIGraphicsGetImageFromCurrentImageContext()
                if !penButtonIsEnabled{
                    self.drawImage.alpha = 1.0
                }else{
                    self.drawImage.alpha = opacity
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
                }else{
                    CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Round)
                }
                CGContextSetLineWidth(UIGraphicsGetCurrentContext(), CGFloat(brushSize))
                if !penButtonIsEnabled{
                    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1, 1, 1, 1)
                }else{
                    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity)
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
            CGContextSetAlpha(UIGraphicsGetCurrentContext(), opacity)
            self.drawImage.image?.drawInRect(CGRectMake(0, 0, self.background.frame.size.width, self.background.frame.size.height), blendMode: CGBlendMode.Normal, alpha: 1) //opacity
        }
        self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext()
        
        if let i = drawImage.image{
            self.appDelegate.mcManager.sendDrawImageToPeers(i)
        }
        
        self.drawImage.image = nil
        UIGraphicsEndImageContext()
        brushImageView.image = nil
        
    }
    @IBAction func didPressExit(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didPressPen(sender: AnyObject) {
        penButtonIsEnabled = true
        penMarker.backgroundColor = UIColor(white: 1, alpha: 0.50)
        erasorMarker.backgroundColor = UIColor(white: 1, alpha: 0.10)
        self.didPressColor()
//        penButton.enabled = false
//        erasorButton.enabled = true
    }
    
    @IBAction func didPressErasor(sender: AnyObject) {
        erasorMarker.backgroundColor = UIColor(white: 1, alpha: 0.50)
        penMarker.backgroundColor = UIColor(white: 1, alpha: 0.10)
        penButtonIsEnabled = false
//        penButton.enabled = true
//        erasorButton.enabled = false
    }
    
    @IBOutlet weak var toolbarStackView: UIStackView!
    
    func didPressColor() {
        // initialise color picker view controller
        let colorPickerVc = storyboard?.instantiateViewControllerWithIdentifier("sbColorPicker") as! ColorPickerViewController
        colorPickerVc.previousColor = UIColor(red: red, green: green, blue: blue, alpha: opacity)
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
            popoverController.sourceView = self.toolbarStackView
            
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
            self.red = CGFloat(rgb.red)
            self.green = CGFloat(rgb.green)
            self.blue = CGFloat(rgb.blue)
            self.opacity = rgb.alpha
            self.brushSize = Float(brushSize)
            // set preview background to selected color
            let penImage = UIImage(named: "pencil")
            self.penButton.setImage(penImage!.maskWithColor(selectedUIColor), forState: .Normal)
        }
        
        
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
    
    // MARK: Popover delegate functions
    // Override iPhone behavior that presents a popover as fullscreen.
    // i.e. now it shows same popover box within on iPhone & iPad
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // show popover box for iPhone and iPad both
        return UIModalPresentationStyle.None
    }
}

