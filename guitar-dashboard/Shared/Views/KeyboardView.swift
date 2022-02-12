//
//  KeyboardView.swift
//  guitar-dashboard (iOS)
//
//  Created by Guglielmo Frigerio on 12/02/22.
//

import SwiftUI

struct KeyboardView: View {
    @State var text = NSMutableAttributedString(string: "")
    
    var body: some View {
        TextView(text: $text)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)    }
}
