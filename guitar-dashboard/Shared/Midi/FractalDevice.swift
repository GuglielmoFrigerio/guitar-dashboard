//
//  FractalDevice.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 22/12/21.
//

import Foundation


class FractalDevice {
    let midiOutputPort: MidiOutputPort
    let midiChannel: UInt8 = 0
    var latestProgramScene = ProgramScene()
    
    init(midiOutputPort: MidiOutputPort, deviceName: String) {
        self.midiOutputPort = midiOutputPort
    }
    
    func send(programScene: ProgramScene) throws {
        programScene.send(previous: latestProgramScene,
              programSender: { bank, program in try! midiOutputPort.sendbankAndProgram(channel: midiChannel, bankNumber: bank, programNumber: program) },
              sceneSender: { scene in try! midiOutputPort.sendControlChange(channel: midiChannel, control: 34, value: scene)})
        latestProgramScene = programScene
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {

    }
}
