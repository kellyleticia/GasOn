//
//  BluetoothManager.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 24/08/24.
//

import CoreBluetooth
import Combine

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    
    private let serviceUUID = CBUUID(string: "F1F1")
    private let characteristicUUID = CBUUID(string: "F1F2")
    
    @Published var isBluetoothEnabled = false
    @Published var discoveredPeripherals = [PeripheralInfo]()
    @Published var receivedData: String = ""
    @Published var receivedPercentage: Float?
    @Published var gasStartDate: Date?
    @Published var gasEndDate: Date?
    
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var dataBuffer = Data()
    
    private let targetDeviceName = "gas_on"

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
        guard peripheralInfo.peripheral.state != .connected else { return }
        
        // Disconnect existing connection
        if let currentConnected = connectedPeripheral {
            centralManager.cancelPeripheralConnection(currentConnected)
        }
        
        connectedPeripheral = peripheralInfo.peripheral
        connectedPeripheral?.delegate = self
        centralManager.connect(peripheralInfo.peripheral)
    }

    func disconnect(_ peripheralInfo: PeripheralInfo) {
        centralManager.cancelPeripheralConnection(peripheralInfo.peripheral)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            isBluetoothEnabled = true
            let scanOptions: [String: Any] = [
                CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: true)
            ]
            centralManager.scanForPeripherals(withServices: nil, options: scanOptions)
            
        case .poweredOff:
            isBluetoothEnabled = false
            centralManager.stopScan()
            
        case .resetting, .unauthorized, .unsupported, .unknown:
            isBluetoothEnabled = false
            
        @unknown default:
            isBluetoothEnabled = false
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        let targetDeviceName = "gas_on"
        
        // Usa advertisementData para buscar o nome local se peripheral.name estiver nulo
        let peripheralName = peripheral.name ?? (advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "desconhecido")
        
        guard peripheralName == targetDeviceName else {
            print("Dispositivo \(peripheralName) não é o dispositivo alvo.")
            return
        }
        
        // Se já foi adicionado, não tenta conectar novamente
        if discoveredPeripherals.contains(where: { $0.peripheral == peripheral }) {
            return
        }
        
        print("Dispositivo específico encontrado: \(peripheralName)")
        let peripheralInfo = PeripheralInfo(peripheral: peripheral, isConnected: false)
        discoveredPeripherals.append(peripheralInfo)
        connect(peripheralInfo)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("DID CONNECT TO \(peripheral.name ?? "unknown")")
        // Para o scan para reduzir interferência
        centralManager.stopScan()
        
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

    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        print("DID DISCONNECT FROM \(peripheral.name ?? "unknown")")
        
        if let index = discoveredPeripherals.firstIndex(where: { $0.peripheral == peripheral }) {
            discoveredPeripherals[index].isConnected = false
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
        connectedPeripheral = nil
        
        // Reinicia o scan para tentar reconectar
        let scanOptions: [String: Any] = [
            CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: true)
        ]
        centralManager.scanForPeripherals(withServices: nil, options: scanOptions)
        
        // Se for o dispositivo alvo, tenta reconectar
        let peripheralName = peripheral.name ?? "desconhecido"
        if peripheralName == targetDeviceName {
            print("Tentando reconectar \(peripheralName)")
            connect(PeripheralInfo(peripheral: peripheral, isConnected: false))
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            } else if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
        }
    }

    private func enableNotifications(for characteristic: CBCharacteristic, peripheral: CBPeripheral) {
        peripheral.setNotifyValue(true, for: characteristic)
        
        if let descriptors = characteristic.descriptors,
           let cccd = descriptors.first(where: { $0.uuid == CBUUID(string: "2902") }) {
            
            print("Escrevendo 0x0100 no CCCD...")
            peripheral.writeValue(Data([0x01, 0x00]), for: cccd)
            
        } else {
            print("CCCD não encontrado. Descobrindo descritores...")
            peripheral.discoverDescriptors(for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverDescriptorsFor characteristic: CBCharacteristic,
                    error: Error?) {
        
        if let error = error {
            print("Erro ao descobrir descritores: \(error.localizedDescription)")
            return
        }
        
        if let cccd = characteristic.descriptors?.first(where: { $0.uuid == CBUUID(string: "2902") }) {
            print("CCCD encontrado após descoberta. Habilitando notificações...")
            peripheral.writeValue(Data([0x01, 0x00]), for: cccd)
        }
    }

    // Adicione este método para verificar erros na escrita do CCCD
    func peripheral(_ peripheral: CBPeripheral,
                    didWriteValueFor descriptor: CBDescriptor,
                    error: Error?) {
        
        if let error = error {
            print("Falha ao escrever no CCCD: \(error.localizedDescription)")
        } else {
            print("Notificações habilitadas com sucesso!")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        
        if let error = error {
            print("Erro ao receber dados: \(error.localizedDescription)")
            return
        }
        
        guard let data = characteristic.value else {
            print("Dados vazios")
            return
        }
        
        let rawString = String(data: data, encoding: .utf8) ?? "Inválido"
        print("Dados brutos recebidos: \(rawString)")
        
        handleReceivedData(rawString)
    }
    
    private func handleReceivedData(_ stringValue: String) {
        let numericString = stringValue
            .replacingOccurrences(of: "%", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let percentage = Float(numericString) else {
            print("Failed to convert value: \(stringValue)")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Atualiza os dados
            self.receivedPercentage = percentage
            
            // Gerencia datas
            if self.gasStartDate == nil {
                self.gasStartDate = Date()
                UserDefaults.standard.set(self.gasStartDate, forKey: BluetoothKeys.gasStartDate)
            }
            
            UserDefaults.standard.set(percentage, forKey: BluetoothKeys.lastKnownPercentage)
            self.updateEstimatedEndDate()
        }
    }

    private func updateEstimatedEndDate() {
        guard let startDate = gasStartDate,
              let initialPercentage = receivedPercentage,
              let currentPercentage = receivedPercentage else {
            return
        }
        
        let elapsedTime = Date().timeIntervalSince(startDate) / (60 * 60 * 24)
        let consumptionRate = (initialPercentage - currentPercentage) / Float(elapsedTime)

        if consumptionRate > 0 {
            let remainingDays = currentPercentage / consumptionRate
            gasEndDate = Calendar.current.date(byAdding: .day, value: Int(remainingDays), to: Date())
            UserDefaults.standard.saveGasEndDate(gasEndDate!)
        }
    }
}
