//
//  DeviceManagerProtocol.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 30/12/21.
//

import Foundation

protocol DeviceManagerProtocol {
    var libraries: [Library] { get }
    
    func send(patch: Patch)
    
    func subscribePedalboard(onPedalboardKey: @escaping (PedalboardKey) -> Void)
    func unsubscribePedaboard()    
}
