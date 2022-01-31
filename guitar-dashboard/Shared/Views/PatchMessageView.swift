//
//  PatchMessageView.swift
//  guitar-dashboard
//
//  Created by Guglielmo Frigerio on 30/01/22.
//

import SwiftUI

struct PatchMessageView: View {
    let message: String
    @State private var color = Color.red
    
    init(message: String) {
        self.message = message
    }
    
    var repeatingAnimation: Animation {
        Animation
            .easeInOut(duration: 0.3)
            .repeatForever()
    }
    
    var body: some View {
        Text(self.message)
            .foregroundColor(Color.white)
            .colorMultiply(self.color)
            .onAppear {
                withAnimation(self.repeatingAnimation) {
                    self.color = Color.white
                }
            }
            .font(.system(size: 35))
    }
}

struct PatchMessageView_Previews: PreviewProvider {
    static var previews: some View {
        PatchMessageView(message: "Sample message")
    }
}
