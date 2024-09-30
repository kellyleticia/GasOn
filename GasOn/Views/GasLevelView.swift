//
//  GasLevelView.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 08/09/24.
//

import SwiftUI

struct GasLevelView: View {
    var pressure: String

    var body: some View {
        ZStack {
            Image("BlueGas")
                .padding(.bottom, 50)
            Text(pressure) 
                .foregroundColor(.white)
                .font(.system(size: 35, weight: .semibold, design: .rounded))
                .padding(.top, 120)
        }
    }
}
