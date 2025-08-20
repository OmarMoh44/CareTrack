package org.example.backend.repository;

import org.example.backend.model.Appointment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;

@Repository
public interface AppointmentRepository extends JpaRepository<Appointment, Long> {
    Integer countByDoctorIdAndDate(Long doctorId, LocalDate date);

    Optional<Appointment> findByDoctorIdAndPatientIdAndDate(Long doctorId, Long patientId, LocalDate date);

    Page<Appointment> findByPatientIdAndDateGreaterThanEqual(Long patientId, LocalDate date, Pageable pageable);

    Page<Appointment> findByDoctorIdAndDateGreaterThanEqual(Long doctorId, LocalDate date, Pageable pageable);
}
