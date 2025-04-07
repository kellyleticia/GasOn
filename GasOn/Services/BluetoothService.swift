//
//  BluetoothService.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 21/03/25.
//

import CoreBluetooth
import Combine

protocol BluetoothProtocol: AnyObject {
    var discoveredPeripherals: [PeripheralInfo] { get }
    var isBluetoothEnabled: Bool { get }
    func connect(_ peripheral: PeripheralInfo)
    func disconnect(_ peripheral: PeripheralInfo)
    var onPeripheralsUpdated: (() -> Void)? { get set }
}

class BluetoothService: NSObject, ObservableObject, BluetoothProtocol, CBCentralManagerDelegate {
    @Published var discoveredPeripherals = [PeripheralInfo]()
    @Published var isBluetoothEnabled = false
    var onPeripheralsUpdated: (() -> Void)?
    
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func peripheralListDidChange() {
        onPeripheralsUpdated?()
        objectWillChange.send() 
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            self.isBluetoothEnabled = (central.state == .poweredOn)
        }
        
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: true)])
        } else {
            centralManager.stopScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        let peripheralInfo = PeripheralInfo(
            peripheral: peripheral as PeripheralProtocol,
            isConnected: false
        )
        
        if !discoveredPeripherals.contains(where: {
            $0.peripheral.identifier == peripheral.identifier
        }) {
            DispatchQueue.main.async {
                self.discoveredPeripherals.append(peripheralInfo)
            }
        }
    }
    
    func connect(_ peripheral: PeripheralInfo) {
        guard peripheral.peripheral.state != .connected else { return }
        
        if let currentConnected = connectedPeripheral {
            centralManager.cancelPeripheralConnection(currentConnected)
        }
        
        connectedPeripheral = peripheral.peripheral as? CBPeripheral
        centralManager.connect(peripheral.peripheral as! CBPeripheral)
    }

    func disconnect(_ peripheral: PeripheralInfo) {
        centralManager.cancelPeripheralConnection(peripheral.peripheral as! CBPeripheral)
    }
}
