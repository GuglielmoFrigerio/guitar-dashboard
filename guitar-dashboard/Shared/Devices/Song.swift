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
    let trackName: String

    init (_ songModel: SongModel,_ deviceManager: DeviceManagerProtocol) {
        self.deviceManager = deviceManager
        self.name = songModel.name
        trackName = songModel.track.name
        
        
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
    
    func activate(pedalboardTarget: PedalboardTargetProtocol) {
        self.deviceManager.subscribePedalboard {
            pedalboardKey in
            self.logger.log("pedalboard key received \(pedalboardKey)")
            if pedalboardKey == .first && self.currentSelection > 0 {
                self.currentSelection -= 1
                pedalboardTarget.patchSelected(index: self.currentSelection)
            } else if pedalboardKey == .second && self.currentSelection < (self.patches.count - 1) {
                self.currentSelection += 1
                pedalboardTarget.patchSelected(index: self.currentSelection)
            } else if pedalboardKey == .third {
                pedalboardTarget.playOrPause()
            } else if pedalboardKey == .fourth {
                pedalboardTarget.stop()
            }
        }
        self.logger.log("song \(self.name) activated")
    }
        
    func deactivate() {
        self.onPatchSelected = nil
        self.deviceManager.unsubscribePedaboard()
        self.logger.log("song \(self.name) deactivated")
    }
    
    func loadTrack(loader: TrackLoaderProtocol) {
        loader.loadTrack(name: self.trackName)
    }
}
