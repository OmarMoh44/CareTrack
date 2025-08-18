package org.example.backend.controller;

import org.example.backend.model.User;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.example.backend.model.MedicalRecord;
import org.example.backend.model.Patient;
import org.example.backend.model.Doctor;
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

    @GetMapping("/patient/me")
    @PreAuthorize("hasRole('PATIENT')")
    public List<MedicalRecord> getRecordsByPatient(@AuthenticationPrincipal User user) {
        // user is guaranteed to be a Patient due to role
        Patient patient = (Patient) user;
        return medicalRecordService.getRecordsByPatient(patient);
    }

    @GetMapping("/{recordId}")
    public Optional<MedicalRecord> getRecordById(@PathVariable Long recordId) {
        return medicalRecordService.getRecordById(recordId);
    }

    @PutMapping("/{recordId}")
    @PreAuthorize("hasRole('DOCTOR')")
    public MedicalRecord updateMedicalRecord(@PathVariable Long recordId, @RequestBody MedicalRecord updatedRecord,
            @AuthenticationPrincipal User user) {
        updatedRecord.setId(recordId);
        return medicalRecordService.saveRecord(updatedRecord);
    }

    @PostMapping("/share")
    @PreAuthorize("hasRole('PATIENT')")
    public void shareRecordWithDoctor(@RequestParam Long recordId, @RequestParam Long doctorId,
            @AuthenticationPrincipal User user) {
        // user is guaranteed to be a Patient due to role
        MedicalRecord record = new MedicalRecord();
        record.setId(recordId);
        Doctor doctor = new Doctor();
        doctor.setId(doctorId);
        medicalRecordService.shareRecordWithDoctor(record, doctor);
    }

    @GetMapping("/shared/doctor/me")
    @PreAuthorize("hasRole('DOCTOR')")
    public List<MedicalRecord> getSharedRecordsForDoctor(@AuthenticationPrincipal User user) {
        // user is guaranteed to be a Doctor due to role
        Doctor doctor = (Doctor) user;
        return medicalRecordService.getSharedRecordsForDoctor(doctor);
    }

    @GetMapping("/shared/patient/me")
    @PreAuthorize("hasRole('PATIENT')")
    public List<MedicalRecord> getSharedRecordsForPatient(@AuthenticationPrincipal User user) {
        // user is guaranteed to be a Patient due to role
        Patient patient = (Patient) user;
        return medicalRecordService.getSharedRecordsForPatient(patient);
    }
}