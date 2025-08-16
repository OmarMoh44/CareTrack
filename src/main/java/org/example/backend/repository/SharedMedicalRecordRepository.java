package org.example.backend.repository;

import org.example.backend.model.SharedMedicalRecord;
import org.example.backend.model.Doctor;
import org.example.backend.model.Patient;
import org.example.backend.model.MedicalRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface SharedMedicalRecordRepository extends JpaRepository<SharedMedicalRecord, Long> {
    List<SharedMedicalRecord> findByPatient(Patient patient);

    List<SharedMedicalRecord> findByDoctor(Doctor doctor);

    List<SharedMedicalRecord> findByMedicalRecord(MedicalRecord medicalRecord);

    List<SharedMedicalRecord> findByPatientAndDoctor(Patient patient, Doctor doctor);

    List<SharedMedicalRecord> findByPatientAndMedicalRecord(Patient patient, MedicalRecord medicalRecord);
}
