//
//  PhotoView.swift
//  TABL
//
//  Created by Ignacio Canto on 12/4/25.
//

import SwiftUI
import PhotosUI

struct PhotoView: View {
    @State var club: Club
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photo = Photo()
    @State private var data = Data()
    @State private var pickerIsPresented = true
    @State private var selectedImage = Image(systemName: "photo")
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            selectedImage
                .resizable()
                .scaledToFit()
            
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button( "Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button( "Save") {
                            Task {
                                await PhotoViewModel.saveImage(club: club, photo: photo, data: data)
                                dismiss()
                            }
                        }
                    }
                }
                .photosPicker(isPresented: $pickerIsPresented, selection: $selectedPhoto)
                .onChange(of: selectedPhoto) {
                    Task {
                        do {
                            if let image = try await selectedPhoto?.loadTransferable(type: Image.self) {
                                selectedImage = image
                            }
                             guard let transferredData = try await selectedPhoto?.loadTransferable(type: Data.self) else {
                                 print("Eror: coul dnot convert data from photo")
                                 return
                            }
                            data = transferredData
                        }catch {
                            print("Eror: Could not create image")
                        }
                    }
                    
                    
                }
        }
        .padding(.bottom)
    }
}

#Preview {
    PhotoView(club: Club())
}
