//
//  PlaceLookupViewModel.swift
//  TABL
//
//  Created by Ignacio Canto on 12/4/25.
//

import Foundation
import MapKit

@MainActor
@Observable

class PlaceLookupViewModel {
    var places: [Place] = []
    
    func search(text: String, region: MKCoordinateRegion) async throws {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
        searchRequest.region = region
        
        let search = MKLocalSearch(request: searchRequest)
        
        let response = try await search.start()
        if response.mapItems.isEmpty {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No location Found"])
        }
        self.places = response.mapItems.map(Place.init)
    }
}
