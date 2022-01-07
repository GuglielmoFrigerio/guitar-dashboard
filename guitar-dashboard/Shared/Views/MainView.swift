//
//  MainView.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 31/12/21.
//

import SwiftUI

struct MainView: View {
    let deviceManager: DeviceManagerProtocol
    
    init(_ deviceManager: DeviceManagerProtocol) {
        self.deviceManager = deviceManager
    }
    
    var body: some View {
        List {
            ForEach(self.deviceManager.libraries, id: \.self) { library in
                NavigationLink(destination: LibraryView(library)) {
                    Text(library.name)
                }
            }
        }

    }
}
