//
//  SongView.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 28/12/21.
//

import SwiftUI

struct SongView: View {
    let song: Song
    @State private var selected : Int? = 1
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    init(_ song: Song) {
        self.song = song
    }
    
    var body: some View {
        List() {
            ForEach(song.patches, id: \.self) { patch in
                PatchView(index: patch.index, name: patch.name, selectedPatch: self.$selected)
            }
        }
        .navigationTitle(song.name)
        .onReceive(timer) { input in
            self.selected! += 1
        }
        .onChange(of: selected) { value in
            print("selected \(value!)")
        }
   }
    
}
