//
//  MidiInputPort.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 05/01/22.
//

import Foundation
import CoreMIDI
import os

class MidiInputPort {
    var inputPort: MIDIPortRef = 0
    var source: MIDIEndpointRef = 0
    let logger: Logger
    
    init (midiClientRef: MIDIClientRef, portName: String, sourceIndex: Int) throws {
        logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MidiInputPort")

        
        var status = MIDIInputPortCreateWithProtocol(midiClientRef, portName as CFString, MIDIProtocolID._1_0, &inputPort) {
            [weak self] unsafePointerMidiEventList, srcConnRefCon in
            
            let midiEventList: MIDIEventList = unsafePointerMidiEventList.pointee
            var packet = midiEventList.packet
            
            self?.logger.log("thread: \(Thread.current) midi message received: numPackets: \(midiEventList.numPackets)")
                    
            (0 ..< midiEventList.numPackets).forEach { _ in
            }
        }
        
        if (status != noErr) {
            throw MidiError.MidiOperationFailed(errorCode: status, functionName: "MIDIInputPortCreateWithProtocol")
        }

        source = MIDIGetSource(sourceIndex)
        status = MIDIPortConnectSource(inputPort, source, &source)
        if (status != noErr) {
            throw MidiError.MidiOperationFailed(errorCode: status, functionName: "MIDIPortConnectSource")
        }

        
        logger.log("init: input port '\(portName)' succesfully connected")

    }
}
