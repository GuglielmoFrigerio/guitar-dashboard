//
//  Song.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 30/12/21.
//

import Foundation
import os

class Song: Hashable {
    private let deviceManager: DeviceManagerProtocol
    var patches: [Patch] = []
    let name: String
    var onPatchSelected: ((Int) -> Void)? = nil
    let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Song")
    var currentSelection = 0

    init (_ songModel: SongModel,_ deviceManager: DeviceManagerProtocol) {
        self.deviceManager = deviceManager
        self.name = songModel.name
        
        var index = 0
        for patchModel in songModel.patches {
            patches.append(Patch(patchModel, index: index, deviceManager: deviceManager))
            index += 1
        }
    }
    
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    func selectPatch(index: Int) {
        self.patches[index].select()
    }
    
    func activate(onPatchSelected: @escaping (Int) -> Void) {
        self.onPatchSelected = onPatchSelected
        self.deviceManager.subscribePedalboard {
            pedalboardKey in
            self.logger.log("pedalboard key received \(pedalboardKey)")
            if let patchSelected = self.onPatchSelected {
                if pedalboardKey == .first && self.currentSelection > 0 {
                    self.currentSelection -= 1
                    patchSelected(self.currentSelection)
                } else if pedalboardKey == .second && self.currentSelection < (self.patches.count - 1) {
                    self.currentSelection += 1
                    patchSelected(self.currentSelection)
                }
            }
        }
        self.logger.log("song \(self.name) activated")
    }
    
    func deactivate() {
        self.onPatchSelected = nil
        self.deviceManager.unsubscribePedaboard()
        self.logger.log("song \(self.name) deactivated")
    }
}
