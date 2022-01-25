//
//  SongViewModel.swift
//  guitar-dashboard
//
//  Created by Guglielmo Frigerio on 21/01/22.
//

import SwiftUI
import AVFoundation
import os

class SongViewModel: NSObject, ObservableObject {
    // MARK: Private properties
    
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let timeEffect = AVAudioUnitTimePitch()
    private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SongViewModel")
    
    private var audioFile: AVAudioFile?
    private var audioSampleRate: Double = 0
    private var audioLengthSeconds: Double = 0
    
    private var seekFrame: AVAudioFramePosition = 0
    private var currentPosition: AVAudioFramePosition = 0
    private var audioSeekFrame: AVAudioFramePosition = 0
    private var audioLengthSamples: AVAudioFramePosition = 0
    
    private var needsFileScheduled = true
    private var displayLink: CADisplayLink?
    
    var playerProgress: Double = 0 {
        willSet {
            objectWillChange.send()
        }
    }
    
    var playerTime: PlayerTime = .zero {
        willSet {
            objectWillChange.send()
        }
    }
    
    private func scaledPower(power: Float) -> Float {
        guard power.isFinite else {
            return 0.0
        }
        
        let minDb: Float = -80
        
        if power < minDb {
            return 0.0
        } else if power >= 1.0 {
            return 1.0
        } else {
            return (abs(minDb) - abs(power)) / abs(minDb)
        }
    }
    
