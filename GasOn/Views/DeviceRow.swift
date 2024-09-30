//
//  DeviceRow.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 30/09/24.
//
import SwiftUI

struct DeviceRow: View {
    let name: String
    let status: String
    
    var body: some View {
        HStack {
            Text(name)
                .foregroundColor(.white)
            Spacer()
            Text(status)
                .foregroundColor(.gray)
        }
        .listRowBackground(Color.darkGrayDefault)
    }
}
