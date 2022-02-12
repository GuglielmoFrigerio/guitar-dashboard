//
//  KeyboardControllerWrapper.swift
//  guitar-dashboard (iOS)
//
//  Created by Guglielmo Frigerio on 12/02/22.
//

import UIKit
import SwiftUI

struct KeyboardControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = KeyboardViewController
    
    func makeUIViewController(context: Context) -> KeyboardViewController {
        return KeyboardViewController()
    }
    
    func updateUIViewController(_ uiViewController: KeyboardViewController, context: Context) {
    }
}

struct TextView: UIViewRepresentable {
    @Binding var text: NSMutableAttributedString

    func makeUIView(context: Context) -> UITextView {
        UITextView()
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = text
    }
}
