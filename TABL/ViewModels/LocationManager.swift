//
//  LocationManager.swift
//  TABL
//
//  Created by Ignacio Canto on 12/4/25.
//

import Foundation
import MapKit
import SwiftUI

@Observable

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    var location: CLLocation?
    private let locationManager = CLLocationManager()
    var errorMessage: String?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var locationUpdated: ((CLLocation) -> Void)?
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func getRegionArroundCurrentLocation(radiusInMeters: CLLocationDistance = 10000) -> MKCoordinateRegion? {
        guard let location = location else { return nil }
        return MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radiusInMeters,
            longitudinalMeters: radiusInMeters
        )
    }
}

extension LocationManager {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        location = newLocation
        locationUpdated?(newLocation)
        manager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Location granted")
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location denied")
            errorMessage = "Location access denied"
            manager.stopUpdatingLocation()
        case .notDetermined:
            print("Location not determined")
            manager.requestWhenInUseAuthorization()
        @unknown default:
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        errorMessage = error.localizedDescription
        print("🗺️ERROR LocationManger: \(errorMessage ?? "")")
    }
}
