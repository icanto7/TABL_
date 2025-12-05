//
//  UserListView.swift
//  TABL
//
//  Created by Ignacio Canto on 12/4/25.
//
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

//TO-DO: Add Image preview

struct UserListView: View {
    @FirestoreQuery(collectionPath: "clubs") private var firestoreClubs: [Club]
    let mockClubs: [Club]?
    @StateObject private var favoritesManager = FavoritesManager()
    @State private var showingFavoritesOnly = false
    
    init(mockClubs: [Club]? = nil) {
        self.mockClubs = mockClubs
    }
    
    private var clubs: [Club] {
        return mockClubs ?? firestoreClubs
    }
    @State private var sheetIsPresented = false
    @State private var clubDetailIsPresented = false
    @State private var locationManager = LocationManager()
    @State private var newClub = Club()
    @State private var searchText = ""
    @Environment(\.dismiss) var dismiss
    
    var filteredClubs: [Club] {
        var clubsToFilter = clubs
        
        // Filter by favorites if showing favorites only
        if showingFavoritesOnly {
            clubsToFilter = favoritesManager.getFavoriteClubs(from: clubsToFilter)
        }
        
        // Then filter by search text
        if searchText.isEmpty {
            return clubsToFilter
        } else {
            return clubsToFilter.filter { club in
                club.name.localizedCaseInsensitiveContains(searchText) ||
                club.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dark background
                Color.black
                    .ignoresSafeArea()
                
                List (filteredClubs) { club in
                    NavigationLink {
                        UserClubDetailView(club: club)
                            .environmentObject(favoritesManager)
                    } label: {
                        ClubRowView(club: club)
                    }
                    .listRowBackground(Color.gray.opacity(0.2))
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Night Clubs")
                .listStyle(.plain)
                .searchable(text: $searchText, prompt: "Search clubs...")
                .toolbarBackground(Color.black, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Sign Out") {
                            do {
                                try Auth.auth().signOut()
                                print("🪵➡️ Log out successful!")
                                dismiss()
                            } catch {
                                print("😡 ERROR: Could not sign out!")
                            }
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .tint(Color.white)
                        .cornerRadius(8)
                        .buttonStyle(.glassProminent)
                        .bold()
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(showingFavoritesOnly ? "All" : "Favorites"){
                            showingFavoritesOnly.toggle()
                        }
                        .foregroundColor(.white)
                        .bold()
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .sheet(isPresented: $sheetIsPresented) {
            PlaceLookupView(locationManager: locationManager, club: $newClub)
                .preferredColorScheme(.dark)
                .onDisappear {
                    if !newClub.name.isEmpty {
                        clubDetailIsPresented.toggle()
                    } else {
                        newClub = Club()
                    }
                }
        }
        .sheet(isPresented: $clubDetailIsPresented) {
            NavigationStack {
                ClubDetailView(club: newClub)
                    .preferredColorScheme(.dark)
            }
            .onDisappear {
                newClub = Club()
            }
        }
    }
}



#Preview {
    UserListView(mockClubs: [Club.preview])
        .environmentObject(FavoritesManager())
}
