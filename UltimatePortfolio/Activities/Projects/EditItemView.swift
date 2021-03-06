//
//  EditItemView.swift
//  UltimatePortfolio
//
//  Created by RICHARD AU on 4/4/2022.
//

import SwiftUI

struct EditItemView: View {
    @EnvironmentObject var dataController: DataController
    
    let item: Item
    
    @State private var title: String
    @State private var detail: String
    @State private var priority: Int
    @State private var completed: Bool
    
    init(item: Item) {
        self.item = item
        
        _title = State(wrappedValue: item.itemTitle)
        _detail = State(wrappedValue: item.itemDetail)
        _priority = State(wrappedValue: Int(item.priority))
        _completed = State(wrappedValue: item.completed)
        
    }
    
    var body: some View {
        Form {
            Section(header: Text("Basic settings")) {
                TextField("Item Name", text: $title)
                TextField("Description", text: $detail)
            }
            Section(header: Text("Priority")) {
                Picker("Priority", selection: $priority) {
                    Text("Low").tag(1)
                    Text("Medium").tag(2)
                    Text("High").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section {
                Toggle("Mark Completed", isOn: $completed)
            }
        }
        .navigationTitle("Edit Item")
        // Note: using clean native SwiftUI .onChange instead of Hudson's convoluted hack
        .onChange(of: title) {_ in update() }
        .onChange(of: detail) {_ in update() }
        .onChange(of: priority) {_ in update() }
        .onChange(of: completed) {_ in update() }
        .onDisappear(perform: dataController.save)
    }
    
    func update() {
        item.project?.objectWillChange.send() //must use project given the to-one relationship
        
        item.title = title
        item.detail = detail
        item.priority = Int16(priority)
        item.completed = completed
    }
    
}

struct EditItemView_Previews: PreviewProvider {
    static var previews: some View {
        EditItemView(item: Item.example)
    }
}
