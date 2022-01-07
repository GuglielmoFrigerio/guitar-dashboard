//
//  MidiInfo.swift
//  Lendmarks
//
//  Created by Guglielmo Frigerio on 20/12/21.
//

import Foundation
import CoreMIDI


struct MidiInfo {
    
    init() {
    }
    
    func getDescription() -> String {
        let numberOfSources = MIDIGetNumberOfSources()
        
        var description = "\(numberOfSources)"
        
        for idx in 0...numberOfSources {
            let midiEndpointRef = MIDIGetSource(idx)
            var property : Unmanaged<CFString>?
            let err = MIDIObjectGetStringProperty(midiEndpointRef, kMIDIPropertyDisplayName, &property)
            if err == noErr {
                let displayName = property!.takeRetainedValue() as String
                description = "\(description) \(displayName)"
            }
        }
        return description
    }
    
    func midiNotifyProc(midiNotification: UnsafePointer<MIDINotification>, refCon: UnsafeMutableRawPointer) {
        
    }
    
    func createOutputPort(portName: String) {
        
        let clientName: CFString = "FractalClient" as CFString
        var midiClientRef = MIDIClientRef()
        var status = MIDIClientCreateWithBlock(clientName, &midiClientRef) {
            midiNotification in
        }
        
        if (status != noErr) {
            return
        }
        
        var midiPortRef = MIDIPortRef();
        status = MIDIOutputPortCreate(midiClientRef, portName as CFString, &midiPortRef)
        
        if (status != noErr) {
            return
        }
        
        let midiEndpointRef = MIDIGetDestination(0)
        
        var packet1:MIDIPacket = MIDIPacket();
        packet1.timeStamp = 0;
        packet1.length = 3;
        packet1.data.0 = 0xC0 + 0; // Note On event channel 1
        packet1.data.1 = 0x40; // Note C3
        packet1.data.2 = 0; // Velocity

        var packetList:MIDIPacketList = MIDIPacketList(numPackets: 1, packet: packet1);
        status = MIDISend(midiPortRef, midiEndpointRef, &packetList)
        
    }
}
