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
    
    init(_ song: Song) {
        self.song = song
    }
    
        
    var body: some View {
        List() {
            ForEach(song.patches, id: \.self) { patch in
                PatchView(patch: patch, selectedPatch: self.$selected)
            }
        }
        .navigationTitle(song.name)
        .onChange(of: selected) { value in
            self.song.selectPatch(index: value!)
        }
        .onAppear {
            self.song.activate {
                index in
            }
        }
        .onDisappear {
            self.song.deactivate()
        }
   }
    
}
