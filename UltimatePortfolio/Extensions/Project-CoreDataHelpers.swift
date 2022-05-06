//
//  Project-CoreDataHelpers.swift
//  UltimatePortfolio
//
//  Created by RICHARD AU on 31/3/2022.
//

import Foundation
import SwiftUI

extension Project {
    var projectTitle: String {title ?? NSLocalizedString("New Project", comment: "Create a new project")}
    var projectDetail: String {detail ?? ""}
    var projectColor: String { color ?? "Light Blue"}
    
    var projectItems: [Item] {
        // Remember that Core Data objects are stored as optional sets so they must be typecast into an array
        items?.allObjects as? [Item] ?? []
    }
    
    var projectItemsDefaultSorted: [Item] {
        projectItems.sorted { first, second in
            if first.completed == false {
                if second.completed == true {
                    return true
                }
            } else if first.completed == true {
                if second.completed == false {
                    return false
                }
            }
            
            if first.priority > second.priority {
                return true
            } else if second.priority < second.priority {
                return false
            }
            
            return first.itemCreationDate < second.itemCreationDate
        }
    }
    
    var completionAmount: Double {
        let originalItems = items?.allObjects as? [Item] ?? []
        guard originalItems.isEmpty == false else {return 0}
        
        let completedItems = originalItems.filter(\.completed)
        return Double(completedItems.count) / Double(originalItems.count)
    }
    
    var label: LocalizedStringKey {
        // swiftlint:disable: next line_length
        LocalizedStringKey("\(projectTitle), \(projectItems.count) items, \(completionAmount * 100, specifier: "%g")% complete.")
    }
    
    static let colors = [
        "Pink",
        "Purple",
        "Red",
        "Orange",
        "Gold",
        "Green",
        "Teal",
        "Light Blue",
        "Dark Blue",
        "Midnight",
        "Dark Gray",
        "Gray"
    ]
    
    static var example: Project {
        // For func testExampleProjectIsClosed()
        // we must use DataController.preview otherwise the example is lost for testing.
        // UltimatePortfolioTests base case creates a DataController inMemory.
        // When a .example is returned iOS releases the memory and the dataController and .example are destroyed
        // Using .preview creates a singleton that keeps the test dataController and .example alive
        let controller = DataController.preview
        let viewContext = controller.container.viewContext
        
        let project = Project(context: viewContext) // create a new project context from viewContext
        project.title = "Example Project"
        project.detail = "This is an example Project"
        project.closed = true
        project.creationDate = Date()
        
        return project
    }
    
    
    func projectItems(using sortOrder: Item.SortOrder) -> [Item] {
        switch sortOrder {
        case .title:
            return projectItems.sorted { $0.itemTitle < $1.itemTitle }
        case .creationDate:
            return projectItems.sorted { $0.itemCreationDate < $1.itemCreationDate }
        case .optimized:
            return projectItemsDefaultSorted
        }
    }
}
