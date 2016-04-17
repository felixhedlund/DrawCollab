//
//  DrawCollabSizes.swift
//  DrawCollab
//
//  Created by Felix Hedlund on 17/04/2016.
//  Copyright © 2016 Felix Hedlund. All rights reserved.
//

import Foundation
import UIKit

class DrawCollabSizes: NSObject{
    
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var canvasButtonWidth: CGFloat!
    var welcomeButtonsWidth: CGFloat!
    var toolbarButtonSize: CGFloat!
    override init() {
        super.init()
        let screen = UIScreen.mainScreen().bounds
        
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
