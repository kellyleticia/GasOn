//
//  ConnectionView.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 15/09/24.
//

import SwiftUI

struct DeviceListViewWrapper: UIViewControllerRepresentable {
    @EnvironmentObject var bluetoothService: BluetoothService
    
    func makeUIViewController(context: Context) -> DeviceListViewController {
        let viewModel = DeviceListViewModel(bluetoothService: bluetoothService)
        return DeviceListViewController.create(with: viewModel)
    }
    
    func updateUIViewController(_ uiViewController: DeviceListViewController, context: Context) {
        uiViewController.viewModel.updateFilteredPeripherals()
    }
}

struct ConnectionView: View {
    @EnvironmentObject var bluetoothService: BluetoothService

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
            
            if bluetoothService.isBluetoothEnabled {
                DeviceListViewWrapper()
            } else {
                Text("Ligue o Bluetooth para ver os dispositivos.")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }
    
    private var bluetoothStatusView: some View {
        HStack {
            Text(bluetoothService.isBluetoothEnabled ? "" : "Bluetooth desligado")
                .foregroundColor(.white)
                .font(.title3)
        }
    }
    
    private var filteredPeripherals: [PeripheralInfo] {
        bluetoothService.discoveredPeripherals.filter {
            $0.peripheral.name != nil && !$0.peripheral.name!.isEmpty
        }
    }
}

#Preview {
    ConnectionView()
        .environmentObject(BluetoothService()) 
}
