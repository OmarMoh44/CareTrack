package org.example.backend.controller;

import com.fasterxml.jackson.databind.JsonMappingException;
import lombok.RequiredArgsConstructor;
import org.example.backend.dto.DoctorDTO;
import org.example.backend.model.User;
import org.example.backend.service.DoctorService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/doctor")
public class DoctorController {
    private final DoctorService doctorService;

    @PatchMapping
    @PreAuthorize("hasAuthority('DOCTOR')")
    public DoctorDTO.MainView updateDoctor(@RequestBody Map<String, Object> updates,
                                           Authentication authentication) throws JsonMappingException {
        User authenticatedUser = (User) authentication.getPrincipal();
        return doctorService.updateDoctor(authenticatedUser.getId(), updates);
    }

}
