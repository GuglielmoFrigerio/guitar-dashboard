//
//  Library.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 28/12/21.
//

import Foundation

struct LibraryModel: Decodable {
    let name: String
    let songs: [SongModel]
}
