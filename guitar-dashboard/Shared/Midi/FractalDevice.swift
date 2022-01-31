//
//  FractalDevice.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 22/12/21.
//

import Foundation

enum FractalDeviceType {
    case axefx2
    case axefx3
}


class FractalDevice {
    let midiOutputPort: MidiOutputPort
    let midiChannel: UInt8 = 0
    var latestProgramScene = ProgramScene()
    private let type: FractalDeviceType
    
    init(midiOutputPort: MidiOutputPort, deviceName: String, type: FractalDeviceType) {
        self.midiOutputPort = midiOutputPort
        self.type = type
    }
    
    func send(programScene: ProgramScene) throws {
        programScene.send(previous: latestProgramScene,
                          programSender: {
            bank, program in
            if self.type == .axefx2 {
                try! midiOutputPort.sendBankSelect(channel: midiChannel, bankNumber: bank)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                    try! self.midiOutputPort.sendProgramChange(channel: self.midiChannel, program: program)
                }                
            } else {
                try! midiOutputPort.sendbankAndProgram(channel: midiChannel, bankNumber: bank, programNumber: program)
            }
        },
                          sceneSender: {
            scene in
            if self.type == .axefx2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                    try! self.midiOutputPort.sendControlChange(channel: self.midiChannel, control: 34, value: scene)
                }
            } else {
                try! midiOutputPort.sendControlChange(channel: midiChannel, control: 34, value: scene)
            }
            
        })
        latestProgramScene = programScene
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        
    }
}
