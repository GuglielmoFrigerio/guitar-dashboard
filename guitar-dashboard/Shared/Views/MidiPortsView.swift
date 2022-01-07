//
//  MidiPortsView.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 29/12/21.
//

import SwiftUI

struct MidiPortsView: View {
    var midiFactory: MidiFactoryProtocol?
    var midiSourceNames: [String] = []
    var midiDestinationNames: [String] = []
    
    init() {
        self.midiFactory = DIContainer.shared.resolve(type: MidiFactoryProtocol.self)
        if let msn = midiFactory?.getMidiSources() {
            self.midiSourceNames = msn
        }
        if let mdn = midiFactory?.getMidiDestinations() {
            self.midiDestinationNames = mdn
        }
    }
    
    
    var body: some View {
        List() {
            Section(header: Text("Sources")) {
                ForEach(midiSourceNames, id: \.self) { name in
                    Text(name)
                }
            }
            Section(header: Text("Destinations")) {
                ForEach(midiDestinationNames, id: \.self) { name in
                    Text(name)
                }
            }
        }
    }
}
