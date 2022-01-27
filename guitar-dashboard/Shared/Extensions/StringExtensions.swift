//
//  StringExtensions.swift
//  guitar-dashboard
//
//  Created by Guglielmo Frigerio on 27/01/22.
//

import Foundation

extension String {
    var encoded: String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
    
    func parseFilename() -> (String, String) {
        let parts = self.components(separatedBy: ".")
        assert(parts.count > 0, "String.components failed")
        return parts.count > 1 ? (parts[0], parts[1]) : (parts[0], "")
    }
}
