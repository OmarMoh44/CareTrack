package org.example.backend.repository;

import org.example.backend.model.MedicalRecord;
import org.example.backend.model.Patient;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface MedicalRecordRepository extends JpaRepository<MedicalRecord, Long> {
    List<MedicalRecord> findByPatient(Patient patient);
}
