//
//  MidiEndpointMonitor.swift
//  guitar-dashboard
//
//  Created by Guglielmo Frigerio on 11/01/22.
//

import Foundation
import CoreMIDI
import os

class MidiEndpointMonitor {
    
    var sourceEndpointCollection = MidiEndpointCollection()
    var destinationEndpoitCollection = MidiEndpointCollection()
    let midiFactory: MidiFactory
    let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MidiEndpointMonitor")

    private func loadSourceEndpoints() -> [String: Int] {
        var endpoints: [String: Int] = [:]
        
        let numberOfSources = MIDIGetNumberOfSources()
        
        for idx in 0...numberOfSources {
            let midiEndpointRef = MIDIGetSource(idx)
            let name = midiEndpointRef.getDisplayName()
            endpoints[name] = idx
            logger.info("loadSourceEndpoints: added source \(name) at index \(idx)")
        }
        return endpoints

    }
    
    
    private func loadDestinationEndpoints() -> [String: Int] {
        var endpoints: [String: Int] = [:]
        
        let numberOfSources = MIDIGetNumberOfDestinations()
        
        for idx in 0...numberOfSources {
            let midiEndpointRef = MIDIGetDestination(idx)
            let name = midiEndpointRef.getDisplayName()
            endpoints[name] = idx
            logger.info("loadSourceEndpoints: added destination \(name) at index \(idx)")
        }
        return endpoints

    }
    
    init(midiFactory: MidiFactory) {
        self.midiFactory = midiFactory
    }

    func subscribeSource(name: String, listener: @escaping (MidiInputPort?) -> Void) {
        sourceEndpointCollection.subscribe(name: name) {
            (name, index) in
            if index != -1 {
                self.logger.info("onSourceChange: endpoint '\(name)' available at index \(index)")
                let midiInputPort = self.midiFactory.createInputPort(sourceIndex: index, portName: name)
                listener(midiInputPort)
            } else {
                self.logger.info("onSourceChange: endpoint '\(name)' is no longer available")
                listener(nil)
            }
        }
    }
    
    func subscribeDestination(name: String, listener: @escaping (MidiOutputPort?) -> Void) {
        destinationEndpoitCollection.subscribe(name: name) {
            (name, index) in
            if (index != -1) {
                self.logger.info("onDestinationChange: endpoint '\(name)' available at index \(index)")
                let midiOutputPort = self.midiFactory.createOutputPort(destinationIndex: index, portName: name)
                listener(midiOutputPort)
            } else {
                self.logger.info("onDestinationChange: endpoint '\(name)' is no longer available")
                listener(nil)
            }
        }        
    }
    
    func update() {
        logger.info("updating subscriptions")
        let sourceEndpoints = loadSourceEndpoints()
        sourceEndpointCollection.compareCollection(endpoints: sourceEndpoints)
        
        let destinationEndpoints = loadDestinationEndpoints()
        destinationEndpoitCollection.compareCollection(endpoints: destinationEndpoints)
    }
}
