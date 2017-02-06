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
                
                peripheral.setNotifyValue(true, for: characteristic)
                //peripheral.readValue(for: IdSkier!)
                
                print ("IdSkier : \(IdSkier!)")
                
                print ("\(characteristic.uuid) : idNotify -- \(characteristic.isNotifying)")
                
                //print("\(characteristic)")
                
                //if let data = characteristic.value
                //{
                //    var data = characteristic.value!
                //    var bytes = Array(repeating : 0 as UInt8, count: 8)
                //    data.copyBytes(to: &bytes, count: data.count)
                //    let Data64 = bytes.map{UInt64($0)}
                //    print ("Hmmm... 1: \(Data64[1]) 0: \(Data64[0])")
                //}
                
                
            case CBUUID(string: CBUUIDs.timeStart) :
                TimeStart = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                print ("\(characteristic.uuid) : idNotify -- \(characteristic.isNotifying)")
            case CBUUID(string: CBUUIDs.timeFinish) :
                TimeFinish = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                print ("\(characteristic.uuid) : idNotify -- \(characteristic.isNotifying)")
           case CBUUID(string: CBUUIDs.timeResult) :
                TimeResult = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                print ("\(characteristic.uuid) : idNotify -- \(characteristic.isNotifying)")
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
    var x = 0
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
    {
        if x <= 9
        {
            x = x + 1
            print ("\(characteristic.uuid) : idNotify -- \(characteristic.isNotifying), x = \(x)")
        }
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
