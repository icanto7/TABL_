//
//  Club.swift
//  TABL
//
//  Created by Ignacio Canto on 12/4/25.
//

import Foundation
import FirebaseFirestore

struct Club: Codable, Identifiable {
    @DocumentID var id: String?
    var name = ""
    var image = ""
    var description = ""
}
