package org.example.backend.controller;

import org.example.backend.dto.AppointmentResponse;
import org.example.backend.dto.BookAppointmentRequest;
import org.example.backend.dto.ModifyAppointmentRequest;
import org.example.backend.model.Patient;
import org.example.backend.model.User;
import org.example.backend.service.AppointmentService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

import java.util.List;

@RestController
@RequestMapping("/appointments")
@RequiredArgsConstructor
public class AppointmentController {
    private final AppointmentService appointmentService;

    @GetMapping
    @PreAuthorize("hasAnyAuthority('PATIENT', 'DOCTOR')")
    public List<AppointmentResponse> getAppointments(Authentication authentication) {
        User authenticatedUser = (User) authentication.getPrincipal();
        return appointmentService.getAppointments(authenticatedUser);
    }

    @PostMapping
    @PreAuthorize("hasAuthority('PATIENT')")
    public AppointmentResponse bookAppointment(@RequestBody @Valid BookAppointmentRequest request,
                                               Authentication authentication) {
        Patient authenticatedUser = (Patient) authentication.getPrincipal();
        return appointmentService.bookAppointment(request, authenticatedUser);
    }

    @PatchMapping("/{appointmentId}")
    @PreAuthorize("hasAnyAuthority('PATIENT', 'DOCTOR')")
    public AppointmentResponse updateAppointment(@RequestBody @Valid ModifyAppointmentRequest request,
                                                 Authentication authentication) {
        User authenticatedUser = (User) authentication.getPrincipal();
        return appointmentService.updateAppointment(request, authenticatedUser);
    }


    @DeleteMapping("/{appointmentId}")
    @PreAuthorize("hasAnyAuthority('PATIENT', 'DOCTOR')")
    public String cancelAppointment(@PathVariable Long appointmentId,
                                    Authentication authentication) {
        User authenticatedUser = (User) authentication.getPrincipal();
        return appointmentService.cancelAppointment(appointmentId, authenticatedUser);
    }
}
