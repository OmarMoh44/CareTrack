package org.example.backend.repository;

import org.example.backend.model.MedicalRecord;
import org.example.backend.model.Patient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface MedicalRecordRepository extends JpaRepository<MedicalRecord, Long> {
    List<MedicalRecord> findByPatient(Patient patient);

    @Query("SELECT mr FROM MedicalRecord mr JOIN mr.sharedWithDoctors d WHERE d.id = :doctorId")
    List<MedicalRecord> findMedicalRecordsSharedWithDoctor(@Param("doctorId") Long doctorId);
}
