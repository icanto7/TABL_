//
//  ClubRowView.swift
//  TABL
//
//  Created by Ignacio Canto on 12/5/25.
//

import SwiftUI
import FirebaseFirestore

struct ClubRowView: View {
    @FirestoreQuery(collectionPath: "clubs") var photos: [Photo]
    @FirestoreQuery(collectionPath: "clubs") var reviews: [Review]
    let club: Club
    
    private var firstPhoto: Photo? {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return Photo.preview
        }
        return photos.first
    }
    
    private var averageRating: String {
        guard !reviews.isEmpty else { return "N/A" }
        let total = reviews.reduce(0) { $0 + $1.rating }
        let average = Double(total) / Double(reviews.count)
        return String(format: "%.1f", average)
    }
    
    var body: some View {
        HStack {
            // Club Image
            if let photo = firstPhoto, let url = URL(string: photo.imageURLString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipped()
                        .cornerRadius(8)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white.opacity(0.6))
                        )
                }
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.white.opacity(0.6))
                    )
            }
            
            // Club Info
            VStack(alignment: .leading, spacing: 4) {
                Text(club.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(club.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Rating
            VStack {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(averageRating)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                Text("(\(reviews.count))")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.vertical, 8)
        .onAppear {
            if let clubId = club.id {
                $photos.path = "clubs/\(clubId)/photos"
                $reviews.path = "clubs/\(clubId)/reviews"
            }
        }
    }
}

#Preview {
    ClubRowView(club: Club.preview)
}
