//
//  UIColor.swift
//  DrawCollab
//
//  Created by Felix Hedlund on 05/04/16.
//  Copyright © 2016 Felix Hedlund. All rights reserved.
//

import UIKit

extension UIColor{
    func rgb() -> (red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = CGFloat(fRed * 255.0)
            let iGreen = CGFloat(fGreen * 255.0)
            let iBlue = CGFloat(fBlue * 255.0)
            let iAlpha = CGFloat(fAlpha * 255.0)
            
            return (red:iRed/255, green:iGreen/255, blue:iBlue/255, alpha:iAlpha/255)
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}

extension UIImage {
    func maskWithColor(_ color: UIColor) -> UIImage {
        
        let maskImage = self.cgImage
        let width = self.size.width
        let height = self.size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let bitmapContext = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        bitmapContext?.clip(to: bounds, mask: maskImage!)
        bitmapContext?.setFillColor(color.cgColor)
        bitmapContext?.fill(bounds)
        
        let cImage = bitmapContext?.makeImage()
        let coloredImage = UIImage(cgImage: cImage!)
        
        return coloredImage
    }
    
    class func roundedRectImageFromImage(_ image:UIImage,imageSize:CGSize,cornerRadius:CGFloat)->UIImage{
        UIGraphicsBeginImageContextWithOptions(imageSize,false,0.0)
        let bounds=CGRect(origin: CGPoint.zero, size: imageSize)
        UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).addClip()
        image.draw(in: bounds)
        let finalImage=UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage!
    }
}


//class RDTraitCollectionOverrideViewController: UIViewController{
//    var willTransitionToPortrait = false
//    var traitCollectionCompactRegular: UITraitCollection!
//    var traitCollectionAnyAny: UITraitCollection!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.setupReferenceSizeClasses()
//    }
//    
//    func setupReferenceSizeClasses(){
//        let traitCollection_hCompact = UITraitCollection(horizontalSizeClass: UIUserInterfaceSizeClass.Compact)
//        let traitCollection_vRegular = UITraitCollection(verticalSizeClass: UIUserInterfaceSizeClass.Regular)
//        traitCollectionCompactRegular = UITraitCollection(traitsFromCollections: [traitCollection_hCompact, traitCollection_vRegular])
//        
//        let traitCollection_hAny = UITraitCollection(horizontalSizeClass: UIUserInterfaceSizeClass.Unspecified)
//        let traitCollection_vAny = UITraitCollection(verticalSizeClass: UIUserInterfaceSizeClass.Unspecified)
//        traitCollectionAnyAny = UITraitCollection(traitsFromCollections: [traitCollection_hAny, traitCollection_vAny])
//
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        willTransitionToPortrait = self.view.frame.size.height > self.view.frame.size.width
//    }
//    
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        willTransitionToPortrait = size.height > size.width
//    }
//    
//    override func overrideTraitCollectionForChildViewController(childViewController: UIViewController) -> UITraitCollection? {
//        let traitCollectionForOverride: UITraitCollection = willTransitionToPortrait ? traitCollectionCompactRegular : traitCollectionAnyAny
//        return traitCollectionForOverride
//    }
//    
//}
