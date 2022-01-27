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
    var pedalboardKeySubscriber: ((PedalboardKey) -> Void)? = nil
    var endpointMonitor: MidiEndpointMonitor? = nil
    
    private func pedalSourceInputAvailable(inputPort: MidiInputPort) {
        pedalBoard = Pedalboard(midiInputPort: inputPort, keyListener: pedalboardKeyHandler)
    }
    
    private func pedalboardKeyHandler(key: PedalboardKey) {
        if let subscriber = self.pedalboardKeySubscriber {
            subscriber(key)
        }
    }
    
    private func loadTracks() -> Void {
        guard let loader = DIContainer.shared.resolve(type: TrackLoaderProtocol.self) else {
            logger.warning("Unable to find and instance of type TrackLoaderProtocol")
            return
        }
        
        for library in libraries {
            library.loadTracks(loader: loader)
        }
    }
    
    private func logDocumentDirectory() {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: directoryURL.path)
            for item in items {
                logger.info("file: \(item)")
            }

        } catch {
            logger.warning("contentsOfDirectory failed")
        }
    }
    
    private func writeTextFile() {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = URL(fileURLWithPath: "myFile", relativeTo: directoryURL).appendingPathExtension("txt")
        
        
        // Create data to be saved
        let myString = "Saving data with FileManager is easy!"
        guard let data = myString.data(using: .utf8) else {
            print("Unable to convert string to data")
            return
        }
        
        // Save the data
        do {
         try data.write(to: fileURL)
            logger.info("File saved: \(fileURL.absoluteURL)")
        } catch {
            logger.info("File write failed: '\(error.localizedDescription)'")
        }
    }
    
    init() {
        midiFactory = nil
        libraryModels = []
    }

    init(libraries: [LibraryModel]) {
        self.libraryModels = libraries        
        
        midiFactory = MidiFactory(clientName: "FractalClient")
        if let uwMidiFactory = midiFactory {
            DIContainer.shared.register(type: MidiFactoryProtocol.self, component: uwMidiFactory)
            DIContainer.shared.register(type: TrackLoaderProtocol.self, component: TrackLoader())
                                    
            endpointMonitor = MidiEndpointMonitor(midiFactory: uwMidiFactory)
            endpointMonitor?.subscribeSource(name: "BT200S-4 v2.3.1 9BCD Bluetooth") {
                midiInpuPort in
                if let uwMidiInpuPort = midiInpuPort {
                    self.pedalBoard = Pedalboard(midiInputPort: uwMidiInpuPort, keyListener: self.pedalboardKeyHandler)
                } else {
                    self.pedalBoard?.dispose()
                    self.pedalBoard = nil
                }
            }
            endpointMonitor?.subscribeDestination(name: "Axe-Fx III") {
                midiOutputPort in
                if let uwMidiOutputPort = midiOutputPort {
                    self.axeFx3Device = FractalDevice(midiOutputPort: uwMidiOutputPort, deviceName: "Axe-Fx III")
                } else {
                    self.axeFx3Device = nil
                }
            }
        }
        
        for libMode in libraryModels {
            self.libraries.append(Library(libMode, self))
        }
        
        midiFactory?.onSetupChanged {
            midiFactory in
            self.endpointMonitor?.update()
        }
        
        endpointMonitor?.update()
        
//        loadTracks()
        logDocumentDirectory()
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
    
    func subscribePedalboard(onPedalboardKey: @escaping (PedalboardKey) -> Void) {
        pedalboardKeySubscriber = onPedalboardKey
    }
    
    func unsubscribePedaboard() {
        pedalboardKeySubscriber = nil
    }
}
