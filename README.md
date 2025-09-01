# CareTrack - Healthcare Management System

CareTrack is a comprehensive healthcare management platform consisting of a Spring Boot backend REST API and a Flutter mobile application. The system enables patients to find doctors, book appointments, and manage medical records, while providing doctors with tools to manage their appointments and patient records.

## 🏥 Features

### For Patients
- **User Authentication**: Secure registration and login
- **Doctor Search**: Find doctors by specialty, location, and availability
- **Appointment Booking**: Schedule appointments with preferred doctors
- **Medical Records**: View and manage personal medical history
- **Profile Management**: Update personal information and preferences
- **Password Recovery**: Secure password reset functionality

### For Doctors
- **Doctor Registration**: Professional signup with specialization details
- **Appointment Management**: View and manage patient appointments
- **Medical Records**: Add and update patient medical records
- **Profile Management**: Maintain professional profile and availability
- **Patient Communication**: Secure interaction with patients

### System Features
- **JWT Authentication**: Secure token-based authentication
- **Role-based Access Control**: Separate permissions for patients and doctors
- **Real-time Data**: Synchronized information across platforms
- **Data Validation**: Comprehensive input validation and error handling
- **API Documentation**: Complete Swagger/OpenAPI documentation

## 🏗️ System Architecture

```
┌─────────────────┐    HTTP/REST API    ┌─────────────────┐
│   Flutter App   │ ◄─────────────────► │  Spring Boot    │
│   (Frontend)    │                     │   (Backend)     │
│                 │                     │                 │
│ • User Login    │                     │ • JWT Auth      │
│ • Doctor Search │                     │ • User Management│
│ • Appointments  │                     │ • Appointments  │
│ • Medical Records│                     │ • Medical Records│
│ • Profile Mgmt  │                     │ • Data Validation│
└─────────────────┘                     └─────────────────┘
                                                │
                                                ▼
                                        ┌─────────────────┐
                                        │   PostgreSQL    │
                                        │   Database      │
                                        │                 │
                                        │ • Users         │
                                        │ • Doctors       │
                                        │ • Appointments  │
                                        │ • Medical Records│
                                        └─────────────────┘
```

## 🛠️ Technology Stack

### Backend (Spring Boot)
- **Framework**: Spring Boot 3.3.2
- **Language**: Java 22
- **Database**: PostgreSQL
- **Authentication**: JWT (JSON Web Tokens)
- **Documentation**: Swagger/OpenAPI 3
- **Build Tool**: Maven
- **Key Dependencies**:
  - Spring Data JPA
  - Spring Security
  - Spring Web
  - Spring Validation
  - JWT (io.jsonwebtoken)
  - ModelMapper
  - Lombok
  - JavaFaker (for data seeding)

### Frontend (Flutter)
- **Framework**: Flutter 3.7.2+
- **Language**: Dart
- **State Management**: Flutter BLoC
- **HTTP Client**: http package
- **Local Storage**: shared_preferences
- **UI Components**: Material Design

### Database Schema
- **Users Table**: Base user information
- **Patients Table**: Patient-specific data (extends Users)
- **Doctors Table**: Doctor profiles with specializations
- **Appointments Table**: Appointment scheduling
- **Medical Records Table**: Patient medical history
- **Supporting Tables**: Cities, Specialties, Days, etc.

## 📁 Project Structure

### Backend Structure
```
backend/
├── src/main/java/org/example/backend/
│   ├── BackendApplication.java          # Main application class
│   ├── config/                          # Configuration classes
│   │   ├── CorsConfig.java             # CORS configuration
│   │   ├── SecurityConfiguration.java   # Security settings
│   │   ├── SwaggerConfig.java          # API documentation
│   │   └── DataSeeder.java             # Initial data setup
│   ├── controller/                      # REST endpoints
│   │   ├── AuthController.java         # Authentication endpoints
│   │   ├── PatientController.java      # Patient operations
│   │   ├── DoctorController.java       # Doctor operations
│   │   ├── AppointmentController.java  # Appointment management
│   │   └── MedicalRecordController.java # Medical records
│   ├── service/                        # Business logic
│   ├── model/                          # JPA entities
│   ├── repository/                     # Data access layer
│   ├── dto/                           # Data transfer objects
│   ├── jwt/                           # JWT utilities
│   └── exception/                     # Error handling
└── src/main/resources/
    └── application.properties         # Application configuration
```

