//
//  UserDefaultTests.swift
//  GasOn
//
//  Created by Kelly Letícia Nascimento de Morais on 21/03/25.
//

import XCTest
@testable import GasOn

class UserDefaultsTests: XCTestCase {
    var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
    }

    func testSaveGasStartDate() {
        let testDate = Date()
        
        userDefaults.saveGasStartDate(testDate)
        
        let savedDate = userDefaults.getGasStartDate()
        
        XCTAssertEqual(testDate, savedDate)
    }

    func testDefaultGasStartDate() {
        let savedDate = userDefaults.getGasStartDate()
        XCTAssertNil(savedDate)
    }
}
