//
//  PlaceLookupView.swift
//  TABL
//
//  Created by Ignacio Canto on 12/4/25.
//

import SwiftUI
import MapKit

struct PlaceLookupView: View {
    let locationManager: LocationManager
    @Binding var club: Club
    @State var placeVM = PlaceLookupViewModel()
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>?
    @State private var searchRegion = MKCoordinateRegion()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dark background
                Color.black
                    .ignoresSafeArea()
                
                Group {
                    if searchText.isEmpty {
                        ContentUnavailableView("No Results", systemImage: "mappin.slash")
                            .foregroundColor(.white)
                    } else {
                        List(placeVM.places) { place in
                            VStack(alignment: .leading) {
                                Text(place.name)
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text(place.address)
                                    .font(.callout)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .listRowBackground(Color.gray.opacity(0.2))
                            .onTapGesture {
                                club.name = place.name
                                club.address = place.address
                                club.latitue = place.latitude
                                club.longuitude = place.longitude
                                dismiss()
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Location Search:")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .searchable(text: $searchText)
        .autocorrectionDisabled()
        .onAppear {
            searchRegion = locationManager.getRegionArroundCurrentLocation() ?? MKCoordinateRegion()
        }
        .onDisappear {
            searchTask?.cancel()
        }
        .onChange(of: searchText) { oldValue, newValue in
            searchTask?.cancel()
            guard !newValue.isEmpty else {
                placeVM.places.removeAll()
                return
            }
            
            searchTask = Task {
                do {
                    try await Task.sleep(for: .milliseconds(300))
                    if Task.isCancelled { return }
                    if searchText == newValue {
                        try await placeVM.search(text: newValue, region: searchRegion)
                    }
                } catch {
                    if !Task.isCancelled {
                        print("ERROR: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

#Preview {
    PlaceLookupView(locationManager: LocationManager(), club: .constant(Club()))
}
