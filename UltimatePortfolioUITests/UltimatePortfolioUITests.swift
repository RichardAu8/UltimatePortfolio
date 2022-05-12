//
//  UltimatePortfolioUITests.swift
//  UltimatePortfolioUITests
//
//  Created by RICHARD AU on 10/5/2022.
//

import XCTest

class UltimatePortfolioUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test.
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    func testAppHas4Tabs() throws {
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // First query the number of tabs which are just buttons
        XCTAssertEqual(app.tabBars.buttons.count, 4, "There should be 4 tabs in the app.")
    }
    
    func testOpenTabAddsProjects() {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")
        
        for tapCount in 1...5 {
            app.buttons["Add Project"].tap()
            XCTAssertEqual(app.tables.cells.count, tapCount, "There should be \(tapCount) row(s) in the list.")
        }
    }
    
    func testAddingItemInsertsRows() {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There shoud be no list rows initially.")
        
        app.buttons["Add Project"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 list row after adding a project.")
        
        app.buttons["Add Item"].tap()
        XCTAssertEqual(app.tables.cells.count, 2, "There should be 2 list rows after adding an item.")
    }

    func testEditingProjectUpdatesCorrectly() {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")
        
        app.buttons["Add Project"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 list row after adding a project.")
        
        app.buttons["New Project"].tap()
        //find the textfield, tap it to activate text entry
        app.textFields["Project name"].tap()
        //Hudson recommends we enter the text in bits because Xcode typeText is a bit bugggy
        //typeText worked in Xcode 13.3.1 so Hudson's code is commented out
        /*
        app.keys["space"].tap()
        app.keys["more"].tap() // more just means continue
        app.keys["2"].tap()
        app.buttons["Return"].tap()
        */
        app.typeText(" 2")
        app.buttons["Return"].tap()
        
        // check that "NEW PROJECT 2" exists
        app.buttons["Open Projects"].tap() //this is actually the back navigation button
        XCTAssertTrue(app.buttons["New Project 2"].exists, "The new project name should be visible in the list.")
    }
    
    func testEditingItemUpdatesCorrectly() {
        testAddingItemInsertsRows()
        
        app.buttons["New Item"].tap()
        app.textFields["Item Name"].tap()
        
        app.typeText(" 2")
        app.buttons["Return"].tap()
        app.buttons["Open Projects"].tap() // i.e., the back button
        
        XCTAssertTrue(app.buttons["New Item 2"].exists, "The new item name should be visible in the list.")
    }
    
    func testAllAwardsShowLockedAlert() {
        app.buttons["Awards"].tap()
        for award in app.scrollViews.buttons.allElementsBoundByIndex {
            app.buttons["Awards"].tap() // an alert resets view back to "Home" tab so we must tap the "Awards" tab each time!!
            award.tap()
            XCTAssertTrue(app.alerts["Locked"].exists, "There should be a Locked alert showing for awards.")
            app.buttons["OK"].tap()
        }
    }
    
    func testCreatingAndClosingProject() {
        app.buttons["Open"].tap() // tap the "Open" tab
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")
        
        app.buttons["Add Project"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 list row after adding a project.")
        
        // Add a new project and name it "Test Project"
        app.buttons["New Project"].tap()
        //find the textfield, tap it to activate text entry
        app.textFields["Project name"].tap(withNumberOfTaps: 3, numberOfTouches: 1)
        app.typeText("Test Project")
        app.buttons["Return"].tap()
        
        // check that "Test Project" exists
        app.buttons["Open Projects"].tap() //this is actually the back navigation button
        XCTAssertTrue(app.buttons["Test Project"].exists, "The new project name should be visible in the list.")
        
        //close "Test Project"
        app.buttons["Test Project"].tap()
        app.buttons["Close this project"].tap()
        
        //Check that "Test Project" is Closed
        app.buttons["Closed"].tap() // tap the "Closed" tab
        XCTAssertTrue(app.buttons["Test Project"].exists, "The new project should be on Closed list.")
        
    }
    
    func testSwipeToDeleteItem() {
        app.buttons["Open"].tap() // tap the "Open" tab
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")
        
        app.buttons["Add Project"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 list row after adding a project.")
        
        // Add a new project and name it "Test Project"
        app.buttons["New Project"].tap()
        //find the textfield, tap it to activate text entry
        app.textFields["Project name"].tap(withNumberOfTaps: 3, numberOfTouches: 1)
        app.typeText("Test Project")
        app.buttons["Return"].tap()
        app.buttons["Open Projects"].tap() // i.e., the back button

        // Add a new Item and name it "New Item 2"
        app.buttons["Add Item"].tap()
        app.buttons["New Item"].tap()
        app.textFields["Item Name"].tap()
        
        app.typeText(" 2")
        app.buttons["Return"].tap()
        app.buttons["Open Projects"].tap() // i.e., the back button
        XCTAssertTrue(app.buttons["New Item 2"].exists, "The new item name should be visible in the list.")
        
        // Find "New Item 2" and swipe to delete
        app.buttons["New Item 2"].swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssertFalse(app.buttons["New Item 2"].exists, "The New Item 2 should be deleted.")
    }
    
    func testUnlockedAwardsAlert() {
        //Check database is empty
        app.buttons["Home"].tap() // tap the "Open" tab
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")
        
        // Check for Locked on empty database
        app.buttons["Awards"].tap()
        app.scrollViews.buttons.firstMatch.tap()
        XCTAssertTrue(app.alerts["Locked"].exists, "There should be a Locked alert showing for awards.")
        app.buttons["OK"].tap()
        
        // Add data to unlock first award
        app.buttons["Home"].tap()
        app.buttons["Add Data"].tap()
        
        // Check First Steps awards is unlocked
        app.buttons["Awards"].tap()
        app.scrollViews.buttons.firstMatch.tap()
        XCTAssertTrue(app.alerts["Unlocked: First Steps"].exists, "There should be a Locked alert showing for awards.")
        app.buttons["OK"].tap()
    }
    
}
