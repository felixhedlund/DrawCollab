//
//  WelcomeViewController.swift
//  DrawCollab
//
//  Created by Felix Hedlund on 06/04/16.
//  Copyright © 2016 Felix Hedlund. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var nicknameTextField: UITextField!
    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    var appDelegate: AppDelegate!
    var randomColor: UIColor!
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.navigationController?.setNeedsStatusBarAppearanceUpdate()

        let userDefaults = NSUserDefaults.standardUserDefaults()
        generateRandomProfileColor()
        if let name = userDefaults.stringForKey("HostName"){
            nicknameTextField.text = name
        }else{
            nicknameTextField.text = UIDevice.currentDevice().name
        }
    }
    
    func generateRandomProfileColor(){
        let redRandom = CGFloat(arc4random_uniform(256))/255
        let greenRandom = CGFloat(arc4random_uniform(256))/255
        let blueRandom = CGFloat(arc4random_uniform(256))/255
        
        appDelegate.mcManager.redColor = redRandom
        appDelegate.mcManager.greenColor = greenRandom
        appDelegate.mcManager.blueColor = blueRandom
        
        randomColor = UIColor(red: redRandom, green: greenRandom, blue: blueRandom, alpha: 1)
        self.imageButton.backgroundColor = randomColor
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

    
    @IBAction func didPressImageButton(sender: AnyObject) {
        self.generateRandomProfileColor()
    }
    

    @IBAction func didPressSearchPeople(sender: AnyObject) {
        if let name = nicknameTextField.text{
            if name.characters.count > 0{
                let hostController = UIStoryboard(name: "SearchPeople", bundle: nil).instantiateViewControllerWithIdentifier("SearchPeople") as! SearchPeopleViewController
                hostController.setupWithHostNameColor(name, color: randomColor)
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
