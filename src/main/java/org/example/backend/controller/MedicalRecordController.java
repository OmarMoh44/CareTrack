package org.example.backend.controller;

import org.example.backend.model.MedicalRecord;
import org.example.backend.model.Patient;
import org.example.backend.model.Doctor;
import org.example.backend.model.SharedMedicalRecord;
import org.example.backend.service.MedicalRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/medical-records")
public class MedicalRecordController {
    @Autowired
    private MedicalRecordService medicalRecordService;

    @GetMapping("/patient/{patientId}")
    public List<MedicalRecord> getRecordsByPatient(@PathVariable Long patientId) {
        Patient patient = new Patient();
        patient.setId(patientId);
        return medicalRecordService.getRecordsByPatient(patient);
    }

    @GetMapping("/{recordId}")
    public Optional<MedicalRecord> getRecordById(@PathVariable Long recordId) {
        return medicalRecordService.getRecordById(recordId);
    }

    @PutMapping("/{recordId}")
    public MedicalRecord updateMedicalRecord(@PathVariable Long recordId, @RequestBody MedicalRecord updatedRecord) {
        updatedRecord.setId(recordId);
        return medicalRecordService.saveRecord(updatedRecord);
    }

    @PostMapping("/share")
    public void shareRecordWithDoctor(@RequestParam Long recordId, @RequestParam Long patientId,
            @RequestParam Long doctorId) {
        MedicalRecord record = new MedicalRecord();
        record.setId(recordId);
        Patient patient = new Patient();
        patient.setId(patientId);
        Doctor doctor = new Doctor();
        doctor.setId(doctorId);
        medicalRecordService.shareRecordWithDoctor(record, patient, doctor);
    }

    @GetMapping("/shared/doctor/{doctorId}")
    public List<SharedMedicalRecord> getSharedRecordsForDoctor(@PathVariable Long doctorId) {
        Doctor doctor = new Doctor();
        doctor.setId(doctorId);
        return medicalRecordService.getSharedRecordsForDoctor(doctor);
    }

    @GetMapping("/shared/patient/{patientId}")
    public List<SharedMedicalRecord> getSharedRecordsForPatient(@PathVariable Long patientId) {
        Patient patient = new Patient();
        patient.setId(patientId);
        return medicalRecordService.getSharedRecordsForPatient(patient);
    }
}
