//
//  Library.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 31/12/21.
//

import Foundation
import SwiftUI

struct Library: Hashable {
    var name: String
    var songs: [Song] = []
    
    init(_ libraryModel: LibraryModel, _ deviceManager: DeviceManagerProtocol) {
        self.name = libraryModel.name
        for songModel in libraryModel.songs {
            songs.append(Song(songModel, deviceManager))
        }
    }
    
    static func == (lhs: Library, rhs: Library) -> Bool {
        return lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
