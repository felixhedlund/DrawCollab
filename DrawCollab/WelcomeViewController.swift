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
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var imageButtonWidthConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var nicknameTextField: UITextField!
    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    
    
    var appDelegate: AppDelegate!
    var randomColor: UIColor!
    
    var hasSetButtonImage = false
    var hasChangedToBlack = false
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        self.navigationController?.setNeedsStatusBarAppearanceUpdate()

        let userDefaults = UserDefaults.standard
        generateRandomProfileColor()
        if let name = userDefaults.string(forKey: "HostName"){
            nicknameTextField.text = name
        }else{
            let name = UIDevice.current.name
            nicknameTextField.text = name
            userDefaults.set(name, forKey: "HostName")
            userDefaults.synchronize()
        }
        imageButtonWidthConstraint.constant = appDelegate.sizes.welcomeButtonsWidth
    }
    
    func generateRandomProfileColor(){
        let redRandom = CGFloat(arc4random_uniform(256))/255
        let greenRandom = CGFloat(arc4random_uniform(256))/255
        let blueRandom = CGFloat(arc4random_uniform(256))/255
        
        appDelegate.mcManager.redColor = redRandom
        appDelegate.mcManager.greenColor = greenRandom
        appDelegate.mcManager.blueColor = blueRandom
        
        randomColor = UIColor(red: appDelegate.mcManager.redColor, green: appDelegate.mcManager.greenColor, blue: appDelegate.mcManager.blueColor, alpha: 1)
        changeProfileColor(randomColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        UINavigationBar.appearance().tintColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)
        appDelegate.mcManager.disconnectFromParty()
        appDelegate.mcManager.lastMainDrawImage = nil
        appDelegate.mcManager.patternNumber = 0
        randomColor = UIColor(red: appDelegate.mcManager.redColor, green: appDelegate.mcManager.greenColor, blue: appDelegate.mcManager.blueColor, alpha: 1)
        changeProfileColor(randomColor)
        
    }
    
    func changeProfileColor(_ color: UIColor){
        if !hasSetButtonImage{
            var image = UIImage(named: "whiteCircle")
            image = image!.maskWithColor(color)
            imageButton.setImage(image, for: UIControlState())
            hasSetButtonImage = true
        }else{
            imageButton.setImage(imageButton.imageView!.image!.maskWithColor(color), for: UIControlState())
        }
        let colors = color.cgColor.components
        
        if colors?[0] == 0.0 && colors?[1] == 0.0 && colors?[2] == 0.0 && !hasChangedToBlack{
            profileImage.image = profileImage.image?.maskWithColor(UIColor.white)
            hasChangedToBlack = true
        }else{
            if hasChangedToBlack{
                profileImage.image =  profileImage.image?.maskWithColor(UIColor.black)
                hasChangedToBlack = false
            }
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func didPressImageButton(_ sender: AnyObject) {
        self.generateRandomProfileColor()
    }
    

    @IBAction func didPressSearchPeople(_ sender: AnyObject) {
        if let name = nicknameTextField.text{
            if name.characters.count > 0{
                let hostController = UIStoryboard(name: "SearchPeople", bundle: nil).instantiateViewController(withIdentifier: "SearchPeople") as! SearchPeopleViewController
                hostController.setupWithHostNameColor(name)
                self.navigationController?.pushViewController(hostController, animated: true)
            }
        }
    }
    
    @IBAction func didTapView(_ sender: AnyObject) {
        if self.nicknameTextField.isFirstResponder{
            hideKeyboard()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = nicknameTextField.text{
            let userDefaults = UserDefaults.standard
            userDefaults.set(text, forKey: "HostName")
            userDefaults.synchronize()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    
    fileprivate func hideKeyboard(){
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
