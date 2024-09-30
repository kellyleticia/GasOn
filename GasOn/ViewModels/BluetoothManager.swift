//
//  BluetoothManager.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 24/08/24.
//

import CoreBluetooth
import Combine

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    
    @Published var isBluetoothEnabled = false
    @Published var discoveredPeripherals = [PeripheralInfo]()
    @Published var receivedData: String = ""

    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var dataBuffer = Data()

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func connect(_ peripheralInfo: PeripheralInfo) {
        if let currentConnectedPeripheral = discoveredPeripherals.first(where: { $0.isConnected }) {
            disconnect(currentConnectedPeripheral)
        }
        
        centralManager.connect(peripheralInfo.peripheral)
    }

    func disconnect(_ peripheralInfo: PeripheralInfo) {
        centralManager.cancelPeripheralConnection(peripheralInfo.peripheral)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            isBluetoothEnabled = true
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        case .poweredOff:
            isBluetoothEnabled = false
            centralManager.stopScan()
        case .resetting, .unauthorized, .unsupported, .unknown:
            isBluetoothEnabled = false
        @unknown default:
            isBluetoothEnabled = false
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(where: { $0.peripheral == peripheral }) {
            let newPeripheralInfo = PeripheralInfo(peripheral: peripheral, isConnected: false)
            discoveredPeripherals.append(newPeripheralInfo)
            print("Discovered peripheral: \(peripheral.name ?? "unknown")")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("DID CONNECT TO \(peripheral.name ?? "unknown")")
        
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        connectedPeripheral?.discoverServices(nil)
        
        if let index = discoveredPeripherals.firstIndex(where: { $0.peripheral == peripheral }) {
            discoveredPeripherals[index].isConnected = true
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("DID DISCONNECT FROM \(peripheral.name ?? "unknown")")
        
        if let index = discoveredPeripherals.firstIndex(where: { $0.peripheral == peripheral }) {
            discoveredPeripherals[index].isConnected = false
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
        connectedPeripheral = nil
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            } else if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            let stringValue = String(data: value, encoding: .utf8) ?? "Invalid data"
            dataBuffer.append(value)
            
            if stringValue.contains("Pressure:") {
                DispatchQueue.main.async {
                    self.receivedData = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
    }
}
