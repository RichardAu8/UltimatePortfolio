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
                    projectsList
                }
            } // Group
            .navigationTitle(showClosedProjects ? "Closed Projects" : "Open Projects")
            .toolbar {
                addProjectToolbarItem
                sortOrderToolbarItem
            }
            .actionSheet(isPresented: $showingSortOrder) {
                ActionSheet(title: Text("Sort Items"), message: nil, buttons: [
                    .default(Text("Optimized")) {sortOrder = .optimized },
                    .default(Text("Creation Date")) {sortOrder = .creationDate },
                    .default(Text("Title")) {sortOrder = .title }
                ])
            }
            SelectSomethingView()  // condition added for iPhone Max landscape
        } //NavigationView

    } // Body
    
    var projectsList: some View {
        // List will render within left pane in landscape mode on iPhone Max
        // Edit Next view in hierarchy
        List {
            ForEach(projects.wrappedValue) { project in
                Section(header: ProjectHeaderView(project: project)) {
                    ForEach(project.projectItems(using: sortOrder)) {item in
                        ItemRowView(project: project, item: item)
                    }
                    .onDelete { offsets in
                        delete(offsets, from: project)
                    }
                    if showClosedProjects == false {
                        Button {
                            addItem(to: project)
                        } label: {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    var addProjectToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if showClosedProjects == false {
                Button(action: addProject) {
                    // ios 14.3 VoiceOver has bug that reads only "Add" instead of "Add Project" hence we
                    // need to test the case and use a Text view instead of just a label
                    if UIAccessibility.isVoiceOverRunning {
                        Text("Add Project")
                    } else {
                        Label("Add Project", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    var sortOrderToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                showingSortOrder.toggle()
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
        }
    }

    func addProject() {
        withAnimation {
            let project = Project(context: managedObjectContext)
            project.closed = false
            project.creationDate = Date()
            dataController.save()
        }
    }
    
    func addItem(to project: Project) {
        withAnimation {
            let item = Item(context: managedObjectContext)
            item.project = project
            item.creationDate = Date()
            dataController.save()
        }
    }
    
    func delete(_ offsets: IndexSet, from project: Project) {
        let allItems = project.projectItems(using: sortOrder)
        for offset in offsets {
            let item = allItems[offset]
            dataController.delete(item)
        }
        dataController.save()
    }
    
} // ProjectsView

struct ProjectsView_Previews: PreviewProvider {
    static var dataController  = DataController.preview
    
    static var previews: some View {
        ProjectsView(showClosedProjects: false)
            .environment(\.managedObjectContext,dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
