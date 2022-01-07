//
//  MidiOutputPort.swift
//  Lendmarks
//
//  Created by Guglielmo Frigerio on 22/12/21.
//

import Foundation
import CoreMIDI

struct MidiOutputPort {
    var midiPortRef = MIDIPortRef()
    let midiEndpointRef: MIDIEndpointRef
    
    init (midiClientRef: MIDIClientRef, portName: String, destinationIndex: Int) throws {
        let status = MIDIOutputPortCreate(midiClientRef, portName as CFString, &midiPortRef)
        
        if (status != noErr) {
            throw MidiError.MidiOperationFailed(errorCode: status, functionName: "MIDIOutputPortCreate")
        }
        
        midiEndpointRef = MIDIGetDestination(destinationIndex)        
    }
    
    func sendProgramChange(channel: UInt8, program: UInt8) throws {
        
        var packet: MIDIPacket = MIDIPacket();
        packet.timeStamp = 0;
        packet.length = 3;
        packet.data.0 = 0xC0 + channel; // Note On event channel 1
        packet.data.1 = program; // Note C3
        packet.data.2 = 0; // Velocity

        var packetList:MIDIPacketList = MIDIPacketList(numPackets: 1, packet: packet);
        let status = MIDISend(midiPortRef, midiEndpointRef, &packetList)
        if status != noErr {
            throw MidiError.MidiOperationFailed(errorCode: status, functionName: "MIDISend")
        }
    }
    
    func sendControlChange(channel: UInt8, control: UInt8, value: UInt8) throws {
        var packet: MIDIPacket = MIDIPacket();
        packet.timeStamp = 0;
        packet.length = 3;
        packet.data.0 = 0xB0 + channel;
        packet.data.1 = control;
        packet.data.2 = value;

        var packetList:MIDIPacketList = MIDIPacketList(numPackets: 1, packet: packet);
        let status = MIDISend(midiPortRef, midiEndpointRef, &packetList)
        if status != noErr {
            throw MidiError.MidiOperationFailed(errorCode: status, functionName: "MIDISend")
        }

    }
    
    func sendbankAndProgram(channel: UInt8, bankNumber: UInt8, programNumber: UInt8) throws {
        var packet: MIDIPacket = MIDIPacket();
        packet.timeStamp = 0;
        packet.length = 6;
        packet.data.0 = 0xB0 + channel;
        packet.data.1 = 0;
        packet.data.2 = bankNumber;
        packet.data.3 = 0xC0 + channel;
        packet.data.4 = programNumber;
        packet.data.5 = 0;

        var packetList:MIDIPacketList = MIDIPacketList(numPackets: 1, packet: packet);
        let status = MIDISend(midiPortRef, midiEndpointRef, &packetList)
        if status != noErr {
            throw MidiError.MidiOperationFailed(errorCode: status, functionName: "MIDISend")
        }

    }
}
