//
//  GasLevelView.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 08/09/24.
//

import SwiftUI

struct GasLevelView: View {
    var percentage: Float

    var body: some View {
        ZStack {
            Image("BlueGas")
                .padding(.bottom, 50)
            Text("\(percentage, specifier: "%.0f")%") 
                .foregroundColor(.white)
                .font(.system(size: 35, weight: .semibold, design: .rounded))
                .padding(.top, 120)
        }
    }
}
