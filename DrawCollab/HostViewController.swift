//
//  MainViewController.swift
//  DrawCollab
//
//  Created by Felix Hedlund on 06/04/16.
//  Copyright © 2016 Felix Hedlund. All rights reserved.
//

import UIKit
import MultipeerConnectivity
class HostViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, MCBrowserViewControllerDelegate {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var visibleSwitch: UISwitch!
    @IBOutlet weak var browseDevicesButton: UIButton!
    @IBOutlet weak var table: UITableView!
    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    var appDelegate: AppDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mcManager.setupPeerAndSessionWithDisplayName(UIDevice.currentDevice().name)
        appDelegate.mcManager.advertiseSelf(visibleSwitch.on)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.peerDidChangestateWithNotification(_:)), name: "MCDidChangeStateNotification", object: nil)
        // Do any additional setup after loading the view.
    }
    @IBAction func didPressVisibleSwitch(sender: AnyObject) {
        appDelegate.mcManager.advertiseSelf(visibleSwitch.on)
    }
    @IBAction func didPressBrowseDevices(sender: AnyObject) {
        appDelegate.mcManager.setupMCBrowser()
        if let browser = appDelegate.mcManager.browser{
            browser.delegate = self
            self.presentViewController(browser, animated: true, completion: nil)
        }
        
    }
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//    selector:@selector(peerDidChangeStateWithNotification:)
//    name:@"MCDidChangeStateNotification"
//    object:nil];
    
    func peerDidChangestateWithNotification(notification: NSNotification){
        let userInfo = notification.userInfo!
        let peerID = userInfo["peerID"] as! MCPeerID
        let peerDisplayName = peerID.displayName
        let state = MCSessionState(rawValue: (userInfo["state"] as! Int))
        
        if state != MCSessionState.Connecting{
            if state == MCSessionState.Connected{
                appDelegate.mcManager.arrConnectedDevices.addObject(peerDisplayName)
            }else if state == MCSessionState.NotConnected{
                if appDelegate.mcManager.arrConnectedDevices.count > 0{
                    let index = appDelegate.mcManager.arrConnectedDevices.indexOfObject(peerDisplayName)
                    if index != NSNotFound{
                        appDelegate.mcManager.arrConnectedDevices.removeObjectAtIndex(index)
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.table.reloadData()
            })
        }
        
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        tapGesture.addTarget(self, action: #selector(self.hideKeyboard))
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.hideKeyboard()
        if let text = textField.text{
            var name = ""
            if text.characters.count > 0{
                name = text
            }else{
                name = UIDevice.currentDevice().name
            }
            appDelegate.mcManager.peerID = nil
            appDelegate.mcManager.session = nil
            appDelegate.mcManager.browser = nil
            
            if visibleSwitch.on{
                appDelegate.mcManager.advertiser?.stop()
            }
            appDelegate.mcManager.advertiser = nil
            appDelegate.mcManager.setupPeerAndSessionWithDisplayName(name)
            appDelegate.mcManager.setupMCBrowser()
            appDelegate.mcManager.advertiseSelf(visibleSwitch.on)
        }
        
        
        
        
        return true
    }
    
    func hideKeyboard(){
        nameTextField.resignFirstResponder()
        tapGesture.removeTarget(self, action: #selector(self.hideKeyboard))
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        if let browser = appDelegate.mcManager.browser{
            browser.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        if let browser = appDelegate.mcManager.browser{
            browser.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.mcManager.arrConnectedDevices.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = table.dequeueReusableCellWithIdentifier("ConnectCell") as? ConnectionTableViewCell{
            cell.titleLabel.text = appDelegate.mcManager.arrConnectedDevices[indexPath.row] as? String
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
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
