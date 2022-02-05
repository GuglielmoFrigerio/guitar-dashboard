//
//  Recorder.swift
//  guitar-dashboard
//
//  Created by Guglielmo Frigerio on 04/02/22.
//

import SwiftUI

struct RecorderView: View {
    var viewModel: SongViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            Spacer()
            Button {
                viewModel.startRecording()
            } label: {
                Image.stop
            }
            .font(.system(size: 32))
            
            Spacer()
            
            Button {
                viewModel.stopRecording()
            } label: {
                Image.record
            }
            .frame(width: 40)
            .font(.system(size: 45))
            
            Spacer()

        }
    }
}
