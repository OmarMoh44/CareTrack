# CareTrack - Healthcare Management Flutter App

A comprehensive healthcare management mobile application built with Flutter, connecting patients and doctors for seamless medical care coordination.

## 🏥 Overview

CareTrack is a mobile healthcare platform that facilitates communication and appointment management between patients and doctors. The app provides separate interfaces for patients and healthcare providers, enabling efficient medical record management, appointment scheduling, and doctor-patient interactions.

## ✨ Features

### For Patients
- 👤 User registration and secure authentication
- 🔍 Search and browse available doctors by specialty
- 📅 Book appointments with preferred doctors
- 📋 View and manage medical records
- 👨‍⚕️ View doctor profiles and availability
- 🔔 Appointment notifications and reminders
- 📱 User-friendly profile management

### For Doctors
- 👨‍⚕️ Doctor registration and professional profile setup
- 📊 Manage patient appointments and schedules
- 📝 Add and update medical records for patients
- 👥 View patient information and history
- ⏰ Set availability hours and consultation fees
- 📈 Track patient numbers and appointments

## 🏗️ Architecture

The app follows a clean architecture pattern with:
- **State Management**: BLoC (Business Logic Component) pattern
- **HTTP Client**: HTTP package for API communication
- **Local Storage**: SharedPreferences for user session management
- **Navigation**: Flutter's built-in navigation system
- **UI**: Material Design components with custom styling

## 📱 Screenshots & UI Components

### Key Screens
- **Splash Screen**: Branded loading screen with CareTrack logo
- **Welcome Screen**: Role selection (Patient/Doctor)
- **Authentication**: Login and signup for both user types
- **Home Dashboards**: Separate interfaces for patients and doctors
- **Doctor Listing**: Browse available doctors with specialties
- **Appointment Booking**: Date/time selection interface
- **Medical Records**: View and manage patient health records
- **Profile Management**: Personal information and settings

## 🛠️ Technology Stack

### Frontend (Flutter)
- **Flutter SDK**: ^3.7.2
- **State Management**: flutter_bloc ^9.1.1, bloc ^9.0.0
- **HTTP Client**: http ^1.5.0
- **Local Storage**: shared_preferences ^2.5.3
- **Icons**: cupertino_icons ^1.0.8

### Backend Integration
- RESTful API integration with JWT authentication
- Comprehensive API documentation via Swagger/OpenAPI 3.0
- Endpoints for user management, appointments, and medical records

## 📂 Project Structure

```
lib/
├── main.dart                 # App entry point and splash screen
├── welcome_screen.dart       # Role selection screen
├── User_login.dart          # Patient login screen
├── user_signup.dart         # Patient registration
├── doctor_login.dart        # Doctor login screen
├── doctor_signup.dart       # Doctor registration
├── home_user.dart           # Patient dashboard
├── home_dr.dart             # Doctor dashboard
├── our_doctors.dart         # Doctor listing screen
├── dr_details.dart          # Doctor profile details
├── appo_datetime.dart       # Appointment scheduling
├── user_appo.dart           # Patient appointments
├── dr_appo.dart             # Doctor appointments
├── medical_record.dart      # Medical records view
├── add_medical_record.dart  # Add medical records
├── profile.dart             # User profile management
├── personal_info.dart       # Personal information
├── search.dart              # Search functionality
└── forget_password.dart     # Password recovery

assets/
├── images/
    ├── background.png       # App background
    ├── ntg.png             # Logo/branding
    ├── heart.png           # Health icons
    ├── heart-2.png         # Health icons
    └── doctor.png          # Doctor illustration
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.7.2)
- Dart SDK
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/OmarMoh44/CareTrack.git
   cd CareTrack/frontend/caretrack
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Backend Setup
Ensure the CareTrack backend API is running on `http://localhost:8080/api` or update the API endpoints in the Flutter code accordingly.

## 🔧 Configuration

### API Integration
The app connects to a backend API for:
- User authentication (JWT-based)
- Doctor and patient management
- Appointment scheduling
- Medical records management

### Environment Setup
Update API endpoints in the respective Dart files to match your backend configuration.

## 👥 User Roles

### Patient Flow
1. Register/Login as Patient
2. Browse available doctors
3. View doctor profiles and specialties
4. Book appointments
5. Manage medical records
6. View appointment history

### Doctor Flow
1. Register/Login as Doctor
2. Set up professional profile
3. Manage availability and consultation fees
4. View and manage patient appointments
5. Add/update patient medical records
6. Track patient interactions

## 🔐 Security Features
- JWT-based authentication
- Secure API communication
- Local session management
- Role-based access control

## 🎨 Design System
- Material Design components
- Custom color scheme (Primary: #0080FF, Secondary: #223A6A)
- Responsive design for various screen sizes
- Consistent typography and spacing

## 📱 Platform Support
- ✅ Android
- ✅ iOS
- ✅ Web (Flutter Web)
- ✅ Desktop (Windows, macOS, Linux)

---

**CareTrack** - Connecting Healthcare, Caring for You 💙
