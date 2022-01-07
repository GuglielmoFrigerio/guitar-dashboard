//
//  MidiFactoring.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 29/12/21.
//

import Foundation

protocol MidiFactoryProtocol {
    func getMidiSources() -> [String]
    func getMidiDestinations() -> [String]
}
