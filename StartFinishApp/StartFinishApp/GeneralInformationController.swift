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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if Device != nil
        {
            BLE.disconnectDevice(peripheral: Device.peripheral)
            print("Disconnected \(Device.peripheral.name!)")
        }
    }
 
    
}
