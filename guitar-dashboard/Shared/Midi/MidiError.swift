//
//  MidiError.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 22/12/21.
//

import Foundation

enum MidiError: Error {
    case MidiOperationFailed(errorCode: OSStatus, functionName: String)
}

