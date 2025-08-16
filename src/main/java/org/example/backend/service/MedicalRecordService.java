package org.example.backend.service;

import org.example.backend.model.MedicalRecord;
import org.example.backend.model.Patient;
import org.example.backend.model.Doctor;
import org.example.backend.model.SharedMedicalRecord;
import org.example.backend.repository.MedicalRecordRepository;
import org.example.backend.repository.SharedMedicalRecordRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class MedicalRecordService {
    @Autowired
    private MedicalRecordRepository medicalRecordRepository;
    @Autowired
    private SharedMedicalRecordRepository sharedMedicalRecordRepository;

    public List<MedicalRecord> getRecordsByPatient(Patient patient) {
        return medicalRecordRepository.findByPatient(patient);
    }

    public Optional<MedicalRecord> getRecordById(Long id) {
        return medicalRecordRepository.findById(id);
    }

    public MedicalRecord saveRecord(MedicalRecord record) {
        return medicalRecordRepository.save(record);
    }

    public void shareRecordWithDoctor(MedicalRecord record, Patient patient, Doctor doctor) {
        SharedMedicalRecord shared = new SharedMedicalRecord(record, patient, doctor);
        sharedMedicalRecordRepository.save(shared);
    }

    public List<SharedMedicalRecord> getSharedRecordsForDoctor(Doctor doctor) {
        return sharedMedicalRecordRepository.findByDoctor(doctor);
    }

    public List<SharedMedicalRecord> getSharedRecordsForPatient(Patient patient) {
        return sharedMedicalRecordRepository.findByPatient(patient);
    }

    public void updateMedicalRecord(MedicalRecord record) {
        medicalRecordRepository.save(record);
    }
}
