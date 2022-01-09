//
//  MidiPacket.swift
//  guitar-dashboard
//
//  Created by Guglielmo Frigerio on 09/01/22.
//

import Foundation

struct MidiPacket {
    let first: UInt8
    let second: UInt8
    let third: UInt8
    let fourth: UInt8
    
    init(first: UInt8, second: UInt8, third: UInt8, fourth: UInt8) {
        self.first = first
        self.second = second
        self.third = third
        self.fourth = fourth        
    }
}
