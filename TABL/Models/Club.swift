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
    var address = ""
    var description = ""
    var link = ""
    var latitue = 0.0
    var longuitude = 0.0
    
}

extension Club {
    static var preview: Club {
        let newClub = Club(id: "1", name: "Bijou", address: "51 Stuart St, Boston, MA 02116 ", description: "nightclub and lounge", link: "https://bijouboston.com", latitue: 42.35158703749007, longuitude: -71.06402230674023)
        return newClub
    }
    
}
