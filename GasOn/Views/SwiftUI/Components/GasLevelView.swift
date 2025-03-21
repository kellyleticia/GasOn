//
//  GasLevelView.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 08/09/24.
//

import SwiftUI

struct GasLevelView: View {
    var percentage: Float
    
    private var gasImage: String {
        switch percentage {
        case 90...100:
            return "BlueGas"
        case 50..<90:
            return "YellowGas"
        case 0..<50:
            return "RedGas"
        default:
            return "BlueGas"
        }
    }

    var body: some View {
        ZStack {
            Image(gasImage)
                .padding(.bottom, 50)
        }
    }
}
