//
//  ExtensionTests.swift
//  UltimatePortfolioTests
//
//  Created by RICHARD AU on 9/5/2022.
//

import SwiftUI
import XCTest
@testable import UltimatePortfolio

class ExtensionTests: BaseTestCase {
    
    // We didn't use Sequence-Sorting.swift so the tests weren't included here

    func testBundleDecodingAwards() {
        let awards = Bundle.main.decode([Award].self, from: "Awards.json")
        XCTAssertFalse(awards.isEmpty, "Awards.json should decode to a non-empty array.")
    }

    func testDecodingString() {
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode(String.self, from: "DecodableString.json")
        XCTAssertEqual(data, "The rain in Spain falls mainly on the Spaniards.", "The string must match the content of DecodableString.json.")
    }
    
    func testDecodingDictionary() {
        let bundle = Bundle(for: ExtensionTests.self)
        let testDictionary: [String: Int] = ["One": 1, "Two": 2, "Three": 3] // for additional test by RA
        let dataDict = bundle.decode([String: Int].self, from: "DecodableDictionary.json")
        
        XCTAssertEqual(dataDict.count, 3, "There should be three items decoded from DecodableDictionary.json")
        XCTAssertEqual(dataDict["One"], 1, "The dictionary should contain Int to String mappings.")
        // additional test by RA
        XCTAssertEqual(dataDict, testDictionary, "The decoded dictionary should equal the testDictionary")
    }
    
    // we didn't use the extension to binding for sort in UltimatePortfolio application
    // test was typed below to complete the tutorial only
    
    /*
    func testBindingOnChange() {
        // Given
        var onChangeFunctionRun = false
        
        func exampleFunctionToCall() {
            onChangeFunctionRun = true
        }
     
        var storedValue = ""
        
        let binding = Binding(
            get: {storedValue },
            set: {storedValue = $0 }
        )
        
        let changedBinding = binding.onChange(exampleFunctionToCall)
        
        // When
        changedBinding.wrappedValue = "Test"
     
        // Then
        XCTAssertTrue(onChangeFunctionRun, "The onChange() function was not run.")
    }
    */
}
