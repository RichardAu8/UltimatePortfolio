//
//  PerformanceTests.swift
//  UltimatePortfolioTests
//
//  Created by RICHARD AU on 10/5/2022.
//

import XCTest
@testable import UltimatePortfolio

class PerformanceTests: BaseTestCase {

    func testAwardCalculationPerformance() throws {
        // Create a significant amount of test data
        for _ in 1...100 {
            try dataController.createSampleData()
        }
        
        // Simulate lots of awards to check
        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        XCTAssertEqual(awards.count, 500, "This checks the awards count is constant.  Change this if you add awards.")
        
        measure {
            awards.filter(dataController.hasEarned).count
        }
        
        //Note: ".. filter() passes each award through a predicate function of our choosing - a test function
        // that should accept one award and return true if it should be included in the result." - Hudson
    }

}
