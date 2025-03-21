//
//  DeviceListViewModelTests.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 21/03/25.
//

import XCTest
@testable import GasOn
import CoreBluetooth

class MockPeripheral: PeripheralProtocol {
    var name: String?
    var identifier: UUID = UUID()
    var state: CBPeripheralState = .disconnected
}

class DeviceListViewModelTests: XCTestCase {
    var viewModel: DeviceListViewModel!
    var mockBluetoothService: MockBluetoothService!
    
    override func setUp() {
        super.setUp()
        mockBluetoothService = MockBluetoothService()
        viewModel = DeviceListViewModel(bluetoothService: mockBluetoothService)
    }
    
    func testFilteredPeripherals() {
        let peripheralWithName = MockPeripheral()
        peripheralWithName.name = "Sensor"
        
        let peripheralWithoutName = MockPeripheral()
        peripheralWithoutName.name = nil
        
        mockBluetoothService.simulateDiscovery(peripherals: [
            PeripheralInfo(peripheral: peripheralWithName, isConnected: false),
            PeripheralInfo(peripheral: peripheralWithoutName, isConnected: false)
        ])
        
        viewModel.updateFilteredPeripherals()

        XCTAssertEqual(viewModel.filteredPeripherals.count, 1)
        XCTAssertEqual(viewModel.filteredPeripherals.first?.peripheral.name, "Sensor")
    }
}