    private var currentFrame: AVAudioFramePosition {
        guard
            let lastRenderTime = player.lastRenderTime,
            let playerTime = player.playerTime(forNodeTime: lastRenderTime)
        else {
            return 0
        }
        
        return playerTime.sampleTime
    }
    
    
    private func connectVolumeTap() {
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.mainMixerNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: format
        ) { buffer, _ in
            guard let channelData = buffer.floatChannelData else {
                return
            }
            
            let channelDataValue = channelData.pointee
            let channelDataValueArray = stride(
                from: 0,
                to: Int(buffer.frameLength),
                by: buffer.stride)
                .map { channelDataValue[$0] }
            
            let rms = sqrt(channelDataValueArray.map {
                return $0 * $0
            }
                            .reduce(0, +) / Float(buffer.frameLength))
            
            let avgPower = 20 * log10(rms)
            let meterLevel = self.scaledPower(power: avgPower)
            
            DispatchQueue.main.async {
                self.meterLevel = self.isPlaying ? meterLevel : 0
            }
        }
    }
    
    private func disconnectVolumeTap() {
        engine.mainMixerNode.removeTap(onBus: 0)
        meterLevel = 0
    }
    
    private func scheduleAudioFile() {
        guard
            let file = audioFile,
            needsFileScheduled
        else {
            return
        }
        
        needsFileScheduled = false
        seekFrame = 0
        
        player.scheduleFile(file, at: nil) {
            self.needsFileScheduled = true
        }
    }
    
    private func configureEngine(with format: AVAudioFormat) {
        engine.attach(player)
        engine.attach(timeEffect)
        
        engine.connect(
            player,
            to: timeEffect,
            format: format)
        engine.connect(
            timeEffect,
            to: engine.mainMixerNode,
            format: format)
        
        engine.prepare()
        
        do {
            try engine.start()
            
            scheduleAudioFile()
            isPlayerReady = true
        } catch {
            logger.warning("Error starting the player: \(error.localizedDescription)")
        }
        
    }
    
    private func setupAudio() {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = URL(fileURLWithPath: "testTrack", relativeTo: directoryURL).appendingPathExtension("mp3")
//        guard let fileURL = Bundle.main.url(
//            forResource: "Anyway - Genesis",
//            withExtension: "mp3")
//        else {
//            return
//        }
        
        do {
            let file = try AVAudioFile(forReading: fileURL)
            let format = file.processingFormat
            
            audioLengthSamples = file.length
            audioSampleRate = format.sampleRate
            audioLengthSeconds = Double(audioLengthSamples) / audioSampleRate
            
            audioFile = file
            
            configureEngine(with: format)
        } catch {
            print("Error reading the audio file: \(error.localizedDescription)")
        }
    }
    
    
    private func updateForRateSelection() {
        let selectedRate = allPlaybackRates[playbackRateIndex]
        timeEffect.rate = Float(selectedRate.value)
    }
    
    private func updateForPitchSelection() {
        let selectedPitch = allPlaybackPitches[playbackPitchIndex]
        
        timeEffect.pitch = 1200 * Float(selectedPitch.value)
    }
    
    
    @objc private func updateDisplay() {
        // 1
        currentPosition = currentFrame + seekFrame
        currentPosition = max(currentPosition, 0)
        currentPosition = min(currentPosition, audioLengthSamples)
        
        // 2
        if currentPosition >= audioLengthSamples {
            player.stop()
            
            seekFrame = 0
            currentPosition = 0
            
            isPlaying = false
            displayLink?.isPaused = true
            
            disconnectVolumeTap()
        }
        
        // 3
        playerProgress = Double(currentPosition) / Double(audioLengthSamples)
        
        let time = Double(currentPosition) / audioSampleRate
        playerTime = PlayerTime(
            elapsedTime: time,
            remainingTime: audioLengthSeconds - time
        )
    }
    
    
    private func seek(to time: Double) {
        guard let audioFile = audioFile else {
            return
        }
        
        let offset = AVAudioFramePosition(time * audioSampleRate)
        seekFrame = currentPosition + offset
        seekFrame = max(seekFrame, 0)
        seekFrame = min(seekFrame, audioLengthSamples)
        currentPosition = seekFrame
        
        let wasPlaying = player.isPlaying
        player.stop()
        
        if currentPosition < audioLengthSamples {
            updateDisplay()
            needsFileScheduled = false
            
            let frameCount = AVAudioFrameCount(audioLengthSamples - seekFrame)
            
            player.scheduleSegment(
                audioFile,
                startingFrame: seekFrame,
                frameCount: frameCount,
                at: nil
            ) {
                self.needsFileScheduled = true
            }
            
            if wasPlaying {
                player.play()
            }
        }
        
    }
    
    
    init(trackName: String) {
        super.init()
        logger.info("init")
        setupAudio()
    }
    
    func skip(forwards: Bool) {
        let timeToSeek: Double
        
        if forwards {
            timeToSeek = 10
        } else {
            timeToSeek = -10
        }
        
        seek(to: timeToSeek)
    }
    
    func playOrPause() {
        isPlaying.toggle()
        
        if player.isPlaying {
            displayLink?.isPaused = true
            disconnectVolumeTap()
            
            player.pause()
        } else {
            displayLink?.isPaused = false
            connectVolumeTap()
            
            if needsFileScheduled {
                scheduleAudioFile()
            }
            player.play()
        }
    }
    
    func dispose() {
        player.stop()
        engine.stop()
    }
    
    let allPlaybackRates: [PlaybackValue] = [
        .init(value: 0.8, label: "0.8x"),
        .init(value: 0.85, label: "0.85x"),
        .init(value: 0.9, label: "0.90x"),
        .init(value: 0.95, label: "0.95x"),
        .init(value: 1, label: "1x"),
        .init(value: 1.05, label: "1.05")
    ]
    
    let allPlaybackPitches: [PlaybackValue] = [
        .init(value: -0.5, label: "-½"),
        .init(value: 0, label: "0"),
        .init(value: 0.5, label: "+½")
    ]
    
    var isPlaying = false {
        willSet {
            withAnimation {
                objectWillChange.send()
            }
        }
    }
    
    var isPlayerReady = false {
        willSet {
            objectWillChange.send()
        }
    }
    
    var meterLevel: Float = 0 {
        willSet {
            objectWillChange.send()
        }
    }
    var playbackRateIndex: Int = 1 {
        willSet {
            objectWillChange.send()
        }
        didSet {
            updateForRateSelection()
        }
    }
    var playbackPitchIndex: Int = 1 {
        willSet {
            objectWillChange.send()
        }
        didSet {
            updateForPitchSelection()
        }
    }
    
}
