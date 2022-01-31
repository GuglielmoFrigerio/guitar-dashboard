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
    let index: Int
    private let deviceManager: DeviceManagerProtocol
    private let message: String?

    init(_ patchModel: PatchModel, index: Int, deviceManager: DeviceManagerProtocol) {
        self.index = index
        self.deviceManager = deviceManager
        self.message = patchModel.message
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
        return lhs.index == rhs.index
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }
    
    func select() -> String {
        self.deviceManager.send(patch: self)
        if let uwMessage = self.message {
            return uwMessage
        }
        return ""
    }
}
