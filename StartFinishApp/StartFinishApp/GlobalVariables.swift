//
//  GlobalVariables.swift
//  StartFinishApp
//
//  Created by Kostiantyn Tkachov on 30.01.17.
//  Copyright © 2017 Kostiantyn Tkachov. All rights reserved.
//

import Foundation

struct RCNotifications
{
    static let FoundDevice = Notification.Name("com.atkachov.StartFinishApp.founddevice")
    static let ConnectedDevice = Notification.Name("com.atkachov.StartFinishApp.connecteddevice")
    static let DisconnectedDevice = Notification.Name("com.atkachov.StartFinishApp.disconnecteddevice")
    static let ReadedRSSI = Notification.Name("com.atkachov.StartFinishApp.readedrssi")
    static let AllSkierCharacterisrticDiscovered = Notification.Name("com.atkachov.StartFinishApp.SkierCharDisc")
    static let TimeSkierArrived = Notification.Name("com.atkachov.StartFinishApp.SkierTimeArrived")
}

struct CBUUIDs {
    static let baseUUID = "00000000-0000-1000-8000-00805F9B34F"
    static let sfSystem = CBUUIDs.baseUUID + "0"
    static let ID_UUID = CBUUIDs.baseUUID + "1"
    static let timeStart = CBUUIDs.baseUUID + "2"
    static let timeFinish = CBUUIDs.baseUUID + "3"
    static let timeResult = CBUUIDs.baseUUID + "4"
    static let systemStatus = CBUUIDs.baseUUID + "5"
    static let sfUnixTime = CBUUIDs.baseUUID + "6"
    static let adminIsOnlyUUID = CBUUIDs.baseUUID + "7"
    static let CCCD_UUID = "00002902-0000-1000-8000-00805f9b34fb"
}
