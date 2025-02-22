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
        case 80...100:
            return "BlueGas"
        case 20..<80:
            return "YellowGas"
        case 0..<20:
            return "RedGas"
        default:
            return "BlueGas"
        }
    }

    var body: some View {
        ZStack {
            Image(gasImage)
                .padding(.bottom, 50)
//            Text("\(percentage, specifier: "%.0f")%")
//                .foregroundColor(.white)
//                .font(.system(size: 35, weight: .semibold, design: .rounded))
//                .padding(.top, 120)
        }
    }
}
