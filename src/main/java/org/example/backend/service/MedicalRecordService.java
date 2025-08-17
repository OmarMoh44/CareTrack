package org.example.backend.service;

import org.example.backend.model.MedicalRecord;
import org.example.backend.model.Patient;
import org.example.backend.model.Doctor;
import org.example.backend.repository.MedicalRecordRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class MedicalRecordService {
    @Autowired
    private MedicalRecordRepository medicalRecordRepository;

    public List<MedicalRecord> getRecordsByPatient(Patient patient) {
        return medicalRecordRepository.findByPatient(patient);
    }

    public Optional<MedicalRecord> getRecordById(Long id) {
        return medicalRecordRepository.findById(id);
    }

    public MedicalRecord saveRecord(MedicalRecord record) {
        return medicalRecordRepository.save(record);
    }

    public void shareRecordWithDoctor(MedicalRecord record, Doctor doctor) {
        List<Doctor> doctors = record.getSharedWithDoctors();
        if (!doctors.contains(doctor)) {
            doctors.add(doctor);
            record.setSharedWithDoctors(doctors);
            medicalRecordRepository.save(record);
        }
    }

    public List<MedicalRecord> getSharedRecordsForDoctor(Doctor doctor) {
        return doctor.getAccessibleMedicalRecords();
    }

    public List<MedicalRecord> getSharedRecordsForPatient(Patient patient) {
        List<MedicalRecord> all = medicalRecordRepository.findByPatient(patient);
        return all.stream().filter(r -> r.getSharedWithDoctors() != null && !r.getSharedWithDoctors().isEmpty())
                .toList();
    }

    public void updateMedicalRecord(MedicalRecord record) {
        medicalRecordRepository.save(record);
    }
}
