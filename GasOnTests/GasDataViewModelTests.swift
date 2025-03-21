//
//  GasDataViewModelTests.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 21/03/25.
//

import XCTest
@testable import GasOn

class GasDataViewModelTests: XCTestCase {
    var viewModel: GasDataViewModel!
    var mockUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        mockUserDefaults = UserDefaults(suiteName: #file)
        mockUserDefaults.removePersistentDomain(forName: #file)
        viewModel = GasDataViewModel(userDefaults: mockUserDefaults)
        viewModel.errorMessage = nil
    }

    func testGasStartDateOnDataReceive() {
        let expectation = self.expectation(description: "Data saved")
        viewModel.handleNewData("75")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("[DEBUG] Conteúdo do UserDefaults mockado: \(self.mockUserDefaults.dictionaryRepresentation())")
            XCTAssertNotNil(
                self.mockUserDefaults.object(forKey: UserDefaults.Keys.gasStartDate),
                "A data deve estar salva no UserDefaults"
            )
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2) 
    }
    
    func testInvalidDataHandling() {
        let expectation = self.expectation(description: "Error message updated")
        viewModel.handleNewData("ABC")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.errorMessage, "Erro ao interpretar os dados recebidos.")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
}
