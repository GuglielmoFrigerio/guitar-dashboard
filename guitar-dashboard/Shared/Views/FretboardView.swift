//
//  FretboardView.swift
//  guitar-dashboard (iOS)
//
//  Created by Guglielmo Frigerio on 12/02/22.
//

import SwiftUI

struct HexagonParameters {
    struct Segment {
        let line: CGPoint
        let curve: CGPoint
        let control: CGPoint
    }

    static let adjustment: CGFloat = 0.085

    static let segments = [
        Segment(
            line:    CGPoint(x: 0.60, y: 0.05),
            curve:   CGPoint(x: 0.40, y: 0.05),
            control: CGPoint(x: 0.50, y: 0.00)
        ),
        Segment(
            line:    CGPoint(x: 0.05, y: 0.20 + adjustment),
            curve:   CGPoint(x: 0.00, y: 0.30 + adjustment),
            control: CGPoint(x: 0.00, y: 0.25 + adjustment)
        ),
        Segment(
            line:    CGPoint(x: 0.00, y: 0.70 - adjustment),
            curve:   CGPoint(x: 0.05, y: 0.80 - adjustment),
            control: CGPoint(x: 0.00, y: 0.75 - adjustment)
        ),
        Segment(
            line:    CGPoint(x: 0.40, y: 0.95),
            curve:   CGPoint(x: 0.60, y: 0.95),
            control: CGPoint(x: 0.50, y: 1.00)
        ),
        Segment(
            line:    CGPoint(x: 0.95, y: 0.80 - adjustment),
            curve:   CGPoint(x: 1.00, y: 0.70 - adjustment),
            control: CGPoint(x: 1.00, y: 0.75 - adjustment)
        ),
        Segment(
            line:    CGPoint(x: 1.00, y: 0.30 + adjustment),
            curve:   CGPoint(x: 0.95, y: 0.20 + adjustment),
            control: CGPoint(x: 1.00, y: 0.25 + adjustment)
        )
    ]
}

struct Frets {
    static let points: [CGFloat] = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
}

struct FretboardView: View {
    
    var fretPoints: [CGFloat] = []
    
    init() {
        for index in 1...24 {
            let x: Float = 1.0/(pow(2.0, (Float(index)/12.0)))
            fretPoints.append(CGFloat(x))
        }
        
    }
    
    var body: some View {
        Path { path in
            var width: CGFloat = 1000.0
            let height = width
            path.move(to: CGPoint(x: 200, y: 100))
            path.addLine(to: CGPoint(x: 100, y: 300))
            path.addLine(to: CGPoint(x: 300, y: 300))
            path.addLine(to: CGPoint(x: 200, y: 100))
            for p in self.fretPoints {
                path.move(to: CGPoint(x: p * width, y: 20))
                path.addLine(to: CGPoint(x: p * width, y: 40))
            }
        }
        .stroke(.blue, lineWidth: 2)
    }
}

struct FretboardView_Previews: PreviewProvider {
    static var previews: some View {
        FretboardView()
.previewInterfaceOrientation(.landscapeLeft)
    }
}
