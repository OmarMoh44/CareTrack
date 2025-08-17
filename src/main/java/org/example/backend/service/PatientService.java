package org.example.backend.service;

import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.ConstraintViolationException;
import jakarta.validation.Validator;
import lombok.RequiredArgsConstructor;
import org.example.backend.dto.DoctorDTO;
import org.example.backend.exception.ErrorMessage;
import org.example.backend.model.Doctor;
import org.example.backend.model.Patient;
import org.example.backend.repository.DoctorRepository;
import org.example.backend.repository.PatientRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class PatientService {
    private final DoctorRepository doctorRepository;
    private final PatientRepository patientRepository;
    private final Validator validator;
    private final ObjectMapper objectMapper;
    private final PasswordEncoder passwordEncoder;

    public List<Doctor> doctorsSearch(DoctorDTO.SearchRequest searchRequest, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return doctorRepository.findByCityAndDoctorSpecialityAndStreetContainingIgnoreCase(
                searchRequest.getCity(),
                searchRequest.getDoctorSpeciality(),
                searchRequest.getStreet(),
                pageable
        ).getContent();

    }

    public Patient updatePatient(Long id, Map<String, Object> updates) throws JsonMappingException {
        Patient patient = patientRepository.findById(id).orElseThrow(
                () -> new EntityNotFoundException(ErrorMessage.USER_NOT_FOUND.getMessage())
        );
        boolean passwordUpdate = updates.containsKey("password");
        objectMapper.updateValue(patient, updates);
        var violations = validator.validate(patient);
        if (!violations.isEmpty()) {
            throw new ConstraintViolationException(violations);
        }
        if (passwordUpdate) patient.setPassword(passwordEncoder.encode(updates.get("password").toString()));
        return patientRepository.save(patient);
    }
}
