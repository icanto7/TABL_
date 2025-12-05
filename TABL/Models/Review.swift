//
//  Review.swift
//  TABL
//
//  Created by Ignacio Canto on 12/4/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore


struct Review: Identifiable, Codable {
    @DocumentID var id: String?
    var title = ""
    var body = ""
    var rating = 0
    var reviewer = ""
    var postedOn = Date()
    
    var dictonary: [String: Any] {
        return ["title": title, "body": body, "rating": rating, "reviewer": Auth.auth().currentUser?.email ?? "", "postedOn": Timestamp(date: Date())]
    }
}
