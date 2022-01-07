//
//  DevicesManager.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 28/12/21.
//

import Foundation
import os

class DevicesManager: DeviceManagerProtocol {
    private let libraryModels: [LibraryModel]
    var libraries: [Library] = []
    let midiFactory: MidiFactory?
    var axeFx3Device: FractalDevice? = nil
    var pedalBoard: Pedalboard? = nil
    let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DevicesManager")
    
    init() {
        midiFactory = nil
        libraryModels = []
    }

    init(libraries: [LibraryModel]) {
        self.libraryModels = libraries        
        
        midiFactory = try? MidiFactory(clientName: "FractalClient") {
            midiFactory in
            midiFactory.logMidiEndpoints()
        }
        if let uwMidiFactory = midiFactory {
            let deviceName = "Axe-Fx III"
            axeFx3Device = FractalDevice(midiFactory: uwMidiFactory, deviceName: deviceName)
            logger.log("device \(deviceName) created")
            DIContainer.shared.register(type: MidiFactoryProtocol.self, component: uwMidiFactory)
            
            let inputPortName = "BT200S-4 v2.3.1 9BCD Bluetooth"
            if let uwMidiInputPort = uwMidiFactory.createInputPort(deviceName: inputPortName) {
                logger.log("midi input port \(inputPortName) created")
                pedalBoard = Pedalboard(midiInputPort: uwMidiInputPort)
            }
        }
        
        for libMode in libraryModels {
            self.libraries.append(Library(libMode, self))
        }
    }
    
    func send (patch: Patch) {
        if let uwAxeFx3Device = self.axeFx3Device, let uwAxeFx3Patch = patch.axeFx3 {
            do {
                try uwAxeFx3Device.send(programScene: uwAxeFx3Patch)
            } catch {
                logger.warning("Unable to send patch to AxeFx3 device")                
            }
        }
    }
}
