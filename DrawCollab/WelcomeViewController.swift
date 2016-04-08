//
//  WelcomeViewController.swift
//  DrawCollab
//
//  Created by Felix Hedlund on 06/04/16.
//  Copyright © 2016 Felix Hedlund. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var hostButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    var imagePicker: UIImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.navigationController?.setNeedsStatusBarAppearanceUpdate()
        nicknameTextField.text = UIDevice.currentDevice().name
        self.imagePicker = UIImagePickerController()
        self.imagePicker?.delegate = self
        self.imagePicker?.allowsEditing = true
        
//        imageButton.layer.cornerRadius = 50
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.imagePicker?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let roundedImage = UIImage.roundedRectImageFromImage(image, imageSize: image.size, cornerRadius: image.size.width/2)
        self.imageButton.setImage(roundedImage, forState: .Normal)
        self.imagePicker?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didPressImageButton(sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let action = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.presentGallery()
        }
        let action2 = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.presentCamera()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
        }
        alert.addAction(action)
        alert.addAction(action2)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func presentGallery() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            self.imagePicker?.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imagePicker!, animated: true, completion: nil)
        }
        
    }
    
    private func presentCamera() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            self.imagePicker?.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(imagePicker!, animated: true, completion: nil)
        } else {
        }
        
    }
    @IBAction func didPressHostButton(sender: AnyObject) {
        let hostController = UIStoryboard(name: "Host", bundle: nil).instantiateViewControllerWithIdentifier("Host") as! HostViewController
        self.navigationController?.pushViewController(hostController, animated: true)
        //self.presentViewController(editModal, animated: true, completion: nil)
    }
    
    @IBAction func didPressJoinButton(sender: AnyObject) {
    }
    
    
    
    
    @IBAction func didTapView(sender: AnyObject) {
        if self.nicknameTextField.isFirstResponder(){
            hideKeyboard()
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    
    private func hideKeyboard(){
        self.view.endEditing(true)
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
