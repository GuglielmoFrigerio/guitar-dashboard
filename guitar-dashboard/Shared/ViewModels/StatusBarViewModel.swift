//
//  StatusBarViewModel.swift
//  guitar-dashboard
//
//  Created by Guglielmo Frigerio on 29/01/22.
//

import Foundation

class StatusBarViewModel: NSObject, ObservableObject {
    var deviceManager: DeviceManagerProtocol?

    var isAxeFx3Connected = false {
        willSet {
            objectWillChange.send()
        }
    }
    
    var isAxeFx2Connected = false {
        willSet {
            objectWillChange.send()
        }
    }

    func loadState() {
        self.deviceManager = DIContainer.shared.resolve(type: DeviceManagerProtocol.self)
        if let dm = self.deviceManager {
            isAxeFx3Connected = dm.isAxeFx3Connected
            dm.onAxeFx3StatusChange(perform: { newState in
                self.isAxeFx3Connected = newState
            })
            
            isAxeFx2Connected = dm.isAxeFx2Connected
            dm.onAxeFx2StatusChange(perform: { newState in
                self.isAxeFx2Connected = newState
            })
        }
    }
}
