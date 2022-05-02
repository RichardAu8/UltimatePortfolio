//
//  EditProjectView.swift
//  UltimatePortfolio
//
//  Created by RICHARD AU on 5/4/2022.
//

import SwiftUI

struct EditProjectView: View {
    let project: Project
    
    @EnvironmentObject var dataController: DataController
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteConfirm = false
    
    @State private var title: String
    @State private var detail: String
    @State private var color: String
    
    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]
    
    init(project: Project) {
        self.project = project
        _title = State(wrappedValue: project.projectTitle)
        _detail = State(wrappedValue: project.projectDetail)
        _color = State(wrappedValue: project.projectColor)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Basic Settings")) {
                TextField("Project name", text: $title)
                TextField("Description of this project", text: $detail)
            }
            Section(header: Text("Custom Project Color")) {
                LazyVGrid(columns: colorColumns) {
                    ForEach(Project.colors, id:\.self, content: colorButton)
                }
                .padding(.vertical)
            }
            // swiftlint:disable: next line_length
            Section(footer: Text("Closing a project moves it from the Open to Closed tab; deleting it removes the project completely.")) {
                Button(project.closed ? "Reopen this project" : "Close this project") {
                    project.closed.toggle()
                    update()
                }
                
                Button("Delete this project") {
                    showingDeleteConfirm.toggle()
                }
                .accentColor(.red)
            }
            
        }
        .navigationTitle("Edit Project")
        // note: using native SwiftUI .onChange instead of Hudson's hack
        .onChange(of: title) {_ in update() }
        .onChange(of: detail) {_ in update() }
        .onDisappear(perform: dataController.save)
        .alert(isPresented: $showingDeleteConfirm) {
            Alert(
                title: Text("Delete project?"),
                // swiftlint:disable: next line_length
                message: Text("Are you sure you want to delete this project?  You will also delete all the items it contains."),
                primaryButton: .default(Text("Delete"), action: delete),
                secondaryButton: .cancel())
        }
    }
    
    func colorButton(for item: String) -> some View {
        ZStack {
            Color(item)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(6)
            if item == color {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        }
        .onTapGesture {
            color = item
            update()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(
            item == color
            ? [.isButton, .isSelected]
            : .isButton
        )
        .accessibilityLabel(LocalizedStringKey(item))
    }
    
    func update() {
        project.title = title
        project.detail = detail
        project.color = color
    }
    
    func delete() {
        dataController.delete(project)
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectView(project: Project.example)
    }
}
