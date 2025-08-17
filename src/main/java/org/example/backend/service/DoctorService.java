package org.example.backend.service;

import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.ConstraintViolationException;
import jakarta.validation.Validator;
import lombok.RequiredArgsConstructor;
import org.example.backend.exception.ErrorMessage;
import org.example.backend.model.Doctor;
import org.example.backend.repository.DoctorRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
@RequiredArgsConstructor
public class DoctorService {
    private final DoctorRepository doctorRepository;
    private final Validator validator;
    private final ObjectMapper objectMapper;
    private final PasswordEncoder passwordEncoder;


    public Doctor updateDoctor(Long id, Map<String, Object> updates) throws JsonMappingException {
        Doctor doctor = doctorRepository.findById(id).orElseThrow(
                () -> new EntityNotFoundException(ErrorMessage.USER_NOT_FOUND.getMessage())
        );
        boolean passwordUpdate = updates.containsKey("password");
        objectMapper.updateValue(doctor, updates);
        var violations = validator.validate(doctor);
        if (!violations.isEmpty()) {
            throw new ConstraintViolationException(violations);
        }
        if (passwordUpdate) doctor.setPassword(passwordEncoder.encode(updates.get("password").toString()));
        return doctorRepository.save(doctor);
    }
}
