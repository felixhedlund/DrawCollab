//
//  PatternCollectionViewCell.swift
//  DrawCollab
//
//  Created by Felix Hedlund on 15/04/16.
//  Copyright © 2016 Felix Hedlund. All rights reserved.
//

import UIKit

let patternImages = ["pattern1", "pattern2"]
let patternButtonImages = ["pattern1Button", "pattern2Button"]
class PatternCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var patternImage: UIImageView!
    @IBOutlet weak var patternButton: UIButton!
    
    
    
    var row: Int!
    var parent: PatternPickerViewController!
    var appDelegate: AppDelegate!
    func setupPatternCell(row: Int, parent: PatternPickerViewController){
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.row = row
        self.parent = parent
        self.setupPatternImage()
    }
    
    private func setupPatternImage(){
        if row == 0{
            patternImage.hidden = true
        }else{
            patternImage.hidden = false
            if row - 1 > patternButtonImages.count-1{
                patternImage.image = UIImage(named: patternButtonImages[0])
            }else{
                patternImage.image = UIImage(named: patternButtonImages[row-1])
            }
        }
        if row == appDelegate.mcManager.patternNumber{
            selectedImage.hidden = false
        }else{
            selectedImage.hidden = true
        }
    }
    
    
    @IBAction func didPressPatternButton(sender: AnyObject) {
        appDelegate.mcManager.patternNumber = row
        parent.didChangePattern()
    }
    
}
