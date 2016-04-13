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
    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    var imagePicker: UIImagePickerController?
    var appDelegate: AppDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.navigationController?.setNeedsStatusBarAppearanceUpdate()
        nicknameTextField.text = UIDevice.currentDevice().name
        self.imagePicker = UIImagePickerController()
        self.imagePicker?.delegate = self
        self.imagePicker?.allowsEditing = true
        
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let imageData = userDefaults.objectForKey("ProfilePicture") as? NSData{
            if let image = UIImage(data: imageData){
                let roundedImage = UIImage.roundedRectImageFromImage(image, imageSize: image.size, cornerRadius: image.size.width/2)
                appDelegate.mcManager.discoveryImage = roundedImage
                imageButton.setImage(roundedImage, forState: .Normal)
            }
        }
        
        if let name = userDefaults.stringForKey("HostName"){
            nicknameTextField.text = name
        }
//        imageButton.layer.cornerRadius = 50
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        UINavigationBar.appearance().tintColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)
        appDelegate.mcManager.disconnectFromParty()
        
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
        appDelegate.mcManager.discoveryImage = roundedImage
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let data = UIImageJPEGRepresentation(roundedImage, 1)
        userDefaults.setObject(data, forKey: "ProfilePicture")
        userDefaults.synchronize()

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
    

    @IBAction func didPressSearchPeople(sender: AnyObject) {
        if let name = nicknameTextField.text{
            if name.characters.count > 0{
                let hostController = UIStoryboard(name: "SearchPeople", bundle: nil).instantiateViewControllerWithIdentifier("SearchPeople") as! SearchPeopleViewController
                hostController.setupWithHostNamePicture(name, image: self.imageButton.currentImage!)
                self.navigationController?.pushViewController(hostController, animated: true)
            }
        }
    }
    
    @IBAction func didTapView(sender: AnyObject) {
        if self.nicknameTextField.isFirstResponder(){
            hideKeyboard()
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let text = nicknameTextField.text{
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(text, forKey: "HostName")
            userDefaults.synchronize()
        }
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
