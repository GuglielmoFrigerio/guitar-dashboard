//
//  StatusBarView.swift
//  guitar-dashboard
//
//  Created by Guglielmo Frigerio on 29/01/22.
//

import Foundation
import SwiftUI

struct StatusBarView: View {
    @StateObject var viewModel  = StatusBarViewModel()
    
    var body: some View {
        HStack {
            Image(systemName: "keyboard").opacity(false ? 1.0 : 0.2)
            Image(systemName: "keyboard.badge.ellipsis").opacity(viewModel.isAxeFx3Connected ? 1.0 : 0.2)
        }
        .onAppear {
            viewModel.loadState()
        }
    }    
}
