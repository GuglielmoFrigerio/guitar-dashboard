//
//  MidiEndpointMonitor.swift
//  guitar-dashboard
//
//  Created by Guglielmo Frigerio on 11/01/22.
//

import Foundation
import CoreMIDI

class MidiEndpointMonitor {
    
    var sourceEndpointCollection = MidiEndpointCollection()
    var destinationEndpoitCollection = MidiEndpointCollection()
    let midiFactory: MidiFactory
    
    private func loadSourceEndpoints() -> [String: Int] {
        var endpoints: [String: Int] = [:]
        
        let numberOfSources = MIDIGetNumberOfSources()
        
        for idx in 0...numberOfSources {
            let midiEndpointRef = MIDIGetSource(idx)
            let name = midiEndpointRef.getName()
            endpoints[name] = idx
        }
        return endpoints

    }
    
    
    private func loadDestinationEndpoints() -> [String: Int] {
        var endpoints: [String: Int] = [:]
        
        let numberOfSources = MIDIGetNumberOfDestinations()
        
        for idx in 0...numberOfSources {
            let midiEndpointRef = MIDIGetDestination(idx)
            let name = midiEndpointRef.getName()
            endpoints[name] = idx
        }
        return endpoints

    }
    
    init(midiFactory: MidiFactory) {
        self.midiFactory = midiFactory
    }

    func subscribeSource(name: String, listener: @escaping (MidiInputPort?) -> Void) {
        sourceEndpointCollection.subscribe(name: name) {
            (name, index) in
            if let uwName = name {
                let midiInputPort = self.midiFactory.createInputPort(sourceIndex: index, portName: uwName)
                listener(midiInputPort)
            } else {
                listener(nil)
            }
        }
    }
    
    func subscribeDestination(name: String, listener: @escaping (MidiOutputPort?) -> Void) {
        destinationEndpoitCollection.subscribe(name: name) {
            (name, index) in
            if let uwName = name {
                let midiOutputPort = self.midiFactory.createOutputPort(destinationIndex: index, portName: uwName)
                listener(midiOutputPort)
            } else {
                listener(nil)
            }
        }        
    }
    
    func update() {
        let sourceEndpoints = loadSourceEndpoints()
        let destinationEndpoints = loadDestinationEndpoints()
        sourceEndpointCollection.compareCollection(endpoints: sourceEndpoints)
        destinationEndpoitCollection.compareCollection(endpoints: destinationEndpoints)
    }
}
