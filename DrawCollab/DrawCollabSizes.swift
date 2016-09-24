//
//  DrawCollabSizes.swift
//  DrawCollab
//
//  Created by Felix Hedlund on 17/04/2016.
//  Copyright © 2016 Felix Hedlund. All rights reserved.
//

import Foundation
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class DrawCollabSizes: NSObject{
    
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var canvasButtonWidth: CGFloat!
    var welcomeButtonsWidth: CGFloat!
    var toolbarButtonSize: CGFloat!
    override init() {
        super.init()
        let screen = UIScreen.main.bounds
        
        let width = screen.width
        let height = screen.height
        if height > width{
            screenWidth = width
            screenHeight = height
        }else{
            screenHeight = width
            screenWidth = height
        }
        welcomeButtonsWidth = screenWidth/3
        canvasButtonWidth = screenWidth/5
        toolbarButtonSize = screenHeight/8
        if toolbarButtonSize > 83{
            toolbarButtonSize = 83
        }
        
    }
}
