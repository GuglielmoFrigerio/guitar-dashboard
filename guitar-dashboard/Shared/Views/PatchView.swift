//
//  PatchView.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 03/01/22.
//

import Foundation
import SwiftUI

struct PatchView: View {
    
    let patch: Patch
    @Binding var selectedPatch: Int?
    
    var body: some View {
        HStack {
            Text(patch.name)
                .frame(maxWidth: .infinity)
                .font(.system(size: 45))
//            Spacer()
//            if patch.index == selectedPatch {
//                Image(systemName: "checkmark")
//                    .foregroundColor(.accentColor)
//            }
        }
        .onTapGesture {
            self.selectedPatch = patch.index
        }
    }
}
