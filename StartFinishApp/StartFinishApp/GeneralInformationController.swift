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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.AllSkierCharacterisrticDiscoveredObserver(notification:)), name: RCNotifications.AllSkierCharacterisrticDiscovered, object: nil)
        if (Device.allCharacteristicSetted() != true)
        {
            self.StartTimeData = "Unk"
        }


    }
    
    func AllSkierCharacterisrticDiscoveredObserver ( notification : Notification)
    {
        print("SubView Notif")
        //SelectedView.StartTimeData.text = "Unknown Time"
        //SelectedView.FinishTimeData.text = "Unknown Time"
        //SelectedView.ResultTimeData.text = "Unknown Time"
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        
    }
    
    
 
    
}
