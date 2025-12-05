//
//  DetailView.swift
//  TABL
//
//  Created by Ignacio Canto on 12/4/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

//TO-DO: Add image upload section

struct ClubDetailView: View {
    @State var club: Club
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Club:")
                .bold()
            TextField("club", text: $club.name)
                .textFieldStyle(.roundedBorder)
            
            Text("Description:")
                .bold()
            TextField("description", text: $club.description)
                .textFieldStyle(.roundedBorder)
            
            Spacer()
        }
        .padding(.horizontal)
        .font(.title)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    dismiss()
                }
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
            }
        }
    }
}
        
        
#Preview {
    ClubDetailView(club: Club(name: "Bijou", image: "", description: "nightclub and lounge"))
}
