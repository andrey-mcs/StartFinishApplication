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
    
    var TimeStartData :     Array< UInt32 >!
    var TimeFinishData:     Array< UInt32 >!
    var TimeResultData :    Array< UInt32 >!
    var IdSkierData : UInt32!
    var SystemStatusData :  Array< UInt32 >!
    var unixTimeData : UInt32!
    
    var numSkierOnWay : UInt32!
    var maxSkierOnWay : UInt32!
    
    var Notify : Bool
    
    
    init(peripheral : CBPeripheral, RSSINumber : NSNumber)
    {
        self.peripheral = peripheral
        self.RSSI = RSSINumber
        self.Notify = false
        
        self.TimeStartData = Array()
        self.TimeFinishData = Array()
        self.TimeResultData = Array()
        self.SystemStatusData = Array()
        
        
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
        }

    }
    
    func allCharacteristicDiscover() -> Bool
    {
        if ((IdSkier != nil ) && (TimeStart != nil) && (TimeFinish != nil) && (TimeResult != nil)  &&
            (SystemStatus != nil) && (unixTime != nil))
        {
            return true
        }
        else
        {
            return false
        }
    }

    func allCharacteristicSetted() -> Bool
    {
        if ((IdSkierData != nil ) && (TimeStartData.count > 0) && (TimeFinishData.count > 0) && (TimeResultData.count > 0) && (SystemStatusData.count > 0)
            //&& (unixTimeData != nil)
            && (numSkierOnWay != nil) && (maxSkierOnWay != nil))
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
        SystemStatus = nil
        unixTime = nil
        
        IdSkierData = nil
        TimeStartData.removeAll()
        TimeFinishData.removeAll()
        TimeResultData.removeAll()
        SystemStatusData.removeAll()
        unixTimeData = nil
        
        maxSkierOnWay = nil
        numSkierOnWay = nil
        
        Notify = false
        
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
        //print ("\(characteristic)")
        
        // hour 0 min 1 sec 2 ms 3
        if (characteristic.value != nil)
        {
            switch characteristic.uuid {
                case CBUUID( string: CBUUIDs.ID_UUID):

                    var tmpId : UInt16 = 0
                    (characteristic.value! as NSData).getBytes(&tmpId, range: NSRange(location: 0, length: 2))
                    IdSkierData = UInt32(tmpId)
                    //print("Id = \(IdSkierData!)")
                case CBUUID( string: CBUUIDs.timeStart):

                    var Hour : UInt16 = 0
                    var Min : UInt16 = 0
                    var Sec : UInt16 = 0
                    var Ms : UInt16 = 0
                    (characteristic.value! as NSData).getBytes(&Hour, range: NSRange(location: 0, length: 2))
                    (characteristic.value! as NSData).getBytes(&Min, range: NSRange(location: 2, length: 2))
                    (characteristic.value! as NSData).getBytes(&Sec, range: NSRange(location: 4, length: 2))
                    (characteristic.value! as NSData).getBytes(&Ms, range: NSRange(location: 6, length: 2))
                    if (TimeStartData.count < 4)
                    {
                        TimeStartData.removeAll()
                        TimeStartData.append(UInt32(Hour))
                        TimeStartData.append(UInt32(Min))
                        TimeStartData.append(UInt32(Sec))
                        TimeStartData.append(UInt32(Ms))
                    }
                    TimeStartData[0] = (UInt32(Hour))
                    TimeStartData[1] = (UInt32(Min))
                    TimeStartData[2] = (UInt32(Sec))
                    TimeStartData[3] = (UInt32(Ms))
                    
                    NotificationCenter.default.post(name: RCNotifications.TimeStartArrived, object: nil)

                    
                    print (String(format: "Start: %02d:%02d:%02d:%03d", Hour, Min, Sec, Ms))
          
                case CBUUID( string: CBUUIDs.timeFinish):

                    var Hour : UInt16 = 0
                    var Min : UInt16 = 0
                    var Sec : UInt16 = 0
                    var Ms : UInt16 = 0
                    (characteristic.value! as NSData).getBytes(&Hour, range: NSRange(location: 0, length: 2))
                    (characteristic.value! as NSData).getBytes(&Min, range: NSRange(location: 2, length: 2))
                    (characteristic.value! as NSData).getBytes(&Sec, range: NSRange(location: 4, length: 2))
                    (characteristic.value! as NSData).getBytes(&Ms, range: NSRange(location: 6, length: 2))
                    if (TimeFinishData.count < 4)
                    {
                        TimeFinishData.removeAll()
                        TimeFinishData.append(UInt32(Hour))
                        TimeFinishData.append(UInt32(Min))
                        TimeFinishData.append(UInt32(Sec))
                        TimeFinishData.append(UInt32(Ms))
                    }
                    TimeFinishData[0] = (UInt32(Hour))
                    TimeFinishData[1] = (UInt32(Min))
                    TimeFinishData[2] = (UInt32(Sec))
                    TimeFinishData[3] = (UInt32(Ms))
                
                    print (String(format: "Finish: %02d:%02d:%02d:%03d", Hour, Min, Sec, Ms))
            
                case CBUUID( string: CBUUIDs.timeResult):
                    var Hour : UInt16 = 0
                    var Min : UInt16 = 0
                    var Sec : UInt16 = 0
                    var Ms : UInt16 = 0
                    (characteristic.value! as NSData).getBytes(&Hour, range: NSRange(location: 0, length: 2))
                    (characteristic.value! as NSData).getBytes(&Min, range: NSRange(location: 2, length: 2))
                    (characteristic.value! as NSData).getBytes(&Sec, range: NSRange(location: 4, length: 2))
                    (characteristic.value! as NSData).getBytes(&Ms, range: NSRange(location: 6, length: 2))
                    if (TimeResultData.count < 4)
                    {
                        TimeResultData.removeAll()
                        TimeResultData.append(UInt32(Hour))
                        TimeResultData.append(UInt32(Min))
                        TimeResultData.append(UInt32(Sec))
                        TimeResultData.append(UInt32(Ms))
                    }
                    TimeResultData[0] = (UInt32(Hour))
                    TimeResultData[1] = (UInt32(Min))
                    TimeResultData[2] = (UInt32(Sec))
                    TimeResultData[3] = (UInt32(Ms))
                
                    print (String(format: "Result: %02d:%02d:%02d:%03d", Hour, Min, Sec, Ms))
                    if ((TimeStartData.count == 4) && (TimeFinishData.count == 4))
                    {
                        NotificationCenter.default.post(name: RCNotifications.TimeSkierArrived, object: nil)
                    }

                case CBUUID( string: CBUUIDs.systemStatus):

                    var Status : UInt16 = 0
                    var Network : UInt16 = 0
                    var Card : UInt16 = 0
                    var numSkier : UInt16 = 0
                    var maxSkier: UInt16 = 0

                    (characteristic.value! as NSData).getBytes(&Status, range: NSRange(location: 0, length: 1))
                    (characteristic.value! as NSData).getBytes(&Network, range: NSRange(location: 1, length: 1))
                    (characteristic.value! as NSData).getBytes(&Card, range: NSRange(location: 2, length: 1))
                    (characteristic.value! as NSData).getBytes(&numSkier, range: NSRange(location: 3, length: 1))
                    (characteristic.value! as NSData).getBytes(&maxSkier, range: NSRange(location: 4, length: 1))

                    if (SystemStatusData.count < 3)
                    {
                        SystemStatusData.removeAll()
                        SystemStatusData.append(UInt32(Status))
                        SystemStatusData.append(UInt32(Network))
                        SystemStatusData.append(UInt32(Card))
                    }
                    SystemStatusData[0] = (UInt32(Status))
                    SystemStatusData[1] = (UInt32(Network))
                    SystemStatusData[2] = (UInt32(Card))
                
                    maxSkierOnWay = UInt32(maxSkier)
                    numSkierOnWay = UInt32(numSkier)

                    print ("Status : \(Status):\(Network):\(Card)[\(numSkierOnWay!)/\(maxSkierOnWay!)]")
              
                
                default: break
            }
        
        }
        
        if ((IdSkierData != nil ) && (TimeStartData.count > 0) && (TimeFinishData.count > 0) && (TimeResultData.count > 0) && (SystemStatusData.count > 0)
            //&& (unixTimeData != nil)
            && (numSkierOnWay != nil) && (maxSkierOnWay != nil) && (Notify == false))
        {
            Notify = true
            print("BLE: All Discovered")
            NotificationCenter.default.post(name: RCNotifications.AllSkierCharacterisrticDiscovered, object: nil)
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
