//
//  DeviceListView.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 30/09/24.
//

import SwiftUI

struct DeviceListView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    var filteredPeripherals: [PeripheralInfo]
    
    var body: some View {
        List {
            Section(header: deviceSectionHeader) {
                ForEach(filteredPeripherals, id: \.peripheral.identifier) { peripheralInfo in
                    DeviceRow(name: peripheralInfo.peripheral.name ?? "Desconhecido",
                              status: peripheralInfo.isConnected ? "Conectado" : "Não Conectado")
                        .onTapGesture {
                            if peripheralInfo.isConnected {
                                bluetoothManager.disconnect(peripheralInfo)
                            } else {
                                bluetoothManager.connect(peripheralInfo)
                            }
                        }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .listRowInsets(EdgeInsets())
    }

    private var deviceSectionHeader: some View {
        Text("DISPOSITIVOS")
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.top, 5)
            .padding(.leading, 5)
    }
}
