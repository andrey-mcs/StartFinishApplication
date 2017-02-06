//
//  GeneralInformationController.swift
//  StartFinishApp
//
//  Created by Andrey Tkachov on 30.01.17.
//  Copyright © 2017 Kostiantyn Tkachov. All rights reserved.
//

import UIKit
//import Foundation

class GeneralInformationController : UIViewController
{
    
    var Device : BleDevice!
    @IBOutlet weak var StartTimeLabel: UILabel!
    @IBOutlet weak var StartTimeData: UILabel!
    @IBOutlet weak var FinishTimeLabel: UILabel!
    @IBOutlet weak var FinishTimeData: UILabel!
    @IBOutlet weak var ResultTimeLabel: UILabel!
    @IBOutlet weak var ResultTimeData: UILabel!
    
    var updaterTime : Timer!
    
    var currentHour : Int32 = 0, currentMin : Int32 = 0, currentSec : Int32 = 0, currentMs : Int32 = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
       NotificationCenter.default.addObserver(self, selector: #selector(self.AllSkierCharacterisrticDiscoveredObserver(notification:)), name: RCNotifications.AllSkierCharacterisrticDiscovered, object: nil)
        if (Device.allCharacteristicSetted() != true)
        {
            self.StartTimeData.text = "Unknown Time"
            self.FinishTimeData.text = "Unknown Time"
            self.ResultTimeData.text = "Unknown Time"
        }
        else
        {
            self.StartTimeData.text = "00:00:000"
            self.FinishTimeData.text = "00:00:000"
            self.ResultTimeData.text = "00:00:000"
        }

        print("Hehe")
        NotificationCenter.default.addObserver(self, selector: #selector(DisconnectedDeviceObserver(notification:)), name: RCNotifications.DisconnectedDevice, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TimeSkierArrivedObserver(notification:)), name: RCNotifications.TimeSkierArrived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TimeStartArrivedObserver(notification:)), name: RCNotifications.TimeStartArrived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.AllSkierCharacterisrticDiscoveredObserver(notification:)), name: RCNotifications.AllSkierCharacterisrticDiscovered, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ConnectedDeviceObserver(notification:)), name: RCNotifications.ConnectedDevice, object: nil)


        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(DisconnectedDeviceObserver(notification:)), name: RCNotifications.DisconnectedDevice, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ConnectedDeviceObserver(notification:)), name: RCNotifications.ConnectedDevice, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TimeSkierArrivedObserver(notification:)), name: RCNotifications.TimeSkierArrived, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TimeStartArrivedObserver(notification:)), name: RCNotifications.TimeStartArrived, object: nil)

    }
    
    func AllSkierCharacterisrticDiscoveredObserver ( notification : Notification)
    {
        print("DiscChar")
        printTimeOnLabels()
    }
    
    func updateTime()
    {
        //print("Update Time")
        currentMs += 31;
        if (currentMs >= 1000) {
            currentMs = 0;
            currentSec += 1;
            if (currentSec >= 60) {
                currentSec = 0;
                currentMin += 1;
                if (currentMin >= 60) {
                    currentMin = 0;
                    currentHour += 1;
                    if (currentHour >= 24) {
                        currentHour = 0;
                    }
                }
            }
        }
        
        
        
        var tmpTime = Array<Int32>(arrayLiteral: 0,0,0,0)
        
        tmpTime[3] = currentMs - Int32(self.Device.TimeStartData[3]);
        
        tmpTime[2] = currentSec - Int32(self.Device.TimeStartData[2]);
        tmpTime[1] = currentMin - Int32(self.Device.TimeStartData[1]);
        tmpTime[0] = currentHour - Int32(self.Device.TimeStartData[0]);
        
        if (tmpTime[3] < 0) {
            tmpTime[3] += 1000;
            tmpTime[2] -= 1;
        }
        if (tmpTime[2] < 0) {
            tmpTime[1] += 60;
            tmpTime[1] -= 1;
        }
        if (tmpTime[1] < 0) {
            tmpTime[1] += 60;
            tmpTime[0] -= 1;
        }
        
        
        //textViewHourFinish.setText(String.format("%02d", currentHour));
        //textViewMinFinish.setText(String.format("%02d", currentMin));
        //textViewSecFinish.setText(String.format("%02d", currentSec));
        //textViewMsFinish.setText(String.format("%03d", currentMs));
        
        print("\(tmpTime[0]):\(tmpTime[1]):\(tmpTime[2]):\(tmpTime[3])")
        
        self.FinishTimeData.text = String(format:"%02d:%02d:%02d:%03d", currentHour, currentMin, currentSec, currentMs)
        self.ResultTimeData.text = String(format:"%02d:%02d:%02d:%03d", tmpTime[0], tmpTime[1], tmpTime[2], tmpTime[3])
        
        //textViewMinResult.setText(String.format("%02d", tmpTime[MIN]));
        //textViewSecResult.setText(String.format("%02d", tmpTime[SEC]));
        //textViewMsResult.setText(String.format("%03d", tmpTime[MS]));
    }
    
    func printTimeOnLabels()
    {
        var tmpVar = Device.TimeStartData
        
        self.StartTimeData.text = String(format: "%02d:%02d:%02d:%03d", tmpVar![0], tmpVar![1], tmpVar![2], tmpVar![3])
        
        if ((self.Device.TimeFinishData[0] == 0) && self.Device.TimeFinishData[1] == 0 && self.Device.TimeFinishData[2] == 0 && self.Device.TimeFinishData[3] == 0)
        {
            if updaterTime != nil
            {
                updaterTime.invalidate()
            }
            print("Not Finish Time")
            currentHour = Int32(self.Device.TimeStartData![0])
            currentMin = Int32(self.Device.TimeStartData![1])
            currentSec = Int32(self.Device.TimeStartData![2])
            currentMs = Int32(self.Device.TimeStartData![3])
            updaterTime = Timer.scheduledTimer(timeInterval: 0.031, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)

        }
        else
        {
            tmpVar = Device.TimeFinishData

            self.FinishTimeData.text = String(format:"%02d:%02d:%02d:%03d", tmpVar![0], tmpVar![1], tmpVar![2], tmpVar![3])
            
            tmpVar = Device.TimeResultData
        
            self.ResultTimeData.text = String(format:"%02d:%02d:%02d:%03d", tmpVar![0], tmpVar![1], tmpVar![2], tmpVar![3])
            if updaterTime != nil
            {
                updaterTime.invalidate()
            }
            
        }
    }
    
    func TimeSkierArrivedObserver( notification: Notification)
    {
        print("TimeArrived")
        printTimeOnLabels()
    }

    func TimeStartArrivedObserver( notification: Notification)
    {
        print("StartArrived")
        if updaterTime != nil
        {
            updaterTime.invalidate()
        }
    }

    
    func ConnectedDeviceObserver( notification: Notification)
    {
        //updaterTime = Timer.scheduledTimer(timeInterval: , target: , selector: , userInfo: , repeats: )
    }
    
    func DisconnectedDeviceObserver(notification : Notification)
    {
        print("DiscDevice")
        self.StartTimeData.text = "Unknown Time"
        self.FinishTimeData.text = "Unknown Time"
        self.ResultTimeData.text = "Unknown Time"
        if (self.updaterTime != nil)
        {
            updaterTime.invalidate()
        }
       
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        print ("Disappear")
        NotificationCenter.default.removeObserver(self)
        
        if updaterTime != nil
        {
            updaterTime.invalidate()
        }
    }
    
    
 
    
}
