//
//  ViewController.swift
//  StartFinishApp
//
//  Created by Kostiantyn Tkachov on 29.01.17.
//  Copyright © 2017 Kostiantyn Tkachov. All rights reserved.
//

import UIKit

var BLE : BleManager = BleManager()

class MainTableViewController: UITableViewController
{

    var BLERefresh : UIRefreshControl!
    
    @IBOutlet var BLETable: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //NotificationCenter.default.addObserver(forName: RCNotifications.FoundDevice, object: self.BLETable , queue: OperationQueue.main)
        //{
        //    _ in self.tableView.reloadData()
        //}
        
        BLE.startUpCentralManager()
        
        BLERefresh = UIRefreshControl()
        BLERefresh.attributedTitle = NSAttributedString(string : "Refreshing")
        BLERefresh.addTarget(self, action : #selector(BLErefresh(sender:)), for: UIControlEvents.valueChanged)
        print ("BLERefresh Goes")
        BLETable.addSubview(BLERefresh)
    }

    
    
    func FoundDeviceObserver(notification: Notification)
    {
        self.tableView.reloadData()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(FoundDeviceObserver(notification:)), name: RCNotifications.FoundDevice, object: nil)
        BLE = BleManager()
        BLE.startUpCentralManager()
        BLETable.reloadData()
        super.viewDidAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView : UITableView, numberOfRowsInSection : Int) -> Int
    {
        print("NumRows : Goes")
        
        return BLE.getCountDevices()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "BLEDevice")
        
        cell.textLabel?.text = "\(BLE.getDeviceForIndex(Index: indexPath.row).peripheral.name!)"
        cell.detailTextLabel?.text = "RSSI : \(BLE.getDeviceForIndex(Index: indexPath.row).RSSI)"
        cell.detailTextLabel?.textColor = UIColor.purple
        
        return cell
    }
        
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print ("Prepare for Send: TableView")
        performSegue(withIdentifier: "seeBle", sender: indexPath.item)
    }
    
    
    override func prepare(for segue : UIStoryboardSegue, sender : Any?)
    {
        print ("Prepare for Send")
        
        
        BLE.centralManager.stopScan()
        
        if let CallCell = sender as? Int
        {
            print("Connect to ... (Int) \(BLE.getDeviceForIndex(Index: CallCell).peripheral.name!)")
            if let destController = segue.destination as? ConnectToBleController
            {
                print ("Yeah")
                destController.DetailViewDevice = BLE.getDeviceForIndex(Index: CallCell)
            }
            //BLE.connectToDevice(peripheral: BLE.getDeviceForIndex(Index: CallCell).peripheral)
        }

        if let CallCell = sender as? UITableViewCell
        {
            print("Connect to ... (UICell) \(BLE.getDeviceForIndex(Index: CallCell.tag).peripheral.name!)")
            //BLE.connectToDevice(peripheral: BLE.getDeviceForIndex(Index: CallCell.tag).peripheral)
        }
        
        
        if let destController = segue.destination as? GeneralInformationController
        {
            if let CallCell = sender as? UITableViewCell
            {
                print("Connect to ... \(BLE.getDeviceForIndex(Index: CallCell.tag).peripheral.name!)")
                destController.Device = BLE.getDeviceForIndex(Index: CallCell.tag)
                //BLE.connectToDevice(peripheral: BLE.getDeviceForIndex(Index: CallCell.tag).peripheral)
            }
        }
    }
    
    func BLErefresh(sender:AnyObject) {
        print("Count Devices : \(BLE.getCountDevices())")
        
        BLE = BleManager()
        BLE.startUpCentralManager()

        
        BLETable.reloadData()
        BLERefresh.endRefreshing()
    }
    
}

