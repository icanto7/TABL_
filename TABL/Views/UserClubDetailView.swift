//
//  UserClubDetailView.swift
//  TABL
//
//  Created by Ignacio Canto on 12/4/25.
//

import SwiftUI
import Combine
import FirebaseAuth
import Firebase
import FirebaseFirestore
import MapKit

//To-do add location

struct UserClubDetailView: View {
    @FirestoreQuery(collectionPath: "clubs") var fsPhotos: [Photo]
    @FirestoreQuery(collectionPath: "clubs") var reviews: [Review]
    @State var club: Club
    @Environment(\.dismiss) private var dismiss
    @State private var showReviewViewSheet = false
    @State private var showPhotoGallery = false
    @State private var showCalendar = false
    @State private var showSeatingMap = false
    @State private var reservedTableNumber: Int? = nil
    @State private var reservedDate: Date? = nil
    @State private var selectedDate = Date()
    @State private var photo: Photo? // Holds the first photo from the subcollection
    @EnvironmentObject private var favoritesManager: FavoritesManager
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
    
    private var averageRating: String {
        guard !reviews.isEmpty else { return "N/A" }
        let total = reviews.reduce(0) { $0 + $1.rating }
        let average = Double(total) / Double(reviews.count)
        return String(format: "%.1f", average)
    }
    

    var body: some View {
        ZStack {
            // Dark background
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        VStack (alignment: .leading) {
                            Text(club.name)
                                .bold()
                                .foregroundColor(.white)
                            Text(club.description)
                                .font(.callout)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: {
                            guard let clubId = club.id else { return }
                            favoritesManager.toggleFavorite(clubId: clubId)
                        }) {
                            Image(systemName: favoritesManager.isFavorite(club.id ?? "") ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(favoritesManager.isFavorite(club.id ?? "") ? .red : .white)
                        }
                    }
                    
                    // Photo Gallery Preview
                    if !photos.isEmpty {
                        Button(action: {
                            showPhotoGallery = true
                        }) {
                            ZStack {
                                let url = URL(string: photos[0].imageURLString)
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity, maxHeight: 300)
                                        .clipped()
                                        .cornerRadius(8)
                                } placeholder: {
                                    ProgressView()
                                        .tint(.white)
                                        .frame(height: 300)
                                }
                                
                                // Photo count badge
                                VStack {
                                    HStack {
                                        Spacer()
                                        Text("\(photos.count)")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.white.opacity(0.9))
                                            .cornerRadius(20)
                                            .padding(.trailing, 12)
                                            .padding(.top, 12)
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Table Plan Chart Image
                    VStack(spacing: 8) {
                        HStack {
                            Text("Table Map")
                                .font(.headline)
                                .foregroundColor(.white)
                                .bold()
                            Spacer()
                        }
                        
                        Image("Sound-Table-Chart-24")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 300)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    if !club.link.isEmpty {
                        VStack(spacing: 8) {
                            Button(action: {
                                showCalendar = true
                            }) {
                                HStack {
                                    Text(reservedTableNumber != nil ? "Edit Table Selection" : "Reserve A Table Now!")
                                }
                                .foregroundColor(.black)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.white)
                                .cornerRadius(8)
                            }
                            
                            // Show reserved table info if table is booked
                            if let tableNumber = reservedTableNumber, let date = reservedDate {
                                VStack(spacing: 4) {
                                    Text("Reserved: Table \(tableNumber)")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                        .bold()
                                    Text("Date: \(date, format: .dateTime.weekday().month().day().year())")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                    
                    // Reviews Section (moved above map)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Avg. Rating:")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            Text(averageRating)
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button("Rate it") {
                                showReviewViewSheet.toggle()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.white)
                            .foregroundStyle(.black)
                        }
                        
                        LazyVStack(spacing: 8) {
                            ForEach(reviews) { review in
                                NavigationLink {
                                    ReviewView(club: club, review: review)
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(review.title)
                                            .foregroundColor(.white)
                                            .font(.headline)
                                        
                                        HStack(spacing: 2) {
                                            ForEach(1...5, id: \.self) { star in
                                                Image(systemName: star <= review.rating ? "star.fill" : "star")
                                                    .foregroundColor(star <= review.rating ? .white : .gray)
                                                    .font(.caption)
                                            }
                                            
                                            Text(review.body)
                                                .foregroundColor(.white.opacity(0.7))
                                                .font(.caption)
                                                .lineLimit(1)
                                                .truncationMode(.tail)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
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
                }
                .padding(.horizontal)
            }
            .padding(.horizontal)
        }
        .onAppear {
                $reviews.path = "clubs/\(club.id ?? "")/reviews"
        }
        .task {
            guard let id = club.id else {
                return
            }
            $fsPhotos.path = "clubs/\(id)/photos"
        }
        .font(.title)
        .navigationBarBackButtonHidden()
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
        .sheet(isPresented: $showReviewViewSheet) {
            NavigationStack {
                ReviewView(club: club, review: Review())
                    .preferredColorScheme(.dark)
            }
        }
        .sheet(isPresented: $showPhotoGallery) {
            NavigationStack {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            // Club photos from Firestore
                            ForEach(photos) { photo in
                                let url = URL(string: photo.imageURLString)
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity, maxHeight: 400)
                                        .clipped()
                                        .cornerRadius(12)
                                } placeholder: {
                                    ProgressView()
                                        .tint(.white)
                                        .frame(height: 400)
                                }
                            }
                        }
                        .padding()
                    }
                }
                .navigationTitle("Photos")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showPhotoGallery = false
                        }
                        .foregroundColor(.white)
                    }
                }
                .toolbarBackground(Color.black, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
            }
            .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showCalendar) {
            NavigationStack {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        Text("Select Reservation Date")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        DatePicker(
                            "Reservation Date",
                            selection: $selectedDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .colorScheme(.dark)
                        .padding()
                        
                        Button("Continue to Table Selection") {
                            showCalendar = false
                            showSeatingMap = true
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .bold()
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
                .navigationTitle("Select Date")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showCalendar = false
                        }
                        .foregroundColor(.white)
                    }
                }
                .toolbarBackground(Color.black, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
            }
            .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showSeatingMap) {
            NavigationStack {
                VenueSeatingMapView { tableNumber in
                    // Handle table purchase
                    reservedTableNumber = tableNumber
                    reservedDate = selectedDate
                    showSeatingMap = false
                }
                .navigationTitle("\(club.name) - Seating")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Back") {
                            showSeatingMap = false
                            showCalendar = true
                        }
                        .foregroundColor(.white)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showSeatingMap = false
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
    UserClubDetailView(club: Club.preview)
        .environmentObject(FavoritesManager())
}

