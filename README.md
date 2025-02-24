# Location Tracker App
A modern Flutter application that tracks and stores user location data with a beautiful, responsive UI for both mobile and tablet devices.

## Getting Started

## 📌 Features

- **Real-time Location Tracking:** Captures user location every 30 seconds  
- **Location History:** Stores and displays location data with timestamps  
- **Responsive Design:** Optimized layouts for both mobile and tablet devices  
- **Permission Management:** Handles location and notification permissions  
- **Data Persistence:** Saves location data across app sessions  
- **Interactive UI:** Visual indicators for tracking status and animated feedback  


##  📸 Screenshots

<img src="https://github.com/user-attachments/assets/1474c11a-cba8-4185-ace3-e7d6caebfd4a" width="300"/>
<img src="https://github.com/user-attachments/assets/11673f70-7691-4cc1-baf5-9eca742afe1f" width="300"/>

##  🏗 Tech Stack

- **Flutter**: UI framework for cross-platform development  
- **Dart**: Programming language  
- **Geolocator**: For accessing device location  
- **SharedPreferences**: For persistent storage of location data  
- **Permission Handler**: To manage app permissions  
- **Font Awesome Flutter**: For enhanced UI icons  
- **Fluttertoast**: For user notifications  
- **Intl**: For date formatting  


## 📂 Project Structure

```
lib/
├── main.dart
├── screens/
│   ├── LocationTrackerScreen.dart
|   |__ LocationService.dart 
│   └── LocationListView.dart      
└── ... (other app files)
```

##   Key Components

###  📍 **LocationTrackerScreen**  
The main interface that provides:  
- **Permission request buttons** for location and notifications  
- **Start/stop tracking** functionality  
- **Visual tracking status indicator**  
- **Location history display**  

###  📋 **LocationListView**  
A responsive component that displays location history:  
- **Renders as a list** on mobile devices  
- **Renders as a 2-column grid** on tablet devices  
- **Shows timestamps and coordinates** with visual indicators  
- **Displays a helpful empty state** when no data exists  


## 🚀 Installation  

### 1️⃣ Clone the repository  
```sh
git clone https://github.com/dinesh-dot-com/location_tracker.git
cd location_tracker
```

### 2️⃣ Install dependencies
```sh
flutter pub get
```
### 3️⃣ Run the app
```sh
flutter run
```

## ⚙️ Setup Requirements  

Ensure your `pubspec.yaml` includes the following dependencies:  

```yaml
dependencies:
  flutter:
    sdk: flutter
  geolocator: ^9.0.0
  shared_preferences: ^2.2.0
  permission_handler: ^10.4.0
  font_awesome_flutter: ^10.5.0
  fluttertoast: ^8.2.2
  intl: ^0.18.1
```


## 📱 Platform Configuration  

### 🟢 Android  
Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:  

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

 ### 🍏 iOS
 Add the following permissions to your `ios/Runner/Info.plist`:  
 
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when open.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to location when in the background.</string>
```

## 🚀 Usage

- **Launch the app**  
- **Grant** location and notification permissions  
- **Press** "Start Tracking" to begin location updates  
- **View** your location history in the list/grid below  
- **Press** "Stop Tracking" to end tracking and clear history  







