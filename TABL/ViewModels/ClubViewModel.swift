//
//  ClubViewModel.swift
//  TABL
//
//  Created by Ignacio Canto on 12/4/25.
//

import Foundation
import FirebaseFirestore

@Observable
class ClubViewModel {
static func saveClub(club: Club) async -> String? { // nil if effort failed, otherwise return place.id
        let db = Firestore.firestore()
        
        if let id = club.id { // if true the place exists
            do {
                try db.collection("clubs").document(id).setData(from: club)
                print("😎 Data updated successfully!")
                return id
            } catch {
                print("😡 Could not update data in 'clubs' \(error.localizedDescription)")
                return id
            }
        } else { // We need to add a new place & create a new id / document name
            do {
                let docRef = try db.collection("clubs").addDocument(from: club)
                print("🐣 Data added successfully!")
                return docRef.documentID
            } catch {
                print("😡 Could not create a new club in 'clubs' \(error.localizedDescription)")
                return nil
            }
        }
    }
}
