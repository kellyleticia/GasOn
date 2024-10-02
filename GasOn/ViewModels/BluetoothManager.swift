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
    @Published var receivedPercentage: Float?
    @Published var gasStartDate: Date?
    @Published var gasEndDate: Date?

    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var dataBuffer = Data()

    struct BluetoothKeys {
        static let gasStartDate = "gasStartDate"
        static let lastKnownPercentage = "lastKnownPercentage"
        static let gasEndDate = "gasEndDate"
    }

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func resetForNewGasCylinder() {
        self.receivedPercentage = nil
        self.gasStartDate = nil
        self.gasEndDate = nil

        UserDefaults.standard.removeObject(forKey: BluetoothKeys.gasStartDate)
        UserDefaults.standard.removeObject(forKey: BluetoothKeys.lastKnownPercentage)
        UserDefaults.standard.removeObject(forKey: BluetoothKeys.gasEndDate)

        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
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
            handleReceivedData(stringValue)
        }
    }

    private func handleReceivedData(_ stringValue: String) {
        if stringValue.contains("Peso:") {
            if let weightString = stringValue.split(separator: ":").last?.trimmingCharacters(in: .whitespacesAndNewlines),
               let weight = Float(weightString),
               let lastPercentage = receivedPercentage, weight > 80 {
                resetForNewGasCylinder()
            }
        }
        
        if stringValue.contains("Peso percentual:") {
            if let percentageString = stringValue.split(separator: ":").last?.trimmingCharacters(in: .whitespacesAndNewlines),
               let percentage = Float(percentageString.replacingOccurrences(of: "%", with: "")) {
                DispatchQueue.main.async {
                    self.receivedPercentage = percentage
                    if self.gasStartDate == nil {
                        self.gasStartDate = Date()
                        UserDefaults.standard.saveGasStartDate(self.gasStartDate!)
                    }
                    UserDefaults.standard.saveLastKnownPercentage(percentage)
                    self.estimateGasEndDate(percentage: percentage)
                }
            }
        }
        
        if stringValue.contains("Pressure:") {
            DispatchQueue.main.async {
                self.receivedData = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }

    private func estimateGasEndDate(percentage: Float) {
        let estimatedDaysRemaining = percentage / 1.0
        let estimatedEndDate = Calendar.current.date(byAdding: .day, value: Int(estimatedDaysRemaining), to: Date())

        if let endDate = estimatedEndDate {
            self.gasEndDate = endDate
            UserDefaults.standard.saveGasEndDate(endDate)
        }
    }
}
