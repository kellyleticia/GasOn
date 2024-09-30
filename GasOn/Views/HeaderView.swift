//
//  HeaderView.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 08/09/24.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack {
            DateInfoView(title: "Início de Uso", date: "04/06/2024", color: .blueDefault)
            Spacer()
            DateInfoView(title: "Fim de Uso", date: "04/07/2024", color: .redDefault)
        }
        .padding(30)
        .background(Color.darkGrayDefault)
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 40)
    }
}
