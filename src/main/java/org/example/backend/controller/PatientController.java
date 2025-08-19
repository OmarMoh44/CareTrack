package org.example.backend.controller;

import com.fasterxml.jackson.databind.JsonMappingException;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.example.backend.dto.DoctorMainView;
import org.example.backend.dto.DoctorSearchRequest;
import org.example.backend.dto.UserMainView;
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

    @GetMapping
    @PreAuthorize("hasAuthority('PATIENT')")
    public UserMainView getPatient(Authentication authentication) {
        User authenticatedUser = (User) authentication.getPrincipal();
        return patientService.getPatient(authenticatedUser.getId());
    }

    @io.swagger.v3.oas.annotations.parameters.RequestBody(
            description = "Dynamic map containing patient fields to update",
            content = @Content(
                    mediaType = "application/json",
                    schema = @Schema(
                            type = "object",
                            description = "Map containing any combination of patient fields to update"
                    )
            )
    )
    @PatchMapping
    @PreAuthorize("hasAuthority('PATIENT')")
    public UserMainView updatePatient(@RequestBody Map<String, Object> updates,
                                      Authentication authentication) throws JsonMappingException {
        User authenticatedUser = (User) authentication.getPrincipal();
        return patientService.updatePatient(authenticatedUser.getId(), updates);
    }

    @PostMapping("/doctors-search")
    @PreAuthorize("hasAuthority('PATIENT')")
    public List<DoctorMainView> doctorsSearch(@RequestBody @Valid DoctorSearchRequest searchRequest,
                                              @RequestParam(defaultValue = "0") int page,
                                              @RequestParam(defaultValue = "10") int size){
        return patientService.doctorsSearch(searchRequest, page, size);
    }
}
