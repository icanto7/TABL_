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

struct TablePrice: Identifiable {
    let id = UUID()
    var tableNumber: String
    var price: String
}

struct ClubDetailView: View {
    @FirestoreQuery(collectionPath: "clubs") var fsPhotos: [Photo]
    @State var club: Club
    @Environment(\.dismiss) private var dismiss
    @State private var photo: Photo? // Holds the first photo from the subcollection
    @State private var photoSheetIsPresented = false
    @State private var showingAlert = false // Alert user if they need to save Place before adding a Photo
    @State private var alertMessage = "Cannot add a Photo until you save the Place."
    @State private var showTableMapSheet = false
    @State private var tableNumber = ""
    @State private var tablePrice = ""
    @State private var tablePrices: [TablePrice] = []
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
                .tint(.white)
                .buttonStyle(.glassProminent)
                
                Button {
                    showTableMapSheet.toggle()
                } label: {
                    HStack {
                        Image(systemName: "map")
                        Text("Add Table Map")
                    }
                    .foregroundColor(.black)
                }
                .bold()
                .padding(.top, 8)
                .tint(.white)
                .buttonStyle(.glassProminent)
                
                // Table Pricing Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Table Pricing:")
                        .bold()
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    // Add new table row
                    HStack(spacing: 12) {
                        TextField("Table #", text: $tableNumber)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .background(Color.clear)
                            .foregroundColor(.white)
                            .colorScheme(.dark)
                            .keyboardType(.numberPad)
                        
                        TextField("Price ($)", text: $tablePrice)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .background(Color.clear)
                            .foregroundColor(.white)
                            .colorScheme(.dark)
                            .keyboardType(.decimalPad)
                        
                        Button {
                            addTablePrice()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        .disabled(tableNumber.isEmpty || tablePrice.isEmpty)
                    }
                    
                    // Display existing table prices
                    if !tablePrices.isEmpty {
                        VStack(spacing: 8) {
                            ForEach(tablePrices) { tablePrice in
                                HStack {
                                    Text("Table \(tablePrice.tableNumber)")
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("$\(tablePrice.price)")
                                        .foregroundColor(.green)
                                        .bold()
                                    
                                    Button {
                                        removeTablePrice(tablePrice)
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.bottom)
                
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
        .sheet(isPresented: $showTableMapSheet) {
            NavigationStack {
                VenueSeatingMapView()
                    .navigationTitle("Table Map Preview")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarBackButtonHidden()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showTableMapSheet = false
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .toolbarBackground(Color.black, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
            }
            .preferredColorScheme(.dark)
        }
    }
    
    func addTablePrice() {
        guard !tableNumber.isEmpty && !tablePrice.isEmpty else { return }
        
        let newTablePrice = TablePrice(tableNumber: tableNumber, price: tablePrice)
        tablePrices.append(newTablePrice)
        
        // Clear the input fields
        tableNumber = ""
        tablePrice = ""
    }
    
    func removeTablePrice(_ tablePrice: TablePrice) {
        tablePrices.removeAll { $0.id == tablePrice.id }
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
