//
//  DeviceListViewModel.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 21/03/25.
//

import Foundation

class DeviceListViewModel {
    var bluetoothService: BluetoothProtocol 
    var filteredPeripherals: [PeripheralInfo] = []
    
    init(bluetoothService: BluetoothProtocol) {
        self.bluetoothService = bluetoothService
    }
    
    func connectOrDisconnect(_ peripheral: PeripheralInfo) {
        if peripheral.isConnected {
            bluetoothService.disconnect(peripheral)
        } else {
            bluetoothService.connect(peripheral)
        }
    }
    
    func updateFilteredPeripherals() {
        filteredPeripherals = bluetoothService.discoveredPeripherals
            .filter { $0.peripheral.name?.isEmpty == false }
    }
}
