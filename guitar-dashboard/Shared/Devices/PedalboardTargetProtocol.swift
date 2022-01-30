//
//  PedalboardTargetProtocol.swift
//  guitar-dashboard
//
//  Created by Guglielmo Frigerio on 30/01/22.
//

import Foundation

protocol PedalboardTargetProtocol {
    func patchSelected(index: Int)
    func playOrPause()
    func stop()
}
