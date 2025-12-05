//
//  Photo.swift
//  TABL
//
//  Created by Ignacio Canto on 12/4/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import Foundation
import FirebaseAuth

class Photo: Identifiable, Codable {
    @DocumentID var id: String?
    var imageURLString = "" // This will hold the URL for loading the image
    var description = ""
    var reviewer: String = Auth.auth().currentUser?.email ?? ""
    var postedOn = Date() // current date/time
    
    init(id: String? = nil, imageURLString: String = "", description: String = "", reviewer: String = (Auth.auth().currentUser?.email ?? ""), postedOn: Date = Date()) {
        self.id = id
        self.imageURLString = imageURLString
        self.description = description
        self.reviewer = reviewer
        self.postedOn = postedOn
    }
}

extension Photo {
    static var preview: Photo {
        let newPhoto = Photo(id: "1", imageURLString: "https://images.squarespace-cdn.com/content/v1/5b2a81f5b27e392c36a4ed64/1691153030586-JIYN7OYDKA9BYC754KRC/Bijou-4021.jpg?format=1000w", description: "club interior", reviewer: "john.doe123@gmail.com", postedOn: Date())
        return newPhoto
    }
}






