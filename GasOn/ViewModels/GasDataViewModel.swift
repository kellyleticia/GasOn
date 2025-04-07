//
//  GasDataViewModel.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 21/03/25.
//

import Combine
import Foundation

class GasDataViewModel: ObservableObject {
    @Published var receivedPercentage: Float?
    @Published var gasStartDate: Date?
    @Published var gasEndDate: Date?
    @Published var errorMessage: String?
    
    private let bluetoothService: BluetoothService
    private let userDefaults: UserDefaults
    private var cancellables = Set<AnyCancellable>()
    
    init(bluetoothService: BluetoothService = BluetoothService(),
         userDefaults: UserDefaults = .standard) {
        self.bluetoothService = bluetoothService
        self.userDefaults = userDefaults
        print("[DEBUG] UserDefaults em uso: \(userDefaults == UserDefaults.standard ? "Padrão" : "Mockado")")
        loadInitialData()
    }
    
    private func loadInitialData() {
        gasStartDate = userDefaults.object(forKey: UserDefaults.Keys.gasStartDate) as? Date
        receivedPercentage = userDefaults.object(forKey: UserDefaults.Keys.lastKnownPercentage) as? Float
        gasEndDate = userDefaults.object(forKey: UserDefaults.Keys.gasEndDate) as? Date
    }
    
    func handleNewData(_ stringValue: String) {
        let numericString = stringValue
            .replacingOccurrences(of: "%", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let percentage = Float(numericString) else {
            DispatchQueue.main.async {
                self.errorMessage = "Erro ao interpretar os dados recebidos."
            }
            return
        }
        
        DispatchQueue.main.async {
            self.receivedPercentage = percentage
            if self.gasStartDate == nil {
                self.gasStartDate = Date()
                print("[DEBUG] Salvando gasStartDate no UserDefaults: \(self.gasStartDate!)")
                self.userDefaults.set(self.gasStartDate, forKey: UserDefaults.Keys.gasStartDate)
            }
            self.userDefaults.set(percentage, forKey: UserDefaults.Keys.lastKnownPercentage)
            self.updateEstimatedEndDate()
        }
    }

    private func updateEstimatedEndDate() {
        guard let startDate = gasStartDate, let currentPercentage = receivedPercentage else {
            return
        }
        
        let elapsedTime = Date().timeIntervalSince(startDate) / (60 * 60 * 24)
        
        if elapsedTime < 0.01 {
            userDefaults.removeObject(forKey: UserDefaults.Keys.gasEndDate)
            return
        }
        
        let initialPercentage: Float = 100
        let consumptionRate = (initialPercentage - currentPercentage) / Float(elapsedTime)
        
        if consumptionRate > 0 {
            let remainingDays = currentPercentage / consumptionRate
            gasEndDate = Calendar.current.date(byAdding: .day, value: Int(remainingDays), to: Date())
            userDefaults.removeObject(forKey: UserDefaults.Keys.gasEndDate)
        } else {
            gasEndDate = nil
            userDefaults.removeObject(forKey: UserDefaults.Keys.gasEndDate)
        }
    }
    
    func resetForNewCylinder() {
        receivedPercentage = nil
        gasStartDate = nil
        gasEndDate = nil

        userDefaults.removeObject(forKey: UserDefaults.Keys.gasStartDate)
        userDefaults.removeObject(forKey: UserDefaults.Keys.lastKnownPercentage)
        userDefaults.removeObject(forKey: UserDefaults.Keys.gasEndDate)
    }
}
