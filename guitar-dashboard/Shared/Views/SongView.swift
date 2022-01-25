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
    @State private var selected : Int? = 1
    @StateObject var viewModel: SongViewModel = SongViewModel(trackName: "")
    let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SongView")
    
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

        HStack {
          Text("Pitch adjustment")
            .font(.system(size: 16, weight: .bold))

          Spacer()
        }

        Picker("Select a pitch", selection: $viewModel.playbackPitchIndex) {
          ForEach(0..<viewModel.allPlaybackPitches.count) {
            Text(viewModel.allPlaybackPitches[$0].label)
          }
        }
        .pickerStyle(SegmentedPickerStyle())
        .disabled(!viewModel.isPlayerReady)
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
            playerView
        }
        .onAppear {
            self.song.activate {
                index in
                self.selected = index
            }
        }
        .onDisappear {
            self.song.deactivate()
            viewModel.dispose()
        }
   }    
}
