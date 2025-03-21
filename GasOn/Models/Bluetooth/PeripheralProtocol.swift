//
//  PeripheralProtocol.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 21/03/25.
//

import CoreBluetooth

public protocol PeripheralProtocol {
    var name: String? { get }
    var identifier: UUID { get }
    var state: CBPeripheralState { get }
}

extension CBPeripheral: PeripheralProtocol {
    public override var identifier: UUID {
        return super.identifier 
    }
}
