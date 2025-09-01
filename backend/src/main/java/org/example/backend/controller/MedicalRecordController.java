package org.example.backend.controller;

import jakarta.validation.Valid;
import org.example.backend.dto.AddMedicalRecordRequest;
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
@RequestMapping("/medical-records")
public class MedicalRecordController {
        @Autowired
        private MedicalRecordService medicalRecordService;

        @GetMapping("/patient/me")
        @PreAuthorize("hasAuthority('PATIENT')")
        public List<org.example.backend.dto.MedicalRecordResponse> getRecordsByPatient(
                        @AuthenticationPrincipal User user) {
                // user is guaranteed to be a Patient due to role
                Patient patient = (Patient) user;
                return medicalRecordService.getRecordsByPatient(patient).stream()
                                .map(record -> org.example.backend.dto.MedicalRecordResponse.builder()
                                                .id(record.getId())
                                                .content(record.getContent())
                                                .date(record.getDate())
                                                .doctorId(record.getDoctor() != null ? record.getDoctor().getId()
                                                                : null)
                                                .doctorName(record.getDoctor() != null
                                                                ? record.getDoctor().getFullName()
                                                                : null)
                                                .patientId(record.getPatient() != null ? record.getPatient().getId()
                                                                : null)
                                                .patientName(record.getPatient() != null
                                                                ? record.getPatient().getFullName()
                                                                : null)
                                                .build())
                                .toList();
        }

        @GetMapping("/{recordId}")
        public Optional<MedicalRecord> getRecordById(@PathVariable Long recordId) {
                return medicalRecordService.getRecordById(recordId);
        }

        @PutMapping("/{recordId}")
        @PreAuthorize("hasAuthority('DOCTOR')")
        public MedicalRecord updateMedicalRecord(@PathVariable Long recordId, @RequestBody MedicalRecord updatedRecord,
                        @AuthenticationPrincipal User user) {
                updatedRecord.setId(recordId);
                return medicalRecordService.saveRecord(updatedRecord);
        }

        @Autowired
        private org.example.backend.repository.MedicalRecordRepository medicalRecordRepository;
        @Autowired
        private org.example.backend.repository.DoctorRepository doctorRepository;

        @PostMapping("/share")
        @PreAuthorize("hasAuthority('PATIENT')")
        public void shareRecordWithDoctor(@RequestParam Long recordId, @RequestParam Long doctorId,
                        @AuthenticationPrincipal User user) {
                // user is guaranteed to be a Patient due to role
                MedicalRecord record = medicalRecordRepository.findById(recordId)
                                .orElseThrow(() -> new RuntimeException("MedicalRecord not found"));
                Doctor doctor = doctorRepository.findById(doctorId)
                                .orElseThrow(() -> new RuntimeException("Doctor not found"));
                medicalRecordService.shareRecordWithDoctor(record, doctor);
        }

        @GetMapping("/shared/doctor/me")
        @PreAuthorize("hasAuthority('DOCTOR')")
        public List<org.example.backend.dto.MedicalRecordResponse> getSharedRecordsForDoctor(
                        @AuthenticationPrincipal User user) {
                // user is guaranteed to be a Doctor due to role
                Doctor doctor = (Doctor) user;
                return medicalRecordService.getSharedRecordsForDoctor(doctor).stream()
                                .map(record -> org.example.backend.dto.MedicalRecordResponse.builder()
                                                .id(record.getId())
                                                .content(record.getContent())
                                                .date(record.getDate())
                                                .doctorId(record.getDoctor() != null ? record.getDoctor().getId()
                                                                : null)
                                                .doctorName(record.getDoctor() != null
                                                                ? record.getDoctor().getFullName()
                                                                : null)
                                                .patientId(record.getPatient() != null ? record.getPatient().getId()
                                                                : null)
                                                .patientName(record.getPatient() != null
                                                                ? record.getPatient().getFullName()
                                                                : null)
                                                .build())
                                .toList();
        }

        @GetMapping("/shared/patient/me")
        @PreAuthorize("hasAuthority('PATIENT')")
        public List<MedicalRecord> getSharedRecordsForPatient(@AuthenticationPrincipal User user) {
                // user is guaranteed to be a Patient due to role
                Patient patient = (Patient) user;
                return medicalRecordService.getSharedRecordsForPatient(patient);
        }

        @PostMapping
        @PreAuthorize("hasAuthority('DOCTOR')")
        public void createMedicalRecord(@RequestBody @Valid AddMedicalRecordRequest newRecord,
                        @AuthenticationPrincipal User user) {
                System.out.println("Creating record: " + newRecord.toString());
                Doctor doctor = (Doctor) user;
                MedicalRecord record = medicalRecordService.addMedicalRecod(newRecord, doctor);
                medicalRecordService.shareRecordWithDoctor(record, doctorRepository.findById(doctor.getId()).orElseThrow(
                                () -> new RuntimeException("Doctor not found")
                ));
        }

        @PostMapping("/share-all")
        @PreAuthorize("hasAuthority('PATIENT')")
        public void shareAllRecordsWithDoctor(@RequestParam Long doctorId, @AuthenticationPrincipal User user) {
                // user is guaranteed to be a Patient due to role
                Patient patient = (Patient) user;
                Doctor doctor = doctorRepository.findById(doctorId)
                                .orElseThrow(() -> new RuntimeException("Doctor not found"));
                medicalRecordService.shareAllRecordsWithDoctor(patient, doctor);
        }
}