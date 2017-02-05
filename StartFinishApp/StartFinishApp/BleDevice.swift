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
    
    var TimeStart : CBCharacteristic?
    var TimeFinish : CBCharacteristic?
    var TimeResult : CBCharacteristic?
    var IdSkier : CBCharacteristic?
    
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
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    {
        for characteristic in service.characteristics!
        {
            print ("Found Characteristic \(characteristic)")
            switch characteristic.uuid {
            case CBUUID(string: CBUUIDs.ID_UUID) :
                IdSkier = characteristic
            case CBUUID(string: CBUUIDs.timeStart) :
                TimeStart = characteristic
            case CBUUID(string: CBUUIDs.timeFinish) :
                TimeFinish = characteristic
            case CBUUID(string: CBUUIDs.timeResult) :
                TimeResult = characteristic
            default:
                print("0")
            }
        }
        
        if ((IdSkier != nil ) && (TimeStart != nil) && (TimeFinish != nil) && (TimeResult != nil))
        {
            NotificationCenter.default.post(name: RCNotifications.AllSkierCharacterisrticDiscovered, object: nil)
        }

    }
    
    func allCharacteristicDiscover() -> Bool
    {
        if ((IdSkier != nil ) && (TimeStart != nil) && (TimeFinish != nil) && (TimeResult != nil))
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func clearCharacteristics()
    {
        IdSkier = nil
        TimeStart = nil
        TimeFinish = nil
        TimeResult = nil
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
    {
        print("Update Value for Characterictic\(characteristic)")
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
