package org.example.backend.repository;

import org.example.backend.model.Appointment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface AppointmentRepository extends JpaRepository<Appointment, Long> {
    Integer countByDoctorIdAndDate(Long doctorId, LocalDate date);

    Optional<Appointment> findByDoctorIdAndPatientIdAndDate(Long doctorId, Long patientId, LocalDate date);

    List<Appointment> findByPatientIdAndDateGreaterThanEqual(Long patientId, LocalDate date);

    List<Appointment> findByDoctorIdAndDateGreaterThanEqual(Long doctorId, LocalDate date);
}
