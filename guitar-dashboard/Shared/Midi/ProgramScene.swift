//
//  ProgramScene.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 22/12/21.
//

import Foundation

struct ProgramScene {
    let programNumber: Int
    let sceneNumber: Int
    
    init(programNumber: Int, sceneNumber: Int) {
        self.programNumber = programNumber
        self.sceneNumber = sceneNumber
    }
    
    init() {
        programNumber = -1
        sceneNumber = -1
    }
    
    func send(previous: ProgramScene, programSender: (UInt8, UInt8) -> Void, sceneSender: (UInt8) -> Void) {
        if programNumber != previous.programNumber {
            programSender(UInt8(programNumber / 128), UInt8(programNumber % 128))
            sceneSender((UInt8)(sceneNumber - 1))
        } else if sceneNumber != previous.sceneNumber {
            sceneSender((UInt8)(sceneNumber - 1))
        }
    }
    
    func send(midiChannel: UInt8, outputPort: MidiOutputPort) throws {
        let bankNumber = UInt8(programNumber / 128)
        let program = UInt8(programNumber % 128)
        try? outputPort.sendbankAndProgram(channel: midiChannel, bankNumber: bankNumber, programNumber: program)
    }
}