### Frontend Structure
```
flutter_app/lib/
├── main.dart                    # App entry point with splash screen
├── welcome_screen.dart          # Landing page
├── User_login.dart             # Patient login screen
├── user_signup.dart            # Patient registration
├── doctor_login.dart           # Doctor login screen
├── doctor_signup.dart          # Doctor registration
├── home_user.dart              # Patient dashboard
├── home_dr.dart                # Doctor dashboard
├── search.dart                 # Doctor search functionality
├── our_doctors.dart            # Doctor listings
├── dr_details.dart             # Doctor profile details
├── appo_datetime.dart          # Appointment scheduling
├── user_appo.dart              # Patient appointments
├── dr_appo.dart                # Doctor appointments
├── medical_record.dart         # Medical records view
├── add_medical_record.dart     # Add medical records
├── profile.dart                # User profile
├── personal_info.dart          # Personal information
└── forget_password.dart        # Password recovery
```

## 🚀 Getting Started

### Prerequisites
- **Backend**:
  - Java 22 or higher
  - Maven 3.6+
  - PostgreSQL 12+

- **Frontend**:
  - Flutter SDK 3.7.2+
  - Dart 3.0+
  - Android Studio / VS Code
  - Android/iOS development environment

### Backend Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd CareTrack/backend
   ```

2. **Configure database**
   Create a PostgreSQL database and update environment variables:
   ```bash
   # Set environment variables
   export DB_URL=jdbc:postgresql://localhost:5432/caretrack
   export DB_USERNAME=your_username
   export DB_PASSWORD=your_password
   export JWT_SECRET=your_jwt_secret_key
   export JWT_EXPIRE=86400000
   ```

3. **Build and run**
   ```bash
   mvn clean install
   mvn spring-boot:run
   ```

4. **Access API Documentation**
   - Swagger UI: http://localhost:8080/api/swagger-ui.html
   - OpenAPI JSON: http://localhost:8080/api/v3/api-docs

### Frontend Setup

1. **Navigate to Flutter directory**
   ```bash
   cd CareTrack/flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   Update the API base URL in the Flutter code if needed (currently set to `http://10.0.2.2:8080/api` for Android emulator)

4. **Run the application**
   ```bash
   flutter run
   ```

## 🔐 API Endpoints

### Authentication
- `POST /api/login` - User login
- `POST /api/register/patient` - Patient registration
- `POST /api/register/doctor` - Doctor registration
- `POST /api/forget-password` - Password recovery
- `GET /api/logout` - User logout
- `DELETE /api/delete-account` - Delete account

### Appointments
- `GET /api/appointments` - Get user appointments
- `POST /api/appointments/book` - Book new appointment
- `PUT /api/appointments/{id}` - Modify appointment
- `DELETE /api/appointments/{id}` - Cancel appointment

### Doctors
- `GET /api/doctors` - Search doctors
- `GET /api/doctors/{id}` - Get doctor details
- `GET /api/doctors/specialities` - Get specialties

### Medical Records
- `GET /api/medical-records` - Get patient records
- `POST /api/medical-records` - Add medical record
- `GET /api/medical-records/{id}` - Get specific record

### Patients
- `GET /api/patients/profile` - Get patient profile
- `PUT /api/patients/profile` - Update patient profile

## 🔒 Security Features

- **JWT Authentication**: Stateless authentication with secure tokens
- **Password Encryption**: BCrypt hashing for password storage
- **Role-based Authorization**: Separate permissions for patients and doctors
- **CORS Configuration**: Proper cross-origin resource sharing setup
- **Input Validation**: Comprehensive validation on all endpoints
- **Secure Cookies**: HTTP-only cookies for token storage

## 📱 Mobile App Features

### User Experience
- **Responsive Design**: Adapts to different screen sizes
- **Material Design**: Modern Android design principles
- **Smooth Navigation**: Intuitive app flow
- **Loading States**: User feedback during operations
- **Error Handling**: Proper error messages and validation

### Data Management
- **Local Storage**: Token persistence with SharedPreferences
- **HTTP Client**: Efficient API communication
- **State Management**: Clean architecture with proper state handling
- **Form Validation**: Real-time input validation

## 👥 Team

- **Backend Development**: Spring Boot REST API
- **Frontend Development**: Flutter Mobile Application
- **Database Design**: PostgreSQL schema design
- **API Documentation**: Swagger/OpenAPI implementation

---

**CareTrack** - Making healthcare accessible and manageable for everyone. 🏥💙