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
    
    
    private var TimeStart : CBCharacteristic?
    private var TimeFinish : CBCharacteristic?
    private var TimeResult : CBCharacteristic?
    private var IdSkier : CBCharacteristic?
    private var SystemStatus : CBCharacteristic?
    private var unixTime : CBCharacteristic?
    
    
    
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
            //print ("Found Characteristic \(characteristic)")
            switch characteristic.uuid {
            case CBUUID(string: CBUUIDs.ID_UUID) :
                IdSkier = characteristic
                print ("\(characteristic.uuid) : idNotify -- \(characteristic.isNotifying)")
            case CBUUID(string: CBUUIDs.timeStart) :
                TimeStart = characteristic
                print ("\(characteristic.uuid) : idNotify -- \(characteristic.isNotifying)")
            case CBUUID(string: CBUUIDs.timeFinish) :
                TimeFinish = characteristic
                print ("\(characteristic.uuid) : idNotify -- \(characteristic.isNotifying)")
           case CBUUID(string: CBUUIDs.timeResult) :
                TimeResult = characteristic
                print ("\(characteristic.uuid) : idNotify -- \(characteristic.isNotifying)")
            case CBUUID(string: CBUUIDs.systemStatus) :
                SystemStatus = characteristic
                print ("\(characteristic.uuid) : idNotify -- \(characteristic.isNotifying)")
            case CBUUID(string: CBUUIDs.sfUnixTime) :
                unixTime = characteristic
                print ("\(characteristic.uuid) : idNotify -- \(characteristic.isNotifying)")
            default:
                print("0")
            }
        }
        
        if ((IdSkier != nil ) && (TimeStart != nil) && (TimeFinish != nil) && (TimeResult != nil) &&
            (SystemStatus != nil) && (unixTime != nil))
        {
            peripheral.setNotifyValue(true, for: IdSkier!)
            peripheral.setNotifyValue(true, for: TimeStart!)
            peripheral.setNotifyValue(true, for: TimeFinish!)
            peripheral.setNotifyValue(true, for: TimeResult!)
            peripheral.setNotifyValue(true, for: SystemStatus!)
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
    
    func unregisterNotify()
    {

        if IdSkier != nil
        {
            peripheral.setNotifyValue(false, for: IdSkier!)
        }
        if TimeStart != nil
        {
            peripheral.setNotifyValue(false, for: TimeStart!)
        }
        if TimeFinish != nil
        {
            peripheral.setNotifyValue(false, for: TimeFinish!)
        }
        if TimeResult != nil
        {
            peripheral.setNotifyValue(false, for: TimeResult!)
        }
        if SystemStatus != nil
        {
            peripheral.setNotifyValue(false, for: SystemStatus!)
        }
        if unixTime != nil
        {
            peripheral.setNotifyValue(false, for: unixTime!)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
    {
        print ("\(characteristic.uuid) : idNotify -- \(characteristic.isNotifying)")
        //print("Update Value for Characterictic\(characteristic)")
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
