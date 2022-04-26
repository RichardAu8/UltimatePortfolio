//
//  ProjectsView.swift
//  UltimatePortfolio
//
//  Created by RICHARD AU on 31/3/2022.
//

import SwiftUI

struct ProjectsView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext
    
    static let openTag: String = "Open"
    static let closedTag: String = "Closed"
    
    @State private var showingSortOrder = false
    @State private var sortOrder = Item.SortOrder.optimized
    
    let showClosedProjects: Bool
    //NOTE: use @FetchRequest instead of Paul's code below
    // his excuse of not knowing whether to fetch open or closed project is lame.  Just fetch the open ones by default
    // His method also needs a hack for sorting.  A lot of unnecessary work!!
    // If he had used @FetchRequest it already comes with SortOrder and Predicate built in.
    let projects: FetchRequest<Project>
    
    init(showClosedProjects: Bool) {
        self.showClosedProjects = showClosedProjects
        
        projects = FetchRequest<Project>(entity: Project.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Project.creationDate, ascending: false)], predicate: NSPredicate(format: "closed = %d", showClosedProjects))
    }
    
    var body: some View {
        // NOTE Hudson makes a mistake here, Navigation view should only appear at the top of the view hierarchy
        // otherwise the view gets smaller everytime you navigate down the hierarchy
        NavigationView {
            Group {
                // condition added for iPhone Max landscape
                if projects.wrappedValue.count == 0 {
                    Text("There's nothing here right now.")
                        .foregroundColor(.secondary)
                } else {
                    // List will render within left pane in landscape mode on iPhone Max
                    // Edit Next view in hierarchy
                    List {
                        ForEach(projects.wrappedValue) { project in
                            Section(header: ProjectHeaderView(project: project)) {
                                ForEach(project.projectItems(using: sortOrder)) {item in
                                    ItemRowView(project: project, item: item)
                                }
                                .onDelete { offsets in
                                    let allItems = project.projectItems(using: sortOrder)
                                    for offset in offsets {
                                        let item = allItems[offset]
                                        dataController.delete(item)
                                    }
                                    dataController.save()
                                }
                                if showClosedProjects == false {
                                    Button {
                                        withAnimation {
                                            let item = Item(context: managedObjectContext)
                                            item.project = project
                                            item.creationDate = Date()
                                            dataController.save()
                                        }
                                    } label: {
                                        Label("Add New Item", systemImage: "plus")
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .navigationTitle(showClosedProjects ? "Closed Projects" : "Open Projects")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if showClosedProjects == false {
                                Button {
                                    withAnimation {
                                        let project = Project(context: managedObjectContext)
                                        project.closed = false
                                        project.creationDate = Date()
                                        dataController.save()
                                    }
                                } label: {
                                    if UIAccessibility.isVoiceOverRunning {
                                        Text("Add Project")
                                    } else {
                                    Label("Add Project", systemImage: "plus")
                                    }
                                }
                            }
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                showingSortOrder.toggle()
                            } label: {
                                Label("Sort", systemImage: "arrow.up.arrow.down")
                            }
                        }
                    }
                    .actionSheet(isPresented: $showingSortOrder) {
                        ActionSheet(title: Text("Sort Items"), message: nil, buttons: [
                            .default(Text("Optimized")) {sortOrder = .optimized },
                            .default(Text("Creation Date")) {sortOrder = .creationDate },
                            .default(Text("Title")) {sortOrder = .title }
                        ])
                    }
                } // else
            } // Group
            // condition added for iPhone Max landscape
            SelectSomethingView()
        } //NavigationView
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
