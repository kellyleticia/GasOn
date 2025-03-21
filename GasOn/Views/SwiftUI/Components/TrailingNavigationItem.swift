//
//  TrailingNavigationItem.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 08/09/24.
//

import SwiftUI

struct TrailingNavigationItem: View {
    var body: some View {
        NavigationLink(destination: ConnectionView()) { 
            Image("BluetoothImage")
                .resizable()
                .scaledToFit()
                .frame(height: 35)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
