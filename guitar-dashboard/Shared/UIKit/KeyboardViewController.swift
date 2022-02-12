//
//  KeyboardViewController.swift
//  guitar-dashboard (iOS)
//
//  Created by Guglielmo Frigerio on 05/02/22.
//

import UIKit
import os

class KeyboardViewController: UIViewController {
    let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "KeyboardViewController")


    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        logger.info("pressBegan")
        super.pressesBegan(presses, with: event)
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        logger.info("pressesEnded")
        super.pressesEnded(presses, with: event)
    }

    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        logger.info("pressesCancelled")
        super.pressesCancelled(presses, with: event)
    }
}
