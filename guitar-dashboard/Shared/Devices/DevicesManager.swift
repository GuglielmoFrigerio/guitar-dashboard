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
    
    init() {
        midiFactory = nil
        libraryModels = []
        
        let fm = FileManager.default;
        let directoryURL = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let items = try fm.contentsOfDirectory(atPath: directoryURL.path)
            for item in items {
                logger.info("file: \(item)")
            }

        } catch {
            logger.warning("contentsOfDirectory failed")
        }
        
//        let fileURL = URL(fileURLWithPath: "myFile", relativeTo: directoryURL).appendingPathExtension("txt")
//        
//        
//        // Create data to be saved
//        let myString = "Saving data with FileManager is easy!"
//        guard let data = myString.data(using: .utf8) else {
//            print("Unable to convert string to data")
//            return
//        }
//        // Save the data
//        do {
//         try data.write(to: fileURL)
//         print("File saved: \(fileURL.absoluteURL)")
//        } catch {
//         // Catch any errors
//         print(error.localizedDescription)
//        }
//        
//        let url = URL(string: "http://192.168.1.58:5074/api/Track/in%20the%20Cage%20-%20Genesis.mp3")!
//
//        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
//            guard let data = data else { return }
//            let fileURL = URL(fileURLWithPath: "testTrack", relativeTo: directoryURL).appendingPathExtension("mp3")
//            do {
//                try data.write(to: fileURL)
//            } catch {
//                self.logger.warning("data.write failed")
//            }
//        }
//
//        task.resume()
    }

    init(libraries: [LibraryModel]) {
        self.libraryModels = libraries        
        
        midiFactory = MidiFactory(clientName: "FractalClient")
        if let uwMidiFactory = midiFactory {
            DIContainer.shared.register(type: MidiFactoryProtocol.self, component: uwMidiFactory)
                        
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
