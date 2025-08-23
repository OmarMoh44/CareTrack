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
        if (doctors == null) {
            doctors = new java.util.ArrayList<>();
        }
        if (!doctors.contains(doctor)) {
            doctors.add(doctor);
            record.setSharedWithDoctors(doctors);
        }

        List<MedicalRecord> records = doctor.getAccessibleMedicalRecords();
        if (records == null) {
            records = new java.util.ArrayList<>();
        }
        if (!records.contains(record)) {
            records.add(record);
            doctor.setAccessibleMedicalRecords(records);
        }

        medicalRecordRepository.save(record);

        org.example.backend.repository.DoctorRepository doctorRepository = null;
        try {
            java.lang.reflect.Field repoField = this.getClass().getDeclaredField("doctorRepository");
            repoField.setAccessible(true);
            doctorRepository = (org.example.backend.repository.DoctorRepository) repoField.get(this);
        } catch (Exception e) {

        }
        if (doctorRepository != null) {
            doctorRepository.save(doctor);
        }
    }

    public List<MedicalRecord> getSharedRecordsForDoctor(Doctor doctor) {
        return medicalRecordRepository.findMedicalRecordsSharedWithDoctor(doctor.getId());
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
