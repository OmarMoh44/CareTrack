package org.example.backend.service;

import jakarta.persistence.EntityNotFoundException;
import org.example.backend.dto.AppointmentResponse;
import org.example.backend.dto.BookAppointmentRequest;
import org.example.backend.dto.ModifyAppointmentRequest;
import org.example.backend.exception.ErrorMessage;
import org.example.backend.model.*;
import org.example.backend.repository.AppointmentRepository;
import org.example.backend.repository.DoctorRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import lombok.RequiredArgsConstructor;

import java.time.LocalDate;
import java.time.format.TextStyle;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@Service
@RequiredArgsConstructor
public class AppointmentService {
    private final AppointmentRepository appointmentRepository;
    private final DoctorRepository doctorRepository;

    public List<AppointmentResponse> getAppointments(User authenticatedUser) {
        List<Appointment> appointments = new ArrayList<>();
        if (authenticatedUser.getRole() == Role.PATIENT) {
            Patient patient = (Patient) authenticatedUser;
            appointments = appointmentRepository.findByPatientIdAndDateGreaterThanEqual(patient.getId(), LocalDate.now());
        } else if (authenticatedUser.getRole() == Role.DOCTOR) {
            Doctor doctor = (Doctor) authenticatedUser;
            appointments = appointmentRepository.findByDoctorIdAndDateGreaterThanEqual(doctor.getId(), LocalDate.now());
        }
        return appointments.stream()
                .map(appointment -> buildAppointmentResponse
                        (appointment, appointment.getDoctor(), appointment.getPatient()))
                .toList();
    }


    @Transactional
    public AppointmentResponse bookAppointment(BookAppointmentRequest request, Patient patient) {
        Doctor doctor = doctorRepository.findById(request.getDoctorId())
                .orElseThrow(() -> new EntityNotFoundException(ErrorMessage.USER_NOT_FOUND.getMessage()));
        verifyDoctorAvailable(doctor, request.getDate());
        if (appointmentRepository.findByDoctorIdAndPatientIdAndDate(request.getDoctorId(), patient.getId(), request.getDate())
                .isPresent()) {
            throw new EntityNotFoundException(ErrorMessage.APPOINTMENT_EXISTS.getMessage());
        }
        verifyEnoughPatientNumber(request.getDoctorId(), request.getDate(), doctor.getPatientNumber());
        Appointment appointment = new Appointment();
        appointment.setDoctor(doctor);
        appointment.setPatient(patient);
        appointment.setDate(request.getDate());
        Appointment savedAppointment = appointmentRepository.save(appointment);
        return buildAppointmentResponse(savedAppointment, doctor, patient);
    }

    @Transactional
    public AppointmentResponse updateAppointment(ModifyAppointmentRequest request, User authenticatedUser) {
        Appointment appointment = appointmentRepository.findById(request.getId())
                .orElseThrow(() -> new EntityNotFoundException(ErrorMessage.APPOINTMENT_NOT_FOUND.getMessage()));
        verifyAppointmentOwnership(appointment, authenticatedUser);
        verifyDoctorAvailable(appointment.getDoctor(), request.getDate());
        verifyEnoughPatientNumber(appointment.getDoctor().getId(), request.getDate(), appointment.getDoctor().getPatientNumber());
        appointment.setDate(request.getDate());
        appointment = appointmentRepository.save(appointment);
        return buildAppointmentResponse(appointment, appointment.getDoctor(), appointment.getPatient());
    }

    @Transactional
    public String cancelAppointment(Long appointmentId, User authenticatedUser) {
        Appointment appointment = appointmentRepository.findById(appointmentId)
                .orElseThrow(() -> new EntityNotFoundException(ErrorMessage.APPOINTMENT_NOT_FOUND.getMessage()));
        verifyAppointmentOwnership(appointment, authenticatedUser);
        appointmentRepository.delete(appointment);
        return "Appointment with ID " + appointmentId + " has been cancelled successfully.";
    }

    private void verifyAppointmentOwnership(Appointment appointment, User authenticatedUser) {
        if (authenticatedUser.getRole() == Role.PATIENT) {
            if (!appointment.getPatient().getId().equals(authenticatedUser.getId())) {
                throw new EntityNotFoundException(ErrorMessage.APPOINTMENT_NOT_FOUND.getMessage());
            }
        } else if (authenticatedUser.getRole() == Role.DOCTOR) {
            if (!appointment.getDoctor().getId().equals(authenticatedUser.getId())) {
                throw new EntityNotFoundException(ErrorMessage.APPOINTMENT_NOT_FOUND.getMessage());
            }
        }
    }

    private void verifyDoctorAvailable(Doctor doctor, LocalDate date) {
        Day day = Day.valueOf(date.getDayOfWeek().getDisplayName(TextStyle.FULL, Locale.ENGLISH).toUpperCase());
        if (!doctor.getAvailableDays().contains(day)) {
            throw new EntityNotFoundException(ErrorMessage.DOCTOR_NOT_AVAILABLE.getMessage());
        }
    }

    private void verifyEnoughPatientNumber(Long doctorId, LocalDate date, Integer patientNumber) {
        Integer count = appointmentRepository.countByDoctorIdAndDate(doctorId, date);
        if (count + 1 > patientNumber) {
            throw new EntityNotFoundException(ErrorMessage.DOCTOR_NOT_AVAILABLE.getMessage());
        }
    }

    private AppointmentResponse buildAppointmentResponse(Appointment appointment, Doctor doctor, Patient patient) {
        return AppointmentResponse.builder()
                .id(appointment.getId())
                .date(appointment.getDate())
                .patientId(patient.getId())
                .patientName(patient.getFullName())
                .doctorId(doctor.getId())
                .doctorName(doctor.getFullName())
                .doctorSpecialization(doctor.getDoctorSpeciality().name())
                .build();
    }


}
