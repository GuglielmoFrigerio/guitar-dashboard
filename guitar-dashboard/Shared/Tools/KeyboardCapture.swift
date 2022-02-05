//
//  KeyboardCapture.swift
//  guitar-dashboard
//
//  Created by Guglielmo Frigerio on 27/01/22.
//

import Foundation
import SwiftUI


class KeyTestController<Content>: UIHostingController<Content> where Content: View {

    override func becomeFirstResponder() -> Bool {
        true
    }

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "1", modifierFlags: [], action: #selector(test)),
            UIKeyCommand(input: "0", modifierFlags: [], action: #selector(test)),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [], action: #selector(test))
        ]
    }

    @objc func test(_ sender: UIKeyCommand) {
        print(">>> test was pressed")
    }

}

