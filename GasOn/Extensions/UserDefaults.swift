//
//  UserDefaults.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 02/10/24.
//

import Foundation

import Foundation

extension UserDefaults {
    enum Keys {
        static let gasStartDate = "gasStartDate"
        static let gasEndDate = "gasEndDate"
        static let lastKnownPercentage = "lastKnownPercentage"
    }
    func saveGasStartDate(_ date: Date) {
        set(date, forKey: Keys.gasStartDate)
    }

    func getGasStartDate() -> Date? {
        return object(forKey: Keys.gasStartDate) as? Date
    }

    func saveLastKnownPercentage(_ percentage: Float) {
        set(percentage, forKey: Keys.lastKnownPercentage)
    }

    func getLastKnownPercentage() -> Float? {
        return float(forKey: Keys.lastKnownPercentage)
    }
    
    func saveGasEndDate(_ date: Date) {
        set(date, forKey: Keys.gasEndDate)
    }

    func getGasEndDate() -> Date? {
        return object(forKey: Keys.gasEndDate) as? Date
    }
}
