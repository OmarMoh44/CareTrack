package org.example.backend.service;

import org.example.backend.dto.AddMedicalRecordRequest;
import org.example.backend.model.MedicalRecord;
import org.example.backend.model.Patient;
import org.example.backend.model.Doctor;
import org.example.backend.repository.MedicalRecordRepository;
import org.example.backend.repository.PatientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class MedicalRecordService {
    @Autowired
    private MedicalRecordRepository medicalRecordRepository;
    @Autowired
    private PatientRepository patientRepository;

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

    public void shareAllRecordsWithDoctor(Patient patient, Doctor doctor) {
        List<MedicalRecord> records = medicalRecordRepository.findByPatient(patient);
        for (MedicalRecord record : records) {
            List<Doctor> sharedDoctors = record.getSharedWithDoctors();
            if (sharedDoctors == null) {
                sharedDoctors = new java.util.ArrayList<>();
            }
            if (!sharedDoctors.contains(doctor)) {
                sharedDoctors.add(doctor);
                record.setSharedWithDoctors(sharedDoctors);
            }

            List<MedicalRecord> doctorRecords = doctor.getAccessibleMedicalRecords();
            if (doctorRecords == null) {
                doctorRecords = new java.util.ArrayList<>();
            }
            if (!doctorRecords.contains(record)) {
                doctorRecords.add(record);
                doctor.setAccessibleMedicalRecords(doctorRecords);
            }
            medicalRecordRepository.save(record);
        }
    }

    public MedicalRecord addMedicalRecod(AddMedicalRecordRequest newRecord, Doctor doctor) {
        Patient patient = patientRepository.findById(newRecord.getPatientId())
                .orElseThrow(() -> new RuntimeException("Patient not found"));
        MedicalRecord record = MedicalRecord.builder()
                .content(newRecord.getContent())
                .date(newRecord.getDate())
                .doctor(doctor)
                .patient(patient)
                .build();
        return medicalRecordRepository.save(record);
    }
}
