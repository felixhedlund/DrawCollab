//
//  ViewController.swift
//  DrawingTest
//
//  Created by Felix Hedlund on 04/04/16.
//  Copyright © 2016 Felix Hedlund. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate, ColorPickerDelegate {
    @IBOutlet weak var penButton: UIBarButtonItem!
    @IBOutlet weak var erasorButton: UIBarButtonItem!
    @IBOutlet weak var colorButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var drawImage: UIImageView!
    
    @IBOutlet weak var brushImageView: UIImageView!
    @IBOutlet weak var brushImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var brushLeading: NSLayoutConstraint!
    @IBOutlet weak var brushTop: NSLayoutConstraint!
    var lastPoint: CGPoint?
    var lastBrushImagePoint: CGPoint?
    var mouseSwiped = false
    
    var red: CGFloat!
    var green: CGFloat!
    var blue: CGFloat!
    var opacity: CGFloat = 1.0
    var brushSize: Float = 10.0
    
    var brushImage = UIImage(named: "brush")
    override func viewDidLoad() {
        super.viewDidLoad()
        red = 20/255
        green = 100/255
        blue = 150/255
        self.colorButton.tintColor = UIColor(red: red, green: green, blue: blue, alpha: opacity)
        self.didPressPen(penButton)
        self.view.bringSubviewToFront(brushImageView)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !erasorButton.enabled{
            brushImage = UIImage(named: "square")
            brushImageView.image = brushImage
        }else{
            brushImage = UIImage(named: "brush")
            brushImageView.image = brushImage?.maskWithColor(UIColor(red: red, green: green, blue: blue, alpha: 1.0))
        }
        
        brushImageViewWidth.constant = CGFloat(brushSize*1.2)
        brushImageView.alpha = CGFloat(opacity)
        mouseSwiped = false
        let touch = touches.first
        lastPoint = touch?.locationInView(self.background)
        lastBrushImagePoint = touch?.locationInView(self.view)
        setBrushImageViewPosition()
    }
    
    private func setBrushImageViewPosition(){
        if let point = lastBrushImagePoint{
            //brushImageView.center = point
            brushLeading.constant = -20 + point.x - brushImageView.frame.size.width/2
            brushTop.constant = -20 + point.y - brushImageView.frame.size.width/2
        }
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
                if !erasorButton.enabled{
                    CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Square)
                }else{
                    CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Round)
                }
                
                CGContextSetLineWidth(UIGraphicsGetCurrentContext(), CGFloat(brushSize))
                if !erasorButton.enabled{
                    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1, 1, 1, 1)
                }else{
                    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1)
                }
                CGContextSetBlendMode(UIGraphicsGetCurrentContext(), CGBlendMode.Normal)
                CGContextStrokePath(UIGraphicsGetCurrentContext())
                self.drawImage.image = UIGraphicsGetImageFromCurrentImageContext()
                if !erasorButton.enabled{
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
                if !erasorButton.enabled{
                    CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Square)
                }else{
                    CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Round)
                }
                CGContextSetLineWidth(UIGraphicsGetCurrentContext(), CGFloat(brushSize))
                if !erasorButton.enabled{
                    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1, 1, 1, 1)
                }else{
                    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1)
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
        if !erasorButton.enabled{
            self.drawImage.image?.drawInRect(CGRectMake(0, 0, self.background.frame.size.width, self.background.frame.size.height), blendMode: CGBlendMode.Normal, alpha: 1.0)
        }else{
            self.drawImage.image?.drawInRect(CGRectMake(0, 0, self.background.frame.size.width, self.background.frame.size.height), blendMode: CGBlendMode.Normal, alpha: opacity)
        }
        self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext()
        self.drawImage.image = nil
        UIGraphicsEndImageContext()
        brushImageView.image = nil
        
    }
    
    @IBAction func didPressPen(sender: AnyObject) {
        penButton.enabled = false
        erasorButton.enabled = true
    }
    
    @IBAction func didPressErasor(sender: AnyObject) {
        penButton.enabled = true
        erasorButton.enabled = false
    }
    @IBAction func didPressColor(sender: AnyObject) {
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
            popoverController.sourceView = self.view
            
            // show popover form button
            popoverController.sourceRect = self.toolbar.frame
            
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
            self.colorButton.tintColor = selectedUIColor
        }
        
        
    }
    
    // MARK: Popover delegate functions
    // Override iPhone behavior that presents a popover as fullscreen.
    // i.e. now it shows same popover box within on iPhone & iPad
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // show popover box for iPhone and iPad both
        return UIModalPresentationStyle.None
    }
}

