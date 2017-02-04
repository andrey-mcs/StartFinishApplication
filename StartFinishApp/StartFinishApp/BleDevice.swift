//
//  BleDevice.swift
//  StartFinishApp
//
//  Created by Kostiantyn Tkachov on 30.01.17.
//  Copyright © 2017 Kostiantyn Tkachov. All rights reserved.
//

import CoreBluetooth

class BleDevice : NSObject, CBPeripheralDelegate
{
    enum StatusConnectionEnum {
        case Disconnected
        case Connected
    }
    
    var StatusConnection : StatusConnectionEnum = .Disconnected
    
    var peripheral : CBPeripheral
    var RSSI : NSNumber
    
    var UnixTimeChar : CBCharacteristic?
    
    init(peripheral : CBPeripheral, RSSINumber : NSNumber)
    {
        self.peripheral = peripheral
        self.RSSI = RSSINumber
        super.init()
        peripheral.delegate = self
        print("Inited Periph")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services!
        {
            print ("Found Service \(service)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    {
        for i in service.characteristics!
        {
            print ("Found Characteristic \(i)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
    {
        print("Update Value for Characterictic")
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        self.RSSI = RSSI
        NotificationCenter.default.post(name: RCNotifications.ReadedRSSI, object: nil)
    }
    
    func UpdateRSSI()
    {
        self.peripheral.readRSSI()
    }
}
