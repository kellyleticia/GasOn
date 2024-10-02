//
//  HeaderView.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 08/09/24.
//

import SwiftUI

struct HeaderView: View {
    @ObservedObject var bluetoothManager: BluetoothManager

    var body: some View {
        HStack {
            DateInfoView(title: "Início de Uso", date: formattedDate(bluetoothManager.gasStartDate), color: .blueDefault)
            Spacer()
            DateInfoView(title: "Fim de Uso", date: formattedDate(bluetoothManager.gasEndDate), color: .redDefault)
        }
        .padding(30)
        .background(Color.darkGrayDefault)
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 40)
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none 
        return formatter.string(from: date)
    }
}
