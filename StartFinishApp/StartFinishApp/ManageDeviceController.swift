//
//  ManageDeviceController.swift
//  StartFinishApp
//
//  Created by Andrey Tkachov on 04.02.17.
//  Copyright © 2017 Kostiantyn Tkachov. All rights reserved.
//

import UIKit


/*
extension ManageDeviceController {
    public func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        
        let fromView: UIView = tabBarController.selectedViewController!.view
        let toView  : UIView = viewController.view
        if fromView == toView {
            return false
        }
        
        UIView.transition(from: fromView, to: toView, duration: 0.3, options: UIViewAnimationOptions.transitionCrossDissolve)
            { (finished:Bool) in
            }

        return true
    }
}

*/
class ManageDeviceController : UITabBarController, UITabBarControllerDelegate
{
    var MessageFrame = UIView()
    var MessageActivityIndicator = UIActivityIndicatorView()
    var MessageText = UILabel()

    var ReconnectTimer : Timer!
    var SyncTimer : Timer!
    
    var ManageDev : BleDevice!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.AllSkierCharacterisrticDiscoveredObserver(notification:)), name: RCNotifications.AllSkierCharacterisrticDiscovered, object: nil)
        if (ManageDev.allCharacteristicSetted() != true)
        {
            progressBarDisplayer(msg: "Syncing", true)
        }
        else
        {
            print ("All Discovered")
        }
        
        let tmpVal = self.viewControllers?[0]
        if let SelectedView = tmpVal! as? GeneralInformationController
        {
            SelectedView.Device = ManageDev
        }
        
        let selectedColor   = UIColor.blue
        let unselectedColor = UIColor.white
        
        //UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: unselectedColor], for: .normal)
        //UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: selectedColor], for: .selected)
        //UITabBarItem.appearance().setTitleTextAttributes([NSBackgroundColorAttributeName: unselectedColor], for: .normal)
        //UITabBarItem.appearance().setTitleTextAttributes([NSBackgroundColorAttributeName: selectedColor], for: .selected)
        UITabBar.appearance().backgroundColor = unselectedColor
        UITabBar.appearance().tintColor = selectedColor
        
        self.setupSwipeGestureRecognizers(allowCyclingThoughTabs: false)
        
        //if var SelectedView = tmpVal!
        
        ReconnectTimer = Timer()
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // just return the custom TransitioningObject object that conforms to UIViewControllerAnimatedTransitioning protocol
        let animatedTransitioningObject = TransitioningObject()
        return animatedTransitioningObject
    }
   
    
    
    

    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(DisconnectedDeviceObserver(notification:)), name: RCNotifications.DisconnectedDevice, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ConnectedDeviceObserver(notification:)), name: RCNotifications.ConnectedDevice, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TimeSkierArrivedObserver(notification:)), name: RCNotifications.TimeSkierArrived, object: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        if (ReconnectTimer != nil){
            ReconnectTimer.invalidate()
        }
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func TimeSkierArrivedObserver( notification : Notification)
    {

    }
    
    func AllSkierCharacterisrticDiscoveredObserver ( notification : Notification)
    {
        MessageFrame.removeFromSuperview()
    }
    
    func DisconnectedDeviceObserver(notification : Notification)
    {
        MessageFrame.removeFromSuperview()
        progressBarDisplayer(msg: "Reconnecting", true)
        ReconnectTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(timeOutReconnect), userInfo: nil, repeats: false)
        BLE.connectToDevice(peripheral: ManageDev.peripheral)
    }
    
    func ConnectedDeviceObserver(notification : Notification)
    {
        MessageFrame.removeFromSuperview()
        ReconnectTimer.invalidate()
        progressBarDisplayer(msg: "Syncing", true)
    }
    
    func timeOutReconnect()
    {
        ReconnectTimer.invalidate()
        MessageFrame.removeFromSuperview()
        NotificationCenter.default.removeObserver(self)
        BLE.disconnectDevice(peripheral: ManageDev.peripheral)
        
        let errorReconnect = UIAlertController(title: "Reconnection Error", message: "Please refresh list and try connect again!", preferredStyle: UIAlertControllerStyle.alert)
        errorReconnect.addAction(UIAlertAction(title: "Retry" , style: UIAlertActionStyle.default, handler: self.ErrorReconnect))
        self.present(errorReconnect, animated: true, completion: nil)
    }
    
    override func prepare(for segue : UIStoryboardSegue, sender : Any?)
    {
        print("Item Tab Bar")
    }
    
    func ErrorReconnect(alert : UIAlertAction!)
    {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    func progressBarDisplayer(msg:String, _ indicator:Bool ) {
        print(msg)
        MessageText = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
        MessageText.text = msg
        MessageText.textColor = UIColor.white
        MessageFrame = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25 , width: 180, height: 50))
        MessageFrame.layer.cornerRadius = 15
        MessageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
        if indicator {
            MessageActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
            MessageActivityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            MessageActivityIndicator.startAnimating()
            MessageFrame.addSubview(MessageActivityIndicator)
        }
        MessageFrame.addSubview(MessageText)
        view.addSubview(MessageFrame)
    }
    
    
    
    func setupSwipeGestureRecognizers(allowCyclingThoughTabs cycleThroughTabs: Bool = false) {
        let swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: cycleThroughTabs ? #selector(self.handleSwipeLeftAllowingCyclingThroughTabs) : #selector(handleSwipeLeft))
        swipeLeftGestureRecognizer.direction = .left
        self.view.addGestureRecognizer(swipeLeftGestureRecognizer)
        self.tabBar.removeGestureRecognizer(swipeLeftGestureRecognizer)
        
        
        let swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: cycleThroughTabs ? #selector(handleSwipeRightAllowingCyclingThroughTabs) : #selector(handleSwipeRight))
        swipeRightGestureRecognizer.direction = .right
        self.view.addGestureRecognizer(swipeRightGestureRecognizer)
        self.tabBar.removeGestureRecognizer(swipeRightGestureRecognizer)
    }
    
    @objc private func handleSwipeLeft(swipe: UISwipeGestureRecognizer) {
        self.selectedIndex -= 1
    }
    
    @objc private func handleSwipeRight(swipe: UISwipeGestureRecognizer) {
        self.selectedIndex += 1
    }
    
    @objc private func handleSwipeLeftAllowingCyclingThroughTabs(swipe: UISwipeGestureRecognizer) {
        let maxIndex = (self.viewControllers?.count ?? 0)
        let nextIndex = self.selectedIndex - 1
        self.selectedIndex = nextIndex >= 0 ? nextIndex : maxIndex - 1
        
    }
    
    @objc private func handleSwipeRightAllowingCyclingThroughTabs(swipe: UISwipeGestureRecognizer) {
        let maxIndex = (self.viewControllers?.count ?? 0)
        let nextIndex = self.selectedIndex + 1
        self.selectedIndex = nextIndex < maxIndex ? nextIndex : 0
    }
}
