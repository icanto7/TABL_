//
//  StarSelectionView.swift
//  TABL
//
//  Created by Ignacio Canto on 12/4/25.
//

import SwiftUI

struct StarSelectionView: View {
    @Binding var rating: Int
    let highestRating: Int = 5
    let unselected = Image(systemName: "star")
    let selected = Image(systemName: "star.fill")
    let font: Font = .largeTitle
    let fillColor: Color = .white
    let emptyColor: Color = .gray
    
    var body: some View {
        HStack {
            ForEach(1...highestRating, id: \.self) { number in
                    showStar(for: number)
                    .foregroundColor(number <= rating ? fillColor : emptyColor)
                    .onTapGesture {
                        rating = number
                    }
            }
            .font(font)
            
        }
    }
    func showStar( for number: Int) -> Image {
        if number > rating {
            return unselected
        } else {
         return selected
        }
    }
}

#Preview {
    StarSelectionView(rating: .constant(4))
}
