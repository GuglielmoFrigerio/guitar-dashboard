//
//  MidiEndpointCollection.swift
//  guitar-dashboard
//
//  Created by Guglielmo Frigerio on 13/01/22.
//

import Foundation

typealias MidiEndpointClosure = ((String, Int) -> Void)

class MidiEndpointCollection {
    private class EndpointContext {
        let listener: MidiEndpointClosure
        var index: Int? = nil
        
        init(_ listener: @escaping MidiEndpointClosure) {
            self.listener = listener
        }
    }
    
    private var monitors: [String: EndpointContext] = [:]
    
    func subscribe(name: String, listener: @escaping MidiEndpointClosure) {
        monitors[name] = EndpointContext(listener)
    }
    
    func compareCollection(endpoints: [String: Int]) {
        
        for (key, value) in monitors {
            let endpointIndex = endpoints[key]
            if let uwEndpointIndex = endpointIndex {
                if value.index == nil {
                    value.index = uwEndpointIndex
                    value.listener(key, uwEndpointIndex)
                }
            } else if value.index != nil {
                value.index = nil
                value.listener(key, -1)
            }
        }
    }
}
