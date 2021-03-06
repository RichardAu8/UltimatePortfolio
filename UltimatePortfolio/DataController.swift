//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by RICHARD AU on 31/3/2022.
//
/// An environment singleton responsible for managing the Core Data stack including,
/// counting fetch requests, tracking awards and dealing with sample data

import Foundation
import SwiftUI
import CoreData

class DataController: ObservableObject {
    let container: NSPersistentCloudKitContainer
    
    // Read and create a SINGLE model so that we don't have multiple everytime we instantiate DataController
    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate core data model file.")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load core data model file.")
        }
        return managedObjectModel
    } ()
    
    /// Initialises a data controller either in permanent (app/cloud) storage or in memory when we only want to use it for testing
    ///
    /// Defaults to permanent storage
    ///  - Parameter inMemory: indicates whether to store data temporarily in memory
    /// For testing & preview, create an in-memory database in /dev/null that is destroyed when the app finishes running.
    /// Modified to use "static model" defined above.
    init(inMemory: Bool = false){
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _ , error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
            
            #if DEBUG
            // delete the entire database 
            if CommandLine.arguments.contains("enable-testing") {
                self.deleteAll()
                UIView.setAnimationsEnabled(false) // this will make UITests run faster
            }
            #endif
        }
    }
    
    /// Creates example projects and items to make manual testing easier
    /// - Throws: an NSError sent from callsave() on the NSManagedObjectContext
    func createSampleData() throws {
        let viewContext = container.viewContext
        
        for i in 1...5 {
            let project = Project(context: viewContext)
            project.title = "Project \(i)"
            project.items = []
            project.creationDate = Date()
            project.closed = Bool.random()
            
            for j in 1...10 {
                let item = Item(context: viewContext)
                item.title = "Item \(j)"
                item.creationDate = Date()
                item.completed = Bool.random()
                item.project = project
                item.priority = Int16.random(in: 1...3)
            }
        }
        try viewContext.save()
    }
    
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        let viewContext = dataController.container.viewContext
        
        do {
            try dataController.createSampleData()
        } catch {
            fatalError("Fatal error creating preview: \(error.localizedDescription)")
        }
        return dataController
    } ()
    
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    func delete(_ object: NSManagedObject) {
        container.viewContext.delete(object)
    }
    
    func deleteAll() {
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        let batchFetchRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        _ = try? container.viewContext.execute(batchFetchRequest1)
        
        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Project.fetchRequest()
        let batchFetchRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        _ = try? container.viewContext.execute(batchFetchRequest2)
        
    }
    
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
    
    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
        //returns true when user adds a certain number of items
        case "items" :
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
        //returns true when user marks a certain number of items as completed
        case "complete":
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
        default:
            // fatalError("Unknown award criterion \(award.criterion).")
            return false
        }
    }
        
}


