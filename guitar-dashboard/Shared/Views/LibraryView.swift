//
//  SongListView.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 28/12/21.
//

import SwiftUI

struct LibraryView: View {
    let library: Library
    
    init (_ library:Library) {
        self.library = library
    }
    
    var body: some View {
        List() {
            ForEach(library.songs, id: \.self) { song in
                NavigationLink(destination: SongView(song)) {
                    Text(song.name)
                }

            }
        }
    }
}
