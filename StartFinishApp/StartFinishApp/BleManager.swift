//
//  BleManager.swift
//  StartFinishApp
//
//  Created by Kostiantyn Tkachov on 30.01.17.
//  Copyright © 2017 Kostiantyn Tkachov. All rights reserved.
//

import CoreBluetooth
import Foundation

class BleManager : NSObject, CBCentralManagerDelegate
{
    
    var counter = 0
    
    var centralManager : CBCentralManager!
    private var listPeriphs = [BleDevice]()
    
    private var bleReady = false
    
    func startUpCentralManager()
    {
        print("Starting Up...")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func discoverDevices()
    {
        print("Discovering Devices")
        print("\(CBUUIDs.sfSystem)")
        centralManager.scanForPeripherals(withServices: [CBUUID(string:CBUUIDs.sfSystem)], options: [CBCentralManagerScanOptionAllowDuplicatesKey : false])
    }
    
    func connectToDevice(peripheral : CBPeripheral)
    {
        print("Connecting")
        centralManager.connect(peripheral, options: nil)
    }
    
    func disconnectDevice(peripheral : CBPeripheral)
    {
        print("Disconnecting")
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        
        if searchDevices(peripheral: peripheral) == nil
        {
            print("Find new service, Periph: \(peripheral.identifier), \(peripheral.name!) ,RSSI : \(RSSI)")
            let tmpDevice = BleDevice(peripheral: peripheral, RSSINumber: RSSI)
            listPeriphs.append(tmpDevice)
            
            NotificationCenter.default.post(name: RCNotifications.FoundDevice, object: nil)
        }
        
    }
    
    func centralManager(_ central : CBCentralManager, didDisconnectPeripheral peripheral : CBPeripheral, error : Error?)
    {
        listPeriphs[searchDevices(peripheral: peripheral)!].StatusConnection = .Disconnected
        print("Disconnected")
        listPeriphs[searchDevices(peripheral: peripheral)!].clearCharacteristics()
        BLE.centralManager.stopScan()
        NotificationCenter.default.post(name: RCNotifications.DisconnectedDevice, object: nil)
    }
    
    func centralManager(_ central : CBCentralManager, didConnect peripheral : CBPeripheral)
    {
        listPeriphs[searchDevices(peripheral: peripheral)!].StatusConnection = .Connected
        print("Connected")
        peripheral.discoverServices(nil)
        BLE.centralManager.stopScan()
        NotificationCenter.default.post(name: RCNotifications.ConnectedDevice, object: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to Connect")
    }
    
    func searchDevices(peripheral : CBPeripheral) -> Int?
    {
        print("SearchDevice")
        for i in 0..<listPeriphs.count
        {
            if listPeriphs[i].peripheral == peripheral
            {
                return i
            }
        }
        return nil
    }
    
    func refreshRSSI()
    {
        print("RefreshRSSI")
        for i in 0 ..< listPeriphs.count
        {
            listPeriphs[i].UpdateRSSI()
        }
    }
    
    func getDeviceForIndex(Index : Int) -> BleDevice
    {
        return listPeriphs[Index]
    }
    
    func getCountDevices() -> Int
    {
        print("ListPeriphs")
        return listPeriphs.count
    }
    
    @objc func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        switch central.state {
            case .poweredOff: break
            case .poweredOn: bleReady = true
            case .resetting : break
            case .unauthorized : break
            case .unknown : break
            case .unsupported : break
        }
        
        if (bleReady)
        {
            print ("BLE Ready")
            discoverDevices()
        }
        
    }
    
    
}
