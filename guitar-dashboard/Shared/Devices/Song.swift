//
//  Song.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 30/12/21.
//

import Foundation

struct Song: Hashable {
    private let deviceManager: DeviceManagerProtocol
    var patches: [Patch] = []
    let name: String
    
    init (_ songModel: SongModel,_ deviceManager: DeviceManagerProtocol) {
        self.deviceManager = deviceManager
        self.name = songModel.name
        
        for patchModel in songModel.patches {
            patches.append(Patch(patchModel))            
        }
    }
    
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
