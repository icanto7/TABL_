//
//  ReviewView.swift
//  TABL
//
//  Created by Ignacio Canto on 12/4/25.
//

import SwiftUI

struct ReviewView: View {
    @State var club: Club
    @State var review: Review
    @State var reviewVM = ReviewViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black
                .ignoresSafeArea()
            
            VStack {
                VStack(alignment: .leading) {
                    Text(club.name)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                    Text(club.address)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                    Text(club.description)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .padding(.bottom)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack {
                    Text("How many stars?")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    HStack {
                        StarSelectionView(rating: $review.rating)
                    }
                    .padding(.bottom)
                    
                    VStack(alignment: .leading) {
                        Text("Review Title:")
                            .bold()
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            
                        TextField("title", text: $review.title)
                            .textFieldStyle(.roundedBorder)
                            .colorScheme(.dark)
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            }
                        Text("Review:")
                            .bold()
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            
                        TextField("review", text: $review.body, axis: .vertical)
                            .padding(.horizontal, 6)
                            .frame(maxHeight: .infinity, alignment: .topLeading)
                            .colorScheme(.dark)
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.white)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    // Check if we're in preview mode
                    #if targetEnvironment(simulator)
                    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                        // In preview, just dismiss without saving
                        print("Preview mode: Skipping Firebase save")
                        dismiss()
                        return
                    }
                    #endif
                    
                    Task {
                        await ReviewViewModel.saveReview(club: club, review: review)
                    }
                    dismiss()
                }
                .foregroundColor(.white)
            }
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        ReviewView(club: Club(id: "preview-club-id", name: "Hava Nightclub", address: "246 Tremont St Boston, MA 02116", description: "Celebrate love, identity, and music in full colour"), review: Review())
    }
}
