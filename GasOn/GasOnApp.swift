//
//  GasOnApp.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 24/08/24.
//

import SwiftUI
import SwiftData

@main
struct GasOnApp: App {
    @StateObject private var bluetoothManager = BluetoothManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        setupNavigationBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bluetoothManager)
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = UIColor.clear
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}
