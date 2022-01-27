//
//  TrackLoader.swift
//  guitar-dashboard
//
//  Created by Guglielmo Frigerio on 27/01/22.
//

import Foundation
import os

class TrackLoader: TrackLoaderProtocol {
    private var baseUrl = "http://192.168.1.58:5074/api/Tracks/"
    private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TrackLoader")
    private let directoryURL: URL
        
    init() {
        let fm = FileManager.default;
        directoryURL = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]

    }

    func loadTrack(name: String) {
        guard let urlEncodedTrackName = name.encoded else {
            logger.warning("unable to encode '\(name)'")
            return
        }
        
        let urlString = "\(self.baseUrl)\(urlEncodedTrackName)"
        guard let url = URL(string: urlString) else {
            logger.warning("Unable to obtain url for '\(urlString)'")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else {
                self.logger.warning("unable to download track from '\(url)'")
                return
            }
            let parts = name.parseFilename()
            let fileURL = URL(fileURLWithPath: parts.0, relativeTo: self.directoryURL).appendingPathExtension(parts.1)
            do {
                try data.write(to: fileURL)
                self.logger.info("Track '\(name)' loaded")
            } catch {
                self.logger.warning("data.write failed")
            }
        }

        task.resume()
    }
}
