//
//  ListLabView.swift
//  guitar-dashboard-for-ios
//
//  Created by Guglielmo Frigerio on 01/01/22.
//

import Foundation
import SwiftUI

struct SelectionView: View {

    let fruit = ["apples", "pears", "bananas", "pineapples"]
    @State var selectedFruit: String? = nil

    var body: some View {
        List {
            ForEach(fruit, id: \.self) { item in
                SelectionCell(fruit: item, selectedFruit: self.$selectedFruit)
            }
        }
    }
}

struct SelectionCell: View {

    let fruit: String
    @Binding var selectedFruit: String?

    var body: some View {
        HStack {
            Text(fruit)
            Spacer()
            if fruit == selectedFruit {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }   .onTapGesture {
                self.selectedFruit = self.fruit
            }
    }
}
