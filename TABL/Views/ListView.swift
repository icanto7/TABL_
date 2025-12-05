//
//  ListView.swift
//  TABL
//
//  Created by Ignacio Canto on 12/4/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

//TO-DO: Add Image preview

struct ListView: View {
    @FirestoreQuery(collectionPath: "clubs") var clubs: [Club]
    @State private var sheetIsPresented = false
    @State private var clubDetailIsPresented = false
    @State private var locationManager = LocationManager()
    @State private var newClub = Club()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dark background
                Color.black
                    .ignoresSafeArea()
                
                List (clubs) { club in
                    NavigationLink {
                        ClubDetailView(club: club)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(club.name)
                                .font(.title)
                                .foregroundColor(.white)
                            Text(club.description)
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Color.gray.opacity(0.2))
                    .swipeActions {
                        Button("", systemImage: "trash", role: .destructive) {
                            ClubViewModel.deleteClub(club: club)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
                .navigationTitle("Night Clubs")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
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
                        Button("New", systemImage: "plus") {
                            sheetIsPresented.toggle()
                        }
                        .foregroundColor(.white)
                    }
                }
                .toolbarBackground(Color.black, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
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
    ListView()
}
