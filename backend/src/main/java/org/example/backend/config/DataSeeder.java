package org.example.backend.config;

import com.github.javafaker.Faker;
import lombok.RequiredArgsConstructor;
import org.example.backend.model.*;
import org.example.backend.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalTime;
import java.util.*;

@Configuration
@RequiredArgsConstructor
public class DataSeeder {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Bean
    public CommandLineRunner seedDatabase() {
        return _ -> {
            if (userRepository.count() > 0) {
                System.out.println("Database already seeded, skipping...");
                return;
            }

            Faker faker = new Faker(new Locale("en"));

            // Create 20 Patients
            for (int i = 0; i < 5; i++) {
                Patient patient = Patient.builder()
                        .fullName(faker.name().fullName())
                        .email("patient" + i + "@gmail.com")
                        .password(passwordEncoder.encode("password"))
                        .phoneNumber("010" + faker.number().digits(8))
                        .appointments(new ArrayList<>())
                        .medicalRecords(new ArrayList<>())
                        .build();

                userRepository.save(patient);
            }

            // Create 20 Doctors
            City[] cities = City.values();
            DoctorSpeciality[] specialities = DoctorSpeciality.values();
            Day[] days = Day.values();

            for (int i = 0; i < 20; i++) {
                Doctor doctor = Doctor.builder()
                        .fullName(faker.name().fullName())
                        .email("doctor" + i + "@gmail.com")
                        .password(passwordEncoder.encode("password"))
                        .phoneNumber("011" + faker.number().digits(8))
                        .city(cities[faker.number().numberBetween(1, cities.length)])
                        .street(faker.address().streetName())
                        .doctorSpeciality(specialities[faker.number().numberBetween(1, specialities.length)])
                        .info(faker.lorem().sentence(10))
                        .patientNumber(faker.number().numberBetween(5, 50))
                        .startTime(LocalTime.of(9, 0))
                        .endTime(LocalTime.of(17, 0))
                        .consultationFee(faker.number().randomDouble(2, 100, 500))
                        .availableDays(Arrays.asList(days))
                        .appointments(new ArrayList<>())
                        .medicalRecords(new ArrayList<>())
                        .build();

                userRepository.save(doctor);
            }

            System.out.println("Seeded 5 patients and 20 doctors.");
        };
    }
}