//
//  Item-CoreDataHelpers.swift
//  UltimatePortfolio
//
//  Created by RICHARD AU on 31/3/2022.
//

import Foundation

extension Item {
    var itemTitle: String {title ?? NSLocalizedString("New Item", comment: "Create a new item")}
    var itemDetail: String {detail ?? ""}
    var itemCreationDate: Date {creationDate ?? Date()}
    
    static var example: Item {
        // For func testExampleItemIsHighPriority()
        // we must use DataController.preview otherwise the example is lost for testing.
        // UltimatePortfolioTests base case creates a DataController inMemory.
        // When a .example is returned iOS releases the memory and the dataController and .example are destroyed
        // Using .preview creates a singleton that keeps the test dataController and .example alive
        let controller = DataController.preview
        let viewContext = controller.container.viewContext
        
        let item = Item(context: viewContext)
        item.title = "Example Item"
        item.detail = "This is an example item"
        item.priority = Int16(3)
        item.creationDate = Date()
        
        return item
    }
    
    enum SortOrder {
        case optimized, title, creationDate
    }
    
}
