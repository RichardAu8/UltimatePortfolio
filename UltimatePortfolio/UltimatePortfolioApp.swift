//
//  UltimatePortfolioApp.swift
//  UltimatePortfolio
//
//  Created by RICHARD AU on 31/3/2022.
//

import SwiftUI

@main
struct UltimatePortfolioApp: App {
    @StateObject var dataController: DataController
    
    init() {
        let dataController = DataController()
        _dataController = StateObject(wrappedValue: dataController)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                //managedObjectContext is the key for the view to find the CoreData context
                .environmentObject(dataController)
                //injecting the controller into the view
        }
    }
}
