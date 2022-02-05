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
    private var recordFile: AVAudioFile?
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
    
    private func setupAudio(trackName: String) {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.interruptSpokenAudioAndMixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            logger.warning("Unable to setup AVAudioSession shared instance")
        }
        
        discoverInput()
        
        let parts = trackName.parseFilename()
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = URL(fileURLWithPath: parts.0, relativeTo: directoryURL).appendingPathExtension(parts.1)
        
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
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(updateDisplay))
        displayLink?.add(to: .current, forMode: .default)
        displayLink?.isPaused = true
    }
    
    override init() {
      super.init()

      setupDisplayLink()
    }

    
    @objc private func updateDisplay() {
        currentPosition = currentFrame + seekFrame
        currentPosition = max(currentPosition, 0)
        currentPosition = min(currentPosition, audioLengthSamples)
        
        if currentPosition >= audioLengthSamples {
            player.stop()
            
            seekFrame = 0
            currentPosition = 0
            
            isPlaying = false
            displayLink?.isPaused = true
            
            disconnectVolumeTap()
        }
        
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
    
    private func discoverInput() {
        let audioSession = AVAudioSession.sharedInstance()
        let not = audioSession.isInputAvailable ? "" : "not"
        logger.info("input is \(not) available")
        if let availInputs = audioSession.availableInputs {
            logger.info("There are  \(availInputs.count) input(s) available")
            for input in availInputs {
                logger.info("input port name is \(input.portName) ")
                if input.portName == "Axe-Fx III" {
                    do {
                        try audioSession.setPreferredInput(input)
                        if let dataSources = audioSession.inputDataSources {
                            logger.info("there are \(dataSources.count) data sources")
                            for ds in dataSources {
                                logger.info("data source name is \(ds.dataSourceName)")
                            }
                        }
                    } catch {
                        logger.warning("setPreferredInput failed")
                    }
                }
            }
            
        }
    }
    
    func dateFormatTime(date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy.hh.mm.ss"
        return dateFormatter.string(from: date)
    }
    
    func recordBlock(buffer: AVAudioPCMBuffer, time: AVAudioTime) {
        do {
            try recordFile?.write(from: buffer)
        } catch {
            logger.warning("AVAudioFile.write failed")
        }
    }
    
    var stoppable: Bool {
        get {
            return currentPosition > 0
        }
    }
    
    func stop() {
        isPlaying = false
        if player.isPlaying {
            displayLink?.isPaused = true
            disconnectVolumeTap()

            player.stop()
        }
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
    
    func setTrackName(_ trackName: String) {
        setupAudio(trackName: trackName)
    }
    
    func setVolume(_ newVolume: Float) {
        self.engine.mainMixerNode.outputVolume = newVolume / 70.0
    }
    
    func startRecording() {
        let recordFilename = dateFormatTime(date: Date())
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let recordFileURL = URL(fileURLWithPath: recordFilename, relativeTo: directoryURL).appendingPathExtension("wav")
        
        do {
            let recordFile = try AVAudioFile(forWriting: recordFileURL, settings: engine.inputNode.inputFormat(forBus: 0).settings)
            self.recordFile = recordFile
            
            let outputFormat = engine.mainMixerNode.outputFormat(forBus: 0)
            logger.info(" outputFormat samplerate: \(outputFormat.sampleRate), channel count: \(outputFormat.channelCount)")
            
            let inputFormat = engine.inputNode.inputFormat(forBus: 0)
            let recordPermission = AVAudioSession.sharedInstance().recordPermission
            logger.info("inputFormat samplerate: \(inputFormat.sampleRate), channel count: \(inputFormat.channelCount) ")
                        
            engine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: engine.mainMixerNode.outputFormat(forBus: 0), block: recordBlock)
         } catch {
            logger.warning("AVAudioFile failed")
        }

    }
    
    func stopRecording() {
        if let uwRecordFile = self.recordFile {
            engine.inputNode.removeTap(onBus: 0)
        }        
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
    var playbackRateIndex: Int = 4 {
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
