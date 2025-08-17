package org.example.backend.controller;

import com.fasterxml.jackson.databind.JsonMappingException;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.example.backend.dto.DoctorDTO;
import org.example.backend.model.Doctor;
import org.example.backend.model.Patient;
import org.example.backend.model.User;
import org.example.backend.service.PatientService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/patient")
public class PatientController {
    private final PatientService patientService;

    @PostMapping("/doctors-search")
    @PreAuthorize("hasAuthority('PATIENT')")
    public List<Doctor> doctorsSearch(@RequestBody @Valid DoctorDTO.SearchRequest searchRequest,
                                      @RequestParam(defaultValue = "0") int page,
                                      @RequestParam(defaultValue = "10") int size){
        return patientService.doctorsSearch(searchRequest, page, size);
    }

    @PatchMapping
    @PreAuthorize("hasAuthority('PATIENT')")
    public Patient updatePatient(@RequestBody Map<String, Object> updates,
                                 Authentication authentication) throws JsonMappingException {
        User authenticatedUser = (User) authentication.getPrincipal();
        return patientService.updatePatient(authenticatedUser.getId(), updates);
    }
}
