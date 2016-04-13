//
//  ErasorPickerViewController.swift
//  DrawCollab
//
//  Created by Felix Hedlund on 13/04/16.
//  Copyright © 2016 Felix Hedlund. All rights reserved.
//

import UIKit

protocol ErasorPickerDelegate{
    func erasorSizeWasPicked(erasorSize: Float)
}

class ErasorPickerViewController: UIViewController {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var erasorView: UIView!
    @IBOutlet weak var erasorWidth: NSLayoutConstraint!
    var delegate: ErasorPickerDelegate!
    var previousSize: Float!
    override func viewDidLoad() {
        super.viewDidLoad()
        erasorView.layer.borderWidth = 1
        erasorView.layer.borderColor = UIColor.blackColor().CGColor
        erasorWidth.constant = CGFloat(previousSize)
        slider.value = previousSize
        // Do any additional setup after loading the view.
    }
    
    @IBAction func brushSizeSliderValueChanged(sender: UISlider) {
        let size = sender.value
        previousSize = size
        erasorWidth.constant = CGFloat(size)
        self.delegate.erasorSizeWasPicked(size)
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
