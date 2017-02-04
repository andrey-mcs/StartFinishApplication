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

    override func viewDidLoad() {
        print("TAB BAR")
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
