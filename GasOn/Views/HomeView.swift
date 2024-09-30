//
//  HomeView.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 03/09/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var bluetoothManager = BluetoothManager()

    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    HeaderView()
                    Spacer()
                    GasLevelView(percentage: bluetoothManager.receivedPercentage ?? 0) 
                    Spacer()
                }
            }
            .navigationBarTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: LeadingNavigationItem(), trailing: TrailingNavigationItem())
        }
    }
}

#Preview {
    HomeView()
}
