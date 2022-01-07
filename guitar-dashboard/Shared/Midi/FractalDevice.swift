//
//  FractalDevice.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 22/12/21.
//

import Foundation


class FractalDevice {
    let midiOutputPort: MidiOutputPort?
    let midiChannel: UInt8 = 0
    var latestProgramScene = ProgramScene()
    
    init(midiFactory: MidiFactory, deviceName: String) {
        midiOutputPort = midiFactory.createOutputPort(deviceName: deviceName)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func send(programScene: ProgramScene) throws {
        if let uwOutputPort = midiOutputPort {
            programScene.send(previous: latestProgramScene,
                  programSender: { bank, program in try! uwOutputPort.sendbankAndProgram(channel: midiChannel, bankNumber: bank, programNumber: program) },
                  sceneSender: { scene in try! uwOutputPort.sendControlChange(channel: midiChannel, control: 34, value: scene)})
            latestProgramScene = programScene
        }
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {

    }
}
