//
//  ManageDeviceController.swift
//  StartFinishApp
//
//  Created by Andrey Tkachov on 04.02.17.
//  Copyright © 2017 Kostiantyn Tkachov. All rights reserved.
//

import UIKit

class ManageDeviceController : UITabBarController
{
    var MessageFrame = UIView()
    var MessageActivityIndicator = UIActivityIndicatorView()
    var MessageText = UILabel()

    var ReconnectTimer : Timer!
    var SyncTimer : Timer!
    
    var ManageDev : BleDevice!
    
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.AllSkierCharacterisrticDiscoveredObserver(notification:)), name: RCNotifications.AllSkierCharacterisrticDiscovered, object: nil)
        if (ManageDev.allCharacteristicSetted() != true)
        {
            progressBarDisplayer(msg: "Syncing", true)
        }
        else
        {
            print ("All Discovered")
        }
        
        var tmpVal = self.viewControllers?[0]
        if var SelectedView = tmpVal! as? GeneralInformationController
        {
            SelectedView.Device = ManageDev
        }
        
        //if var SelectedView = tmpVal!
        
        ReconnectTimer = Timer()
        
        
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
        //SelectedView.StartTimeData.text = ""
        //SelectedView.FinishTimeData.text = ""
        //SelectedView.ResultTimeData.text = ""
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
    
}
