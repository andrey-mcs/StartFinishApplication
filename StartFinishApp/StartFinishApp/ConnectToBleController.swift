//
//  ConnectToBleController.swift
//  StartFinishApp
//
//  Created by Andrey Tkachov on 31.01.17.
//  Copyright © 2017 Kostiantyn Tkachov. All rights reserved.
//

import UIKit

class ConnectToBleController : UIViewController
{
    @IBOutlet weak var NameBle: UILabel!
    @IBOutlet weak var RssiBle: UILabel!
    @IBOutlet weak var StateBle: UILabel!
    @IBOutlet weak var ConnectButton: UIButton!
    @IBOutlet weak var DisconnectButton: UIButton!
    @IBOutlet weak var ManageButton: UIButton!
    @IBOutlet weak var ConnectionLevel: UIImageView!
    
    var MessageFrame = UIView()
    var MessageActivityIndicator = UIActivityIndicatorView()
    var MessageText = UILabel()
    
    var RSSIRefreshTimer : Timer!
    var ConnectionTimer : Timer!
    
    var DetailViewDevice : BleDevice!
    
    var DiscAfterDismiss = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //DetailViewDevice = nil
        
        if (DetailViewDevice == nil)
        {
            print("Unknown Error")
            let alertNoConn = UIAlertController(title: "Unknown Error", message: "Unknown error. Please refresh List and Connect Again!", preferredStyle: UIAlertControllerStyle.alert)
            alertNoConn.addAction(UIAlertAction(title: "Dismiss" , style: UIAlertActionStyle.default, handler: ErrorCloseView))
            self.present(alertNoConn, animated: true, completion: nil)
        }
        else
        {
            self.NameBle.text = "\(DetailViewDevice.peripheral.name!)"
            self.NameBle.textColor = UIColor.orange
            
            self.RssiBle.text = "\(DetailViewDevice.RSSI)"
            
            switch DetailViewDevice.RSSI.intValue {
            case -54 ... 0:
                ConnectionLevel.image = UIImage(named : "Net-3")
            case -70 ... -55:
                ConnectionLevel.image = UIImage(named : "Net-2")
            case -150 ..< -70:
                ConnectionLevel.image = UIImage(named : "Net-1")
            default:
                break
            }
            
            self.RssiBle.textColor = UIColor.purple
            
            switch(DetailViewDevice.StatusConnection)
            {
                case .Connected:
                    self.StateBle.text = "Connected"
                    self.StateBle.textColor = UIColor.green
                    self.ManageButton.isEnabled = true
                    self.DisconnectButton.isEnabled = true
                    self.ConnectButton.isEnabled = false
                
                case .Disconnected :
                    self.StateBle.text = "Disconnected"
                    self.StateBle.textColor = UIColor.red
                    self.ManageButton.isEnabled = false
                    self.DisconnectButton.isEnabled = false
                    self.ConnectButton.isEnabled = true
            }

            ConnectButton.addTarget(self, action : #selector(self.actionConnectButton), for : .touchUpInside)
            DisconnectButton.addTarget(self, action: #selector(self.actionDisconnectButton), for: .touchUpInside)
            ManageButton.addTarget(self, action: #selector(self.actionManageDevice), for: .touchUpInside)
            
            RSSIRefreshTimer = Timer()
            
            ConnectionTimer = Timer()
            
            
            self.navigationItem.hidesBackButton = true
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "List Devices", style: .plain, target: self, action : #selector(goBackToTable(sender:)))
            
        }
        print("ConnectToBleController : Init")
        
    }
    
    func ConnectedDeviceObserver(notification : Notification)
    {
        self.StateBle.text = "Connected"
        self.StateBle.textColor = UIColor.green
        self.ManageButton.isEnabled = true
        self.DisconnectButton.isEnabled = true
        self.ConnectButton.isEnabled = false
        
        self.ConnectionTimer.invalidate()
        self.MessageFrame.removeFromSuperview()
        
        self.RSSIRefreshTimer = Timer.scheduledTimer(timeInterval: 0.5 , target: self, selector: #selector(self.actionRefreshRSSI), userInfo: nil, repeats: true)
        self.DiscAfterDismiss = false
    }
    
    func DisconnectedDeviceObserver(notification: Notification)
    {
        self.StateBle.text = "Disconnected"
        self.StateBle.textColor = UIColor.red
        self.ManageButton.isEnabled = false
        self.DisconnectButton.isEnabled = false
        
        (self.DiscAfterDismiss == true) ? (self.ConnectButton.isEnabled = false) : (self.ConnectButton.isEnabled = true)
        
        if self.RSSIRefreshTimer != nil
        {
            self.RSSIRefreshTimer.invalidate()
        }
        ConnectionLevel.image = UIImage(named : "Net-0")

    }
    
    func ReadedRSSI(notification: Notification)
    {
        self.RssiBle.text = "\(self.DetailViewDevice.RSSI)"
        switch DetailViewDevice.RSSI.intValue {
        case -54 ... 0:
            ConnectionLevel.image = UIImage(named : "Net-3")
        case -70 ... -55:
            ConnectionLevel.image = UIImage(named : "Net-2")
        case -150 ..< -70:
            ConnectionLevel.image = UIImage(named : "Net-1")
        default:
            break
        }

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
    
    
    override func viewDidAppear(_ animated: Bool) {
        if DetailViewDevice.StatusConnection == .Connected
        {
            self.RSSIRefreshTimer = Timer.scheduledTimer(timeInterval: 0.5 , target: self, selector: #selector(self.actionRefreshRSSI), userInfo: nil, repeats: true)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.ConnectedDeviceObserver(notification:)), name: RCNotifications.ConnectedDevice, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.DisconnectedDeviceObserver(notification:)), name: RCNotifications.DisconnectedDevice, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.ReadedRSSI(notification:)), name: RCNotifications.ReadedRSSI, object: nil)

    }
    override func prepare(for segue : UIStoryboardSegue, sender : Any?)
    {
        if let Destination = segue.destination as? ManageDeviceController
        {
            Destination.ManageDev = self.DetailViewDevice
        }
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    
    func goBackToTable(sender: UIBarButtonItem) -> ()
    {
        print ("Nooo")
        BLE.disconnectDevice(peripheral: DetailViewDevice.peripheral)
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    func actionConnectButton() -> ()
    {
        
        //performSegue(withIdentifier: "ManageDevice", sender: nil)
        progressBarDisplayer(msg: "Connecting", true)
        BLE.connectToDevice(peripheral: DetailViewDevice.peripheral)
        self.ConnectionTimer = Timer.scheduledTimer(timeInterval: 5 , target: self, selector: #selector(self.actionTimeoutConnect), userInfo: nil, repeats: false)
        self.ConnectButton.isEnabled = false
        DiscAfterDismiss = false
    }

    func actionTimeoutConnect() -> ()
    {
        self.MessageFrame.removeFromSuperview()
        DiscAfterDismiss = true
        BLE.disconnectDevice(peripheral: DetailViewDevice.peripheral)
        let alertErrorConn = UIAlertController(title: "Connection Error", message: "Please try again!", preferredStyle: UIAlertControllerStyle.alert)
        alertErrorConn.addAction(UIAlertAction(title: "Retry" , style: UIAlertActionStyle.default, handler: actionRetryTry))
        alertErrorConn.addAction(UIAlertAction(title: "Dismiss" , style: UIAlertActionStyle.default, handler: actionCancelRetryTry))
        self.present(alertErrorConn, animated: true, completion: nil)
        ConnectionTimer.invalidate()
 
    }
    
    func actionDisconnectButton() -> ()
    {
        BLE.disconnectDevice(peripheral: DetailViewDevice.peripheral)
        DiscAfterDismiss = false
    }
    
    func actionRetryTry(alert : UIAlertAction!)
    {
        progressBarDisplayer(msg: "Connecting", true)
        BLE.connectToDevice(peripheral: DetailViewDevice.peripheral)
        self.ConnectionTimer = Timer.scheduledTimer(timeInterval: 5 , target: self, selector: #selector(self.actionTimeoutConnect), userInfo: nil, repeats: false)
        DiscAfterDismiss = false
    }
    
    func actionCancelRetryTry(alert : UIAlertAction!)
    {
        self.ConnectButton.isEnabled = true
        DiscAfterDismiss = false
    }

    func actionRefreshRSSI() -> ()
    {
        DetailViewDevice.peripheral.readRSSI()
    }

    func actionManageDevice() -> ()
    {
        self.RSSIRefreshTimer.invalidate()
        performSegue(withIdentifier: "ManageDevice", sender: nil)
    }
    
    func ErrorCloseView(alert : UIAlertAction!)
    {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
}
