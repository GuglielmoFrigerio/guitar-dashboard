//
//  Patch.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 30/12/21.
//

import Foundation

struct Patch: Hashable, Identifiable {
    let name: String
    var axeFx2: ProgramScene?
    var axeFx3: ProgramScene?
    let id = UUID()
    
    init(_ patchModel: PatchModel) {
        if let uwName = patchModel.name {
            self.name = uwName
        } else {
            self.name = "untitled"
        }
        if let axeFx2Patch = patchModel.axeFx2 {
            axeFx2 = ProgramScene(programNumber: axeFx2Patch.number, sceneNumber: axeFx2Patch.scene)
        }
        if let axeFx3Patch = patchModel.axeFx3 {
            axeFx3 = ProgramScene(programNumber: axeFx3Patch.number, sceneNumber: axeFx3Patch.scene)
        }
    }
    
    static func == (lhs: Patch, rhs: Patch) -> Bool {
        return lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
