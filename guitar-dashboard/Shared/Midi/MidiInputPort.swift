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
    var packetListener: ((MidiPacket) -> Void)?
    
    init (midiClientRef: MIDIClientRef, portName: String, sourceIndex: Int) throws {
        logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MidiInputPort")
        
        var status = MIDIInputPortCreateWithProtocol(midiClientRef, portName as CFString, MIDIProtocolID._1_0, &inputPort) {
            [weak self] unsafePointerMidiEventList, srcConnRefCon in
            
            let midiEventList: MIDIEventList = unsafePointerMidiEventList.pointee
            let packet = midiEventList.packet
                    
            (0 ..< midiEventList.numPackets).forEach { _ in
                let words = Mirror(reflecting: packet.words).children
                words.forEach {
                    word in
                    let uint32 = word.value as! UInt32
                    guard uint32 > 0 else {
                        return
                    }
                    let midiPacket = MidiPacket(first: UInt8((uint32 & 0xFF000000) >> 24), second: UInt8((uint32 & 0x00FF0000) >> 16), third: UInt8((uint32 & 0x0000FF00) >> 8), fourth: UInt8(uint32 & 0x000000FF))
                    self?.packetListener!(midiPacket)
                }
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
    
    func onMidiPacket(packetListener: @escaping (MidiPacket) -> Void) {
        self.packetListener = packetListener;
    }
}
