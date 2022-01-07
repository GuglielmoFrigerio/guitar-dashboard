//
//  Patch.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 28/12/21.
//

import Foundation

struct PatchModel: Decodable {
    let name: String?
    let axeFx2: ProgramModel?
    let axeFx3: ProgramModel?
}
