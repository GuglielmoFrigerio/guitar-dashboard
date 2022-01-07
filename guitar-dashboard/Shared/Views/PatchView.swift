//
//  PatchView.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 03/01/22.
//

import Foundation
import SwiftUI

struct PatchView: View {
    var index: Int
    var name: String
    @Binding var selectedPatch: Int?
    
    var body: some View {
        HStack {
            Text(name)
            Spacer()
            if index == selectedPatch {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
        .onTapGesture {
            self.selectedPatch = index
        }
    }
}
