//
//  HomeView.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 03/09/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: GasDataViewModel
     
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    HeaderView()
                    Spacer()
                    GasLevelView(percentage: viewModel.receivedPercentage ?? 0)
                    Spacer()
                }
            }
            .navigationBarTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: LeadingNavigationItem(), trailing: TrailingNavigationItem())
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    HomeView()
        .environmentObject(GasDataViewModel()) 
}
