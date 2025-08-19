package org.example.backend.controller;

import com.fasterxml.jackson.databind.JsonMappingException;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.RequiredArgsConstructor;
import org.example.backend.dto.DoctorMainView;
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

    @GetMapping
    @PreAuthorize("hasAuthority('DOCTOR')")
    public DoctorMainView getDoctor(Authentication authentication) {
        User authenticatedUser = (User) authentication.getPrincipal();
        return doctorService.getDoctor(authenticatedUser.getId());
    }

    @PatchMapping
    @PreAuthorize("hasAuthority('DOCTOR')")
    @io.swagger.v3.oas.annotations.parameters.RequestBody(
            description = "Dynamic map containing doctor fields to update",
            content = @Content(
                    mediaType = "application/json",
                    schema = @Schema(
                            type = "object",
                            description = "Map containing any combination of doctor fields to update"
                    )
            )
    )
    public DoctorMainView updateDoctor(
            @RequestBody Map<String, Object> updates,
            Authentication authentication) throws JsonMappingException {
        User authenticatedUser = (User) authentication.getPrincipal();
        return doctorService.updateDoctor(authenticatedUser.getId(), updates);
    }

}
