//
//  Library.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 28/12/21.
//

import Foundation
import UIKit

class LibraryModel: Decodable {
    private var enabled: Bool?
    let name: String
    let songs: [SongModel]
    
    var isEnabled: Bool {
        get {
            if let uwenabled = enabled {
                return uwenabled
            }
            return true
        }
    }
}
