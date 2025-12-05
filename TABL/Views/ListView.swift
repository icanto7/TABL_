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
    @FirestoreQuery(collectionPath: "places") var clubs: [Club]
    @State private var sheetIsPresented = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            List (clubs) { club in
                                NavigationLink {
                                    ClubDetailView(club: club)
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text(club.name)
                                            .font(.title)
                                        Text(club.description)
                                            .font(.title3)
                                            .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .listStyle(.plain)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Sign Out") { //SIGN-OUT Code here
                            do {
                                try Auth.auth().signOut()
                                print("🪵➡️ Log out successful!")
                                dismiss()
                            } catch {
                                print("😡 ERROR: Could not sign out!")
                            }
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                                        Button("New", systemImage: "plus") {
                                            sheetIsPresented.toggle()
                                    }
                                }
                            }
                            .sheet(isPresented: $sheetIsPresented) {
                                NavigationStack {
                                    ClubDetailView(club: Club())
                                }
                            }
                        }
                    }
                }


#Preview {
    ListView()
}
