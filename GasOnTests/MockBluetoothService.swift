//
//  MockBluetoothService.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 21/03/25.
//

import XCTest
@testable import GasOn
import CoreBluetooth

class MockBluetoothService: BluetoothProtocol {
    var discoveredPeripherals: [PeripheralInfo] = []
    var isBluetoothEnabled: Bool = true
    var onPeripheralsUpdated: (() -> Void)?
    
    var connectedPeripheral: PeripheralInfo?
    var disconnectedPeripheral: PeripheralInfo?
    
    func connect(_ peripheral: PeripheralInfo) {
        connectedPeripheral = peripheral
        discoveredPeripherals = discoveredPeripherals.map {
            var updated = $0
            updated.isConnected = ($0.peripheral.identifier == peripheral.peripheral.identifier)
            return updated
        }
        onPeripheralsUpdated?()
    }
    
    func disconnect(_ peripheral: PeripheralInfo) {
        disconnectedPeripheral = peripheral
        discoveredPeripherals = discoveredPeripherals.map {
            var updated = $0
            updated.isConnected = false
            return updated
        }
        onPeripheralsUpdated?()
    }
    
    func simulateDiscovery(peripherals: [PeripheralInfo]) {
        discoveredPeripherals = peripherals
        onPeripheralsUpdated?()
    }
}
