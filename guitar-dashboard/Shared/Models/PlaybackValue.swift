//
//  PlaybackValue.swift
//  guitar-dashboard
//
//  Created by Guglielmo Frigerio on 23/01/22.
//

import Foundation

struct PlaybackValue: Identifiable {
  let value: Double
  let label: String

  var id: String {
    return "\(label)-\(value)"
  }
}
