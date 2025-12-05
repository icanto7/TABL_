//
//  DetailView.swift
//  TABL
//
//  Created by Ignacio Canto on 12/4/25.
//

import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseFirestore
import MapKit

//To-do add location

struct ClubDetailView: View {
    @FirestoreQuery(collectionPath: "clubs") var fsPhotos: [Photo]
    @State var club: Club
    @Environment(\.dismiss) private var dismiss
    @State private var photo: Photo? // Holds the first photo from the subcollection
    @State private var photoSheetIsPresented = false
    @State private var showingAlert = false // Alert user if they need to save Place before adding a Photo
    @State private var alertMessage = "Cannot add a Photo until you save the Place."
    private var photos: [Photo] {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return[Photo.preview, Photo.preview, Photo.preview, Photo.preview, Photo.preview]
        }
        return fsPhotos
    }
    private let mapDimension = 750.0
    private var mapCameraPosition: MapCameraPosition {
        let coordinate = CLLocationCoordinate2D(latitude: club.latitue, longitude: club.longuitude)
        return .region(MKCoordinateRegion(center: coordinate, latitudinalMeters: mapDimension, longitudinalMeters: mapDimension))
    }
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                VStack (alignment: .leading) {
                    Text("Club:")
                        .bold()
                        .foregroundColor(.white)
                    TextField("club", text: $club.name)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 1)
                        )
                        .background(Color.clear)
                        .foregroundColor(.white)
                        .colorScheme(.dark)
                    
                    Text("Description:")
                        .bold()
                        .foregroundColor(.white)
                    TextField("description", text: $club.description)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 1)
                        )
                        .background(Color.clear)
                        .foregroundColor(.white)
                        .colorScheme(.dark)
                        .padding(.bottom)
                    
                    Text("Table Reservation Link:")
                        .bold()
                        .foregroundColor(.white)
                    HStack {
                        TextField("https://example.com", text: $club.link)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .background(Color.clear)
                            .foregroundColor(.white)
                            .colorScheme(.dark)
                        
                        if !club.link.isEmpty {
                            Button(action: {
                                openLink()
                            }) {
                                Image(systemName: "link")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                }
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(photos) { photo in
                            let url = URL(string: photo.imageURLString)
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipped()
                                    .cornerRadius(8)
                            } placeholder: {
                                ProgressView()
                                    .tint(.white)
                            }
                        }
                    }
                }
                .frame(height: 150)
                
                Button {
                    if club.id == nil { // Ask if you want to save
                        showingAlert.toggle()
                    } else { // Go right to PhotoView
                        photoSheetIsPresented.toggle()
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Photo")
                    }
                    .foregroundColor(.black)
                }
                .bold()
                .padding(.bottom)
                .tint(.white)
                .buttonStyle(.glassProminent)
                
                Map(position: .constant(mapCameraPosition)) {
                    Marker(club.name, coordinate: CLLocationCoordinate2D(latitude: club.latitue, longitude: club.longuitude))
                        .tint(.white)
                    
                    UserAnnotation()
                }
                .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll, showsTraffic: false))
                .mapControls {
                    MapUserLocationButton()
                        .mapControlVisibility(.hidden)
                    MapCompass()
                        .mapControlVisibility(.hidden)
                }
                .colorScheme(.dark)
                .frame(height: 250)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                
                Spacer()
                    
                }
                .padding(.horizontal)
            }
        }
        .navigationBarBackButtonHidden()
        .task {
            guard let id = club.id else {
                return
            }
            $fsPhotos.path = "clubs/\(id)/photos"
        }
        .font(.title)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    dismiss()
                }
                .foregroundColor(.white)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", systemImage: "checkmark") {
                    Task {
                        let id = await ClubViewModel.saveClub(club: club)
                        if id == nil {
                            print("😡 ERROR: Save on DetailView did not work")
                        } else {
                            dismiss()
                        }
                    }
                    dismiss()
                }
                .foregroundColor(.white)
            }
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                // We want to return place.id after saving a new Place. Right now it's nil
                Task {
                    guard let id = await ClubViewModel.saveClub(club: club) else {
                        print("😡 ERROR: Saving club in alert returned nil")
                        return
                    }
                    club.id = id
                    print(club)
                    $fsPhotos.path = "spots/\(id)/photos"
                    photoSheetIsPresented.toggle() // Now open sheet & move to PhotoView
                }
            }
        }
        .fullScreenCover(isPresented: $photoSheetIsPresented, onDismiss: {
            // Reload photo when user returns from PhotoView
            Task {
                await loadFirstPhoto()
            }
        }) {
            PhotoView(club: club)
        }

    }
    func loadFirstPhoto() async {
        guard let clubId = club.id else {
            print("⚠️ No place ID - can't load photos")
            return
        }
        
        let db = Firestore.firestore()
        do {
            let snapshot = try await db.collection("places")
                .document(clubId)
                .collection("photos")
                .limit(to: 1)
                .getDocuments()
            
            if let document = snapshot.documents.first {
                photo = try document.data(as: Photo.self)
                print("📸 Loaded photo: \(photo?.imageURLString ?? "no url")")
            }
        } catch {
            print("😡 ERROR loading photo: \(error.localizedDescription)")
        }
    }
    
    func openLink() {
        guard !club.link.isEmpty else { return }
        
        var urlString = club.link
        // Add https:// if no protocol is specified
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        
        guard let url = URL(string: urlString) else {
            print("⚠️ Invalid URL: \(urlString)")
            return
        }
        
        #if os(iOS)
        UIApplication.shared.open(url)
        #elseif os(macOS)
        NSWorkspace.shared.open(url)
        #endif
    }
}
    
    
#Preview {
    ClubDetailView(club: Club.preview)
}
