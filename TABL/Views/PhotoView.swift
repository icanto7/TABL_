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
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [Image] = []
    @State private var photosData: [Data] = []
    @State private var pickerIsPresented = true
    @State private var isUploading = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                if selectedImages.isEmpty {
                    VStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No photos selected")
                            .foregroundColor(.gray)
                            .font(.title2)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                ZStack {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 200)
                                        .clipped()
                                        .cornerRadius(12)
                                    
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Button {
                                                removeImage(at: index)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .background(Color.black.opacity(0.6))
                                                    .clipShape(Circle())
                                                    .font(.title2)
                                            }
                                            .padding(.trailing, 8)
                                            .padding(.top, 8)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                if isUploading {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                    
                    VStack {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                        Text("Uploading photos...")
                            .foregroundColor(.white)
                            .padding(.top)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveAllPhotos()
                        }
                    }
                    .foregroundColor(.white)
                    .disabled(selectedImages.isEmpty || isUploading)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .photosPicker(
                isPresented: $pickerIsPresented,
                selection: $selectedPhotos,
                maxSelectionCount: 10, // Allow up to 10 photos
                matching: .images
            )
            .onChange(of: selectedPhotos) {
                Task {
                    await loadSelectedPhotos()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    func loadSelectedPhotos() async {
        selectedImages.removeAll()
        photosData.removeAll()
        
        for photoItem in selectedPhotos {
            do {
                if let image = try await photoItem.loadTransferable(type: Image.self) {
                    selectedImages.append(image)
                }
                
                if let data = try await photoItem.loadTransferable(type: Data.self) {
                    photosData.append(data)
                }
            } catch {
                print("Error loading photo: \(error)")
            }
        }
    }
    
    func removeImage(at index: Int) {
        guard index < selectedImages.count && index < photosData.count else { return }
        selectedImages.remove(at: index)
        photosData.remove(at: index)
        selectedPhotos.remove(at: index)
    }
    
    func saveAllPhotos() async {
        guard !photosData.isEmpty else { return }
        
        isUploading = true
        
        for data in photosData {
            let photo = Photo()
            await PhotoViewModel.saveImage(club: club, photo: photo, data: data)
        }
        
        isUploading = false
        dismiss()
    }
}


#Preview {
    PhotoView(club: Club())
}
