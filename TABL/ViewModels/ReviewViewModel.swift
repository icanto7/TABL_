//
//  ReviewViewModel.swift
//  TABL
//
//  Created by Ignacio Canto on 12/4/25.
//
import Foundation
import FirebaseFirestore

@Observable
class ReviewViewModel {
    static func saveReview(club: Club, review: Review) async -> String? { // nil if effort failed, otherwise return place.id
        // Check if we're in preview mode and skip Firebase operations
        #if targetEnvironment(simulator)
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            print("Preview mode: Skipping Firebase save for review")
            return "preview-review-id"
        }
        #endif
        
        let db = Firestore.firestore()
        
        if let id = review.id { // if true the place exists
            do {
                try db.collection("clubs/\(club.id ?? "")/reviews").document(id).setData(from: review)
                print("😎 Data updated successfully!")
                return id
            } catch {
                print("😡 Could not update data in 'clubs' \(error.localizedDescription)")
                return id
            }
        } else { // We need to add a new place & create a new id / document name
            do {
                let docRef = try db.collection("clubs/\(club.id ?? "")/reviews").addDocument(from: review)
                print("🐣 Data added successfully!")
                return docRef.documentID
            } catch {
                print("😡 Could not create a new club in 'clubs' \(error.localizedDescription)")
                return nil
            }
        }
    }
    static func deleteClub(club: Club) {
        let db = Firestore.firestore()
        guard let id = club.id else {
            print("Tried to delete a club with no id!")
            return
        }
        Task {
            do {
                try await db.collection("clubs").document(id).delete()
                print("🗑️ Successfully deleted!")
            } catch {
                print("😡 ERROR: Could not delete document \(id). \(error.localizedDescription)")
            }
        }
    }
}
