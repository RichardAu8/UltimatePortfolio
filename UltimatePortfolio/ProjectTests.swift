//
//  ProjectTests.swift
//  UltimatePortfolioTests
//
//  Created by RICHARD AU on 4/5/2022.
//

import CoreData
import XCTest
@testable import UltimatePortfolio

class ProjectTests: BaseTestCase {
    // test whether the testdata was created, saved and read from Core Data by counting the number of expected records
    func testCreatingProjectsAndItems() {
        let targetCount = 10
        
        for _ in 0..<targetCount {
            let project = Project(context: managedObjectContext)
            
            for _ in 0..<targetCount {
                let item = Item(context: managedObjectContext)
                item.project = project
            }
        }
        
        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), targetCount)
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), targetCount * targetCount)
    }
    
    // test whether deleting the first project cascades the delete to it's items
    // method uses throws so throwing code can be used within and handle any errors returned
    func testDeletingProjectCascadeDeletesItems() throws {
        try dataController.createSampleData()
        
        let request = NSFetchRequest<Project>(entityName: "Project")
        let projects = try managedObjectContext.fetch(request)
        
        dataController.delete(projects[0])
        
        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 4)
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 40)
    }
    
}
