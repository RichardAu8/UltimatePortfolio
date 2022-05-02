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
                //managedObjectContext is the key for the view to find the CoreData context
                .environment(\.managedObjectContext, dataController.container.viewContext)
                //injecting the controller into the view
                .environmentObject(dataController)
                //listen to a notification (i.e., UIApplication.willResignActiveNotification) when user leaves the app
                // from foreground.  Didnt use .onChange(of: scenePhase) {...} so we can port the app to MacOS
                //save if the user leaves the app for any reason
                .onReceive(
                    NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
                    perform: save
                )
        }
    }
    
    // saves to core data
    // needs a notification parameter because .onReceive above needs to pass the notification
    func save(_ note: Notification) {
        dataController.save()
    }
}
