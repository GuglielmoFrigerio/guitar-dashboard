//
//  Pedalboard.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 05/01/22.
//

import Foundation

class Pedalboard {
    
    let midiInputPort: MidiInputPort
    
    init (midiInputPort: MidiInputPort) {
        self.midiInputPort = midiInputPort
    }
}
