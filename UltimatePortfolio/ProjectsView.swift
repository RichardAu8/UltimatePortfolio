//
//  ProjectsView.swift
//  UltimatePortfolio
//
//  Created by RICHARD AU on 31/3/2022.
//

import SwiftUI

struct ProjectsView: View {
    static let openTag: String = "Open"
    static let closedTag: String = "Closed"
    
    let showClosedProjects: Bool
    //NOTE: use @FetchRequest instead of Paul's code below
    // his excuse of not knowing whether to fetch open or closed project is lame.  Just fetch the open ones by default
    let projects: FetchRequest<Project>
    
    init(showClosedProjects: Bool) {
        self.showClosedProjects = showClosedProjects
        
        projects = FetchRequest<Project>(entity: Project.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Project.creationDate, ascending: false)], predicate: NSPredicate(format: "closed = %d", showClosedProjects))
    }
    
    var body: some View {
        // NOTE Hudson makes a mistake here, Navigation view should only appear at the top of the view hierarchy
        // otherwise the view gets smaller everytime you navigate down the hierarchy
        NavigationView {
            List {
                ForEach(projects.wrappedValue) { project in
                    Section(header: ProjectHeaderView(project: project)) {
                        ForEach(project.projectItems) {item in
                            ItemRowView(item: item)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(showClosedProjects ? "Closed Projects" : "Open Projects")
        }
        
    }
}

struct ProjectsView_Previews: PreviewProvider {
    static var dataController  = DataController.preview
    
    static var previews: some View {
        ProjectsView(showClosedProjects: false)
            .environment(\.managedObjectContext,dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
