//
//  Song.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 28/12/21.
//

import Foundation

struct SongModel: Decodable {
    let name: String
    let track: TrackModel
    let patches: [PatchModel]
    private var enabled: Bool?
    
    var isEnabled: Bool {
        get {
            if let uwenabled = enabled {
                return uwenabled
            }
            return true
        }
    }
}
