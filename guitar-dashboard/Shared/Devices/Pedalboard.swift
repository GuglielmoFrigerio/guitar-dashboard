//
//  Pedalboard.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 05/01/22.
//

import Foundation

enum PedalboardKey: CustomStringConvertible {
    case first
    case second
    case third
    case fourth
    
    var description: String {
        switch self {
        case .first:
            return "First"
            
        case .second:
            return "Second"
            
        case .third:
            return "Third"
            
        case .fourth:
            return "Fourth"
        }
    }
}

class Pedalboard {
    
    let midiInputPort: MidiInputPort
    let keyListener: (PedalboardKey) -> Void;
    
    init (midiInputPort: MidiInputPort, keyListener: @escaping (PedalboardKey) -> Void) {
        self.midiInputPort = midiInputPort
        self.keyListener = keyListener
        midiInputPort.onMidiPacket(packetListener: {
            midiPacket in
            if midiPacket.second == 144 {
                switch midiPacket.third {
                case 50:
                    self.keyListener(.first)
                    
                case 51:
                    self.keyListener(.second)
                    
                case 52:
                    self.keyListener(.third)
                    
                case 53:
                    self.keyListener(.fourth)
                    
                default:
                    break
                }
            }
        })
    }
}
