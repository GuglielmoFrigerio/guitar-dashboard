//
//  SongView.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 28/12/21.
//

import SwiftUI
import os

struct SongView: View {
    let song: Song
    @State private var selected : Int? = 0
    @StateObject var viewModel: SongViewModel = SongViewModel()
    let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SongView")
    
    private func prevPatch() {
        guard let selected = selected else {
            return
        }

        if (selected > 0) {
            self.selected = selected - 1
        }
    }
    
    private func nextPatch() {
        guard let selected = selected else {
            return
        }

        if (selected < (song.patches.count - 1)) {
            self.selected = selected + 1
        }
    }
    
    private var patchView: some View {
        HStack {
            Spacer()
            
            Button {
                prevPatch()
            } label: {
                ZStack {
                    Color.rwGreen
                        .frame(
                            width: 10,
                            height: 35 * CGFloat(viewModel.meterLevel))
                        .opacity(0.9)
                    
                    Image.prevPatch
                }
            }
            .frame(width: 40)
            .font(.system(size: 45))
            .keyboardShortcut("a", modifiers: [.command])

            Spacer()
            
            Button {
                nextPatch()
            } label: {
                ZStack {
                    Color.rwGreen
                        .frame(
                            width: 10,
                            height: 35 * CGFloat(viewModel.meterLevel))
                        .opacity(0.9)
                    
                    Image.nextPatch
                }
            }
            .frame(width: 40)
            .font(.system(size: 45))
            .keyboardShortcut("b", modifiers: [.command])

            Spacer()
        }
    }
    
    private var controlsView: some View {
        VStack {
            ProgressView(value: viewModel.playerProgress)
                .progressViewStyle(
                    LinearProgressViewStyle(tint: .rwGreen))
                .padding(.bottom, 8)
            
            HStack {
                Text(viewModel.playerTime.elapsedText)
                
                Spacer()
                
                Text(viewModel.playerTime.remainingText)
            }
            .font(.system(size: 14, weight: .semibold))
            
            audioControlButtons
                .disabled(!viewModel.isPlayerReady)
                .padding(.bottom)
            
            adjustmentControlsView
        }
        .padding(.horizontal)
    }
    
    private var adjustmentControlsView: some View {
        VStack {
            HStack {
                Text("Playback speed")
                    .font(.system(size: 16, weight: .bold))
                
                Spacer()
            }
            
            Picker("Select a rate", selection: $viewModel.playbackRateIndex) {
                ForEach(0..<viewModel.allPlaybackRates.count) {
                    Text(viewModel.allPlaybackRates[$0].label)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .disabled(!viewModel.isPlayerReady)
            .padding(.bottom, 20)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.groupedBackground))
    }
    
    private var audioControlButtons: some View {
        HStack(spacing: 20) {
            Spacer()
            
            Button {
                viewModel.skip(forwards: false)
            } label: {
                Image.backward
            }
            .font(.system(size: 32))
            
            Spacer()
            
            Button {
                viewModel.stop()
            } label: {
                ZStack {
                    Color.rwGreen
                        .frame(
                            width: 10,
                            height: 35 * CGFloat(viewModel.meterLevel))
                        .opacity(0.9)
                    
                    Image.stop.opacity(viewModel.stoppable ? 1.0 : 0.1)
                }
            }
            .frame(width: 40)
            .font(.system(size: 45))
            .disabled(!viewModel.isPlaying)
            .keyboardShortcut("d", modifiers: [.command])

            Spacer()
            
            Button {
                viewModel.playOrPause()
            } label: {
                ZStack {
                    Color.rwGreen
                        .frame(
                            width: 10,
                            height: 35 * CGFloat(viewModel.meterLevel))
                        .opacity(0.5)
                    
                    viewModel.isPlaying ? Image.pause : Image.play
                }
            }
            .frame(width: 40)
            .font(.system(size: 45))
            .keyboardShortcut("c", modifiers: [.command])

            Spacer()
            
            Button {
                viewModel.skip(forwards: true)
            } label: {
                Image.forward
            }
            .font(.system(size: 32))
            
            Spacer()
        }
        .foregroundColor(.primary)
        .padding(.vertical, 20)
        .frame(height: 58)
    }
    
    private var playerView: some View {
        VStack {
            ProgressView(value: viewModel.playerProgress)
                .progressViewStyle(
                    LinearProgressViewStyle(tint: .rwGreen))
                .padding(.bottom, 8)
            
            HStack {
                Text(viewModel.playerTime.elapsedText)
                
                Spacer()
                
                Text(viewModel.playerTime.remainingText)
            }
            .font(.system(size: 14, weight: .semibold))
            
            Spacer()
            
            audioControlButtons
                .disabled(!viewModel.isPlayerReady)
                .padding(.bottom)
            
            Spacer()
            
            adjustmentControlsView
        }
        .padding(.horizontal)
    }
    
    
    init(_ song: Song) {
        self.song = song
        logger.info("init: \(song.name)")
    }
    
    
    var body: some View {
        VStack {
            ScrollViewReader {
                scrollViewReader in
                List() {
                    ForEach(song.patches, id: \.self) { patch in
                        PatchView(patch: patch, selectedPatch: self.$selected).id(patch.index)
                    }
                }
                .navigationTitle(song.name)
                .onChange(of: selected) { value in
                    self.song.selectPatch(index: value!)
                    scrollViewReader.scrollTo(selected)
                }
            }
            patchView
            playerView
        }
        .onAppear {
            viewModel.setTrackName(self.song.trackName)
            self.song.activate {
                index in
                self.selected = index
            }
            if let index = self.selected {
                self.song.selectPatch(index: index)
            }
        }
        .onDisappear {
            self.song.deactivate()
            viewModel.dispose()
        }
    }
}
