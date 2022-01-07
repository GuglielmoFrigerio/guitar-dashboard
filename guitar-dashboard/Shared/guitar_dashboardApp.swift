//
//  guitar_dashboardApp.swift
//  Shared
//
//  Created by Guglielmo Frigerio on 07/01/22.
//

import SwiftUI

@main
struct guitar_dashboardApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
