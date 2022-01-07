//
//  SongView.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 28/12/21.
//

import SwiftUI

struct SongView: View {
    let song: Song
    @State private var singleSelection : UUID?
    
    init(_ song: Song) {
        self.song = song
    }
    
    var body: some View {
        List(selection: $singleSelection) {
            ForEach(song.patches, id: \.self) { patch in
                Text(patch.name)
            }
        }
        .navigationTitle(song.name)
   }
    
}
