//
//  LaunchScreenView.swift
//  TABL
//
//  Created by Assistant on 12/5/25.
//

import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            // Black background that takes up entire screen
            Color.black
                .ignoresSafeArea(.all) // This ensures it covers the entire screen
            
            VStack(spacing: 20) {
                // Replace with your logo image when you add it
                // Uncomment and use this when you add your logo:
                // Image("LaunchLogo")
                //     .resizable()
                //     .scaledToFit()
                //     .frame(width: 200, height: 200)
                
                // Temporary text logo - remove this when you add your image
                Text("TABL")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Optional: Add a loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LaunchScreenView()
}