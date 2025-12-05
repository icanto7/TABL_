//
//  FavoritesManager.swift
//  TABL
//
//  Created by Ignacio Canto on 12/5/25.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
class FavoritesManager: ObservableObject {
    @Published var favoriteClubIds: Set<String> = []
    private let db = Firestore.firestore()
    
    init() {
        loadFavorites()
    }
    
    func loadFavorites() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                print("Error loading favorites: \(error)")
                return
            }
            
            if let data = snapshot?.data(),
               let favorites = data["favoriteClubs"] as? [String] {
                DispatchQueue.main.async {
                    self?.favoriteClubIds = Set(favorites)
                }
            }
        }
    }
    
    func toggleFavorite(clubId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if favoriteClubIds.contains(clubId) {
            favoriteClubIds.remove(clubId)
        } else {
            favoriteClubIds.insert(clubId)
        }
        
        // Update Firestore
        db.collection("users").document(userId).setData([
            "favoriteClubs": Array(favoriteClubIds)
        ], merge: true) { error in
            if let error = error {
                print("Error updating favorites: \(error)")
            }
        }
    }
    
    func isFavorite(_ clubId: String) -> Bool {
        return favoriteClubIds.contains(clubId)
    }
    
    func getFavoriteClubs(from clubs: [Club]) -> [Club] {
        return clubs.filter { club in
            guard let clubId = club.id else { return false }
            return favoriteClubIds.contains(clubId)
        }
    }
}
