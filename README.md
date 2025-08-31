# CareTrack Backend

A comprehensive healthcare management system backend built with Spring Boot, designed to connect patients with doctors and manage medical records efficiently.

## 🏥 Overview

CareTrack is a robust backend API that facilitates healthcare management by providing:
- Patient and doctor registration/authentication
- Appointment booking and management
- Medical record creation and sharing
- Doctor search functionality
- Secure JWT-based authentication

## 🚀 Features

### Authentication & Authorization
- JWT-based authentication
- Role-based access control (Patient/Doctor)
- Secure password management
- Account deletion functionality

### Patient Management
- Patient registration and profile management
- Doctor search by speciality, city, and availability
- Medical record creation and management
- Record sharing with doctors
- Appointment booking and modification

### Doctor Management
- Doctor registration with speciality and availability
- Profile management
- Access to shared patient records
- Appointment management

### Medical Records
- Create and update medical records
- Share records with specific doctors
- Share all records with a doctor
- Secure access control

### Appointment System
- Book appointments with doctors
- Modify existing appointments
- Cancel appointments
- View appointment history with pagination

## 🛠️ Technology Stack

- **Framework**: Spring Boot 3.3.2
- **Java Version**: Java 22
- **Database**: PostgreSQL
- **Security**: Spring Security with JWT
- **Documentation**: OpenAPI 3 (Swagger)
- **Build Tool**: Maven
- **Additional Libraries**:
  - Lombok for boilerplate code reduction
  - ModelMapper for entity-DTO mapping
  - JavaFaker for test data generation
  - Spring Validation for input validation

## 📋 Prerequisites

- Java 22 or higher
- Maven 3.6+
- PostgreSQL database
- Redis server
- IDE (IntelliJ IDEA, Eclipse, VS Code)

## ⚙️ Installation & Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/OmarMoh44/CareTrack.git
   cd CareTrack/backend
   ```

2. **Configure Environment Variables**
   Create a `.env` file in the root directory with the following variables:
   ```env
   DB_URL=jdbc:postgresql://localhost:5432/caretrack
   DB_USERNAME=your_db_username
   DB_PASSWORD=your_db_password
   JWT_SECRET=your_jwt_secret_key
   JWT_EXPIRE=86400000
   SERVER_PORT=8080
   CONTEXT_PATH=/api
   ```

3. **Set up PostgreSQL Database**
   ```sql
   CREATE DATABASE caretrack;
   ```

4. **Start Redis Server**
   Make sure Redis is running on your local machine or configure the connection string accordingly.

5. **Build and Run the Application**
   ```bash
   # Using Maven Wrapper
   ./mvnw clean install
   ./mvnw spring-boot:run
   
   # Or using Maven directly
   mvn clean install
   mvn spring-boot:run
   ```

## 📚 API Documentation

Once the application is running, you can access the interactive API documentation at:
- **Swagger UI**: `http://localhost:8080/api/swagger-ui/index.html`
- **OpenAPI JSON**: `http://localhost:8080/api/v3/api-docs`

### Key API Endpoints

#### Authentication
- `POST /api/register/patient` - Register as patient
- `POST /api/register/doctor` - Register as doctor
- `POST /api/login` - User login
- `POST /api/forget-password` - Password recovery
- `GET /api/logout` - User logout
- `DELETE /api/delete-account` - Delete user account

#### Appointments
- `GET /api/appointments` - Get user appointments (paginated)
- `POST /api/appointments` - Book new appointment
- `PATCH /api/appointments` - Modify appointment
- `DELETE /api/appointments/{appointmentId}` - Cancel appointment

#### Medical Records
- `POST /api/medical-records` - Create medical record
- `GET /api/medical-records/{recordId}` - Get record by ID
- `PUT /api/medical-records/{recordId}` - Update medical record
- `GET /api/medical-records/patient/me` - Get patient's records
- `POST /api/medical-records/share` - Share record with doctor
- `POST /api/medical-records/share-all` - Share all records with doctor

#### Patient Operations
- `GET /api/patient` - Get patient profile
- `PATCH /api/patient` - Update patient profile
- `POST /api/patient/doctors-search` - Search doctors
- `GET /api/patient/doctors/{doctorId}` - Get doctor by ID

#### Doctor Operations
- `GET /api/doctor` - Get doctor profile
- `PATCH /api/doctor` - Update doctor profile

## 🔧 Configuration

### Database Configuration
The application uses PostgreSQL with JPA/Hibernate for data persistence. Database configuration is handled through environment variables.

### Redis Configuration
Redis is used for caching to improve application performance. Make sure Redis server is running and accessible.

### Security Configuration
- JWT tokens are used for authentication
- CORS is configured to allow cross-origin requests
- Security filters are applied to protect endpoints

## 📁 Project Structure

```
src/
├── main/
│   ├── java/org/example/backend/
│   │   ├── config/          # Configuration classes
│   │   ├── controller/      # REST controllers
│   │   ├── dto/            # Data Transfer Objects
│   │   ├── exception/      # Exception handlers
│   │   ├── jwt/            # JWT utilities
│   │   ├── model/          # Entity classes
│   │   ├── repository/     # Data repositories
│   │   ├── service/        # Business logic
│   │   └── validator/      # Custom validators
│   └── resources/
│       └── application.properties
└── test/                   # Test classes
```

## 🔒 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Encryption**: Passwords are encrypted using BCrypt
- **Role-based Access**: Different access levels for patients and doctors
- **CORS Support**: Configured for cross-origin requests
- **Input Validation**: Comprehensive validation for all inputs
- **Error Handling**: Global exception handling for security

## 📝 Data Models

### Core Entities
- **User**: Base user entity
- **Patient**: Extends User with patient-specific fields
- **Doctor**: Extends User with medical speciality and availability
- **Appointment**: Manages patient-doctor appointments
- **MedicalRecord**: Stores patient medical information

### Enumerations
- **Role**: USER, DOCTOR
- **DoctorSpeciality**: Various medical specialities
- **City**: Supported cities
- **Day**: Days of the week for doctor availability

## 🌐 Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DB_URL` | PostgreSQL database URL | Required |
| `DB_USERNAME` | Database username | Required |
| `DB_PASSWORD` | Database password | Required |
| `JWT_SECRET` | JWT signing secret | Required |
| `JWT_EXPIRE` | Token expiration time (ms) | Required |
| `SERVER_PORT` | Application port | 8080 |
| `CONTEXT_PATH` | API context path | /api |

## 👥 Author

**Omar Mohammed** - [GitHub](https://github.com/OmarMoh44)

---

**Note**: Make sure to configure all environment variables before running the application. The application includes comprehensive API documentation accessible through Swagger UI once running.
