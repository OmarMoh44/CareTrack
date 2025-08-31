package org.example.backend.service;

import jakarta.persistence.EntityNotFoundException;
import org.example.backend.dto.AppointmentResponse;
import org.example.backend.dto.BookAppointmentRequest;
import org.example.backend.dto.ModifyAppointmentRequest;
import org.example.backend.exception.ErrorMessage;
import org.example.backend.model.*;
import org.example.backend.repository.AppointmentRepository;
import org.example.backend.repository.DoctorRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import lombok.RequiredArgsConstructor;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AppointmentService {
    private final AppointmentRepository appointmentRepository;
    private final DoctorRepository doctorRepository;

    public List<AppointmentResponse> getAppointments(User authenticatedUser, int page, int size) {
        List<Appointment> appointments = new ArrayList<>();
        Pageable pageable = PageRequest.of(page, size, Sort.by("date").ascending());
        if (authenticatedUser.getRole() == Role.PATIENT) {
            Patient patient = (Patient) authenticatedUser;
            appointments = appointmentRepository.findByPatientIdAndDateGreaterThanEqual(patient.getId(),
                    LocalDate.now(), pageable).getContent();
        } else if (authenticatedUser.getRole() == Role.DOCTOR) {
            Doctor doctor = (Doctor) authenticatedUser;
            appointments = appointmentRepository.findByDoctorIdAndDateGreaterThanEqual(doctor.getId(), LocalDate.now(),
                    pageable).getContent();
        }
        return appointments.stream()
                .map(appointment -> buildAppointmentResponse(appointment, appointment.getDoctor(),
                        appointment.getPatient()))
                .toList();
    }

    @Transactional
    public AppointmentResponse bookAppointment(BookAppointmentRequest request, Patient patient) {
        Doctor doctor = doctorRepository.findById(request.getDoctorId())
                .orElseThrow(() -> new EntityNotFoundException(ErrorMessage.USER_NOT_FOUND.getMessage()));
        verifyAppointmentNotPast(request.getDate());
        if (appointmentRepository
                .findByDoctorIdAndPatientIdAndDate(request.getDoctorId(), patient.getId(), request.getDate())
                .isPresent()) {
            throw new EntityNotFoundException(ErrorMessage.APPOINTMENT_EXISTS.getMessage());
        }
        verifyDoctorAvailable(doctor, request.getDate());
        verifyEnoughPatientNumber(request.getDoctorId(), request.getDate(), doctor.getPatientNumber());
        Appointment appointment = new Appointment();
        appointment.setDoctor(doctor);
        appointment.setPatient(patient);
        appointment.setDate(request.getDate());
        Appointment savedAppointment = appointmentRepository.save(appointment);
        return buildAppointmentResponse(savedAppointment, doctor, patient);
    }

    @Transactional
    public AppointmentResponse modifyAppointment(ModifyAppointmentRequest request, User authenticatedUser) {
        Appointment appointment = appointmentRepository.findById(request.getId())
                .orElseThrow(() -> new EntityNotFoundException(ErrorMessage.APPOINTMENT_NOT_FOUND.getMessage()));
        verifyAppointmentOwnership(appointment, authenticatedUser);
        verifyAppointmentNotPast(appointment.getDate());
        verifyAppointmentNotPast(request.getDate());

        // If date is not changing, skip duplicate check
        if (!appointment.getDate().equals(request.getDate())) {
            // Check if there's already another appointment for the same patient and doctor
            // on the new date
            appointmentRepository.findByDoctorIdAndPatientIdAndDate(
                    appointment.getDoctor().getId(),
                    appointment.getPatient().getId(),
                    request.getDate())
                    .ifPresent(existingAppointment -> {
                        throw new EntityNotFoundException(ErrorMessage.APPOINTMENT_EXISTS.getMessage());
                    });

            verifyDoctorAvailable(appointment.getDoctor(), request.getDate());
            verifyEnoughPatientNumber(appointment.getDoctor().getId(), request.getDate(),
                    appointment.getDoctor().getPatientNumber());
        }

        appointment.setDate(request.getDate());
        Appointment savedAppointment = appointmentRepository.save(appointment);
        return buildAppointmentResponse(savedAppointment, savedAppointment.getDoctor(), savedAppointment.getPatient());
    }

    @Transactional
    public String cancelAppointment(Long appointmentId, User authenticatedUser) {
        Appointment appointment = appointmentRepository.findById(appointmentId)
                .orElseThrow(() -> new EntityNotFoundException(ErrorMessage.APPOINTMENT_NOT_FOUND.getMessage()));
        verifyAppointmentOwnership(appointment, authenticatedUser);
        verifyAppointmentNotPast(appointment.getDate());
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
        Day day = Day.valueOf(date.getDayOfWeek().name());
        if (!doctor.getAvailableDays().contains(day)) {
            throw new EntityNotFoundException(ErrorMessage.DOCTOR_NOT_AVAILABLE.getMessage());
        }
    }

    private void verifyEnoughPatientNumber(Long doctorId, LocalDate date, Integer patientNumber) {
        Integer count = appointmentRepository.countByDoctorIdAndDate(doctorId, date);
        if (count + 1 > patientNumber) {
            throw new EntityNotFoundException(ErrorMessage.DOCTOR_CAPACITY_FULL.getMessage());
        }
    }

    private void verifyAppointmentNotPast(LocalDate date) {
        if (date.isBefore(LocalDate.now())) {
            throw new EntityNotFoundException(ErrorMessage.APPOINTMENT_PAST.getMessage());
        }
    }

    private AppointmentResponse buildAppointmentResponse(Appointment appointment, Doctor doctor, Patient patient) {
        return AppointmentResponse.builder()
                .id(appointment.getId())
                .date(appointment.getDate())
                .patientId(patient.getId())
                .patientName(patient.getFullName())
                .patientEmail(patient.getEmail())
                .doctorId(doctor.getId())
                .doctorName(doctor.getFullName())
                .doctorEmail(doctor.getEmail())
                .doctorCity(doctor.getCity().name())
                .doctorStreet(doctor.getStreet())
                .doctorSpecialization(doctor.getDoctorSpeciality().name())
                .doctorStartTime(doctor.getStartTime())
                .doctorEndTime(doctor.getEndTime())
                .doctorConsultationFee(doctor.getConsultationFee())
                .build();
    }

}
