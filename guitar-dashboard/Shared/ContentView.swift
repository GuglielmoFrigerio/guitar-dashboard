//
//  ContentView.swift
//  Shared
//
//  Created by Guglielmo Frigerio on 07/01/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    var devicesManager: DevicesManager = DevicesManager()

    init() {
        guard let asset = NSDataAsset(name: "DeviceConfiguration") else {
            print("NSDataAsset failed")
            return
        }
        
        let data = asset.data
        let configRoot: ConfigRootModel = try! JSONDecoder().decode(ConfigRootModel.self, from: data)
        devicesManager = DevicesManager(libraries: configRoot.libraries)
        DIContainer.shared.register(type: DeviceManagerProtocol.self, component: devicesManager)
    }

    var body: some View {
        VStack {
            NavigationView() {
                List() {
                    NavigationLink(destination: MainView(devicesManager)) {
                        Text("Main View")
                    }
                    NavigationLink(destination: MidiPortsView()) {
                        Text("List Midi Ports")
                    }
                    NavigationLink(destination: KeyboardView()) {
                        Text("Keyboard View")
                    }
                }
    //            .navigationBarTitle("Libraries")
            }
            StatusBarView()
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
