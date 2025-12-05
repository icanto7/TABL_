//
//  PhotoViewModel.swift
//  TABL
//
//  Created by Ignacio Canto on 12/4/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import Foundation
import FirebaseAuth 

class PhotoViewModel {
    
    static func saveImage(club: Club, photo: Photo, data: Data) async {
        guard let id = club.id else {
            print("😡 ERROR: Should never have been called without a valid place.id")
            return
        }
        
        let storage = Storage.storage().reference()
        let metadata = StorageMetadata()
        if photo.id == nil {
            photo.id = UUID().uuidString // create a unique filename for the photo about to be saved
        }
        metadata.contentType = "image/jpeg"
        // will allow image to be viewed in the browser from the Firebase console
        let path = "\(id)/\(photo.id ?? "n/a")"
        
        do {
            let storageRef = storage.child(path)
            let returnedMetaData = try await storageRef.putDataAsync(data, metadata: metadata)
            print("😎 SAVED! \(returnedMetaData)")
            
            // get URL that we'll use to load the image
            guard let url = try? await storageRef.downloadURL() else {
                print("😡 ERROR Could not get downloadURL.")
                return
            }
            photo.imageURLString = url.absoluteString
            print("photo.imageURLString: \(photo.imageURLString)")
            
            // Now that photo file is saved to Storage, save a Photo document to the place.id's "Photos" collection
            let db = Firestore.firestore()
            do {
                try db.collection("clubs").document(id).collection("photos").document(photo.id ?? "n/a").setData(from: photo)
            } catch {
                print("😡 ERROR could not update data in places/\(id)/photos/\(photo.id ?? "n/a"). \(error.localizedDescription)")
            }
        } catch {
            print("😡 ERROR saving photo to Storage \(error.localizedDescription)")
        }
    }
    
}
