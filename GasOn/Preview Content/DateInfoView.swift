//
//  DateInfoView.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 08/09/24.
//

import SwiftUI

struct DateInfoView: View {
    let title: String
    let date: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 22, weight: .semibold))
            Text(date)
                .foregroundColor(color)
                .font(.system(size: 22, weight: .semibold))
        }
    }
}

#Preview {
    DateInfoView()
}
