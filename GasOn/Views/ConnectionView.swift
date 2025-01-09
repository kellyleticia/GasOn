//
//  ConnectionView.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 15/09/24.
//

import SwiftUI

struct ConnectionView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            content
        }
        .navigationBarTitle("Bluetooth", displayMode: .inline)
    }
    
    private var content: some View {
        VStack {
            bluetoothStatusView
            
            if bluetoothManager.isBluetoothEnabled {
                DeviceListView(bluetoothManager: bluetoothManager, filteredPeripherals: filteredPeripherals)

                if let percentage = bluetoothManager.receivedPercentage {
                    GasLevelView(percentage: percentage)
                        .padding()
                }
            } else {
                Text("Ligue o Bluetooth para ver os dispositivos.")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }
    
    private var bluetoothStatusView: some View {
        HStack {
            Text(bluetoothManager.isBluetoothEnabled ? "" : "Bluetooth desligado")
                .foregroundColor(.white)
                .font(.title3)
        }
    }

    private var filteredPeripherals: [PeripheralInfo] {
        bluetoothManager.discoveredPeripherals.filter {
            $0.peripheral.name != nil && !$0.peripheral.name!.isEmpty
        }
    }
}

#Preview {
    ConnectionView()
}
