# TABL - Nightclub Discovery App

TABL is an iOS application designed for discovering and exploring nightclubs. The app provides users with detailed information about clubs, including photos, descriptions, locations, and reviews to help them find the perfect nightlife experience. [What demo here](https://www.youtube.com/watch?v=Rm0wdfqPO0Q)

## Features - Main Branch

### For Users 
- 🎉 **Club Discovery**: Browse a comprehensive list of nightclubs in your area
- 📍 **Location Integration**: View club locations on an interactive map with MapKit
- 📸 **Photo Gallery**: Browse photos of clubs to get a feel for the atmosphere
- ⭐ **Reviews & Ratings**: Read and write reviews for clubs you've visited
- ❤️ **Favorites**: Save your favorite clubs for easy access
- 🔍 **Search**: Find clubs that are registered with the app

### For Administrators
- ➕ **Club Management**: Add new clubs to the database
- ✏️ **Content Editing**: Update club information, descriptions, and details
- 📊 **Analytics**: Monitor app usage and club popularity

## Technical Stack

- **Platform**: iOS (SwiftUI)
- **Backend**: Firebase Firestore for data storage
- **Authentication**: Firebase Authentication with user/admin roles
- **Location Services**: MapKit for location display and search
- **Architecture**: MVVM pattern with Observable classes
- **Image Storage**: Firebase Storage for photo uploads

## Key Components

### Data Models
- **Club**: Core club entity with name, address, description, coordinates, and website links
- **Photo**: User-uploaded photos with metadata and reviewer information
- **User Management**: Role-based authentication for users and administrators

### Views
- **LoginView**: Authentication interface with user/admin role selection
- **ListView**: Main club browsing interface with search and filter capabilities
- **ClubDetailView**: Comprehensive club information page with photos and a map
- **UserListView**: Personalized view for regular users
- **PlaceLookupView**: Location search and club creation interface

### Core Features
- **Real-time Data**: Live updates using Firestore's real-time capabilities
- **Location Services**: GPS integration for location-based features
- **User Authentication**: Secure login with role-based permissions

## Future Enhancements - Alternative Branch called bidding (still a work in progress)

- [ ] Implement loading screens and animations
- [ ] Interactive table map where users can select tables they want to bid for
- [ ] Enhanced search and filtering capabilities
- [ ] Social features and user profiles
- [ ] Push notifications for new clubs or events
- [ ] Integration with social media platforms
- [ ] Advanced analytics and reporting

