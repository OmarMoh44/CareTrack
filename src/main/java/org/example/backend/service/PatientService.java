package org.example.backend.service;

import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.ConstraintViolationException;
import jakarta.validation.Validator;
import lombok.RequiredArgsConstructor;
import org.example.backend.dto.DoctorMainView;
import org.example.backend.dto.DoctorSearchRequest;
import org.example.backend.dto.UserMainView;
import org.example.backend.exception.ErrorMessage;
import org.example.backend.model.City;
import org.example.backend.model.Doctor;
import org.example.backend.model.DoctorSpeciality;
import org.example.backend.model.Patient;
import org.example.backend.repository.DoctorRepository;
import org.example.backend.repository.PatientRepository;
import org.modelmapper.ModelMapper;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PatientService {
    private final DoctorRepository doctorRepository;
    private final PatientRepository patientRepository;
    private final Validator validator;
    private final ObjectMapper objectMapper;
    private final PasswordEncoder passwordEncoder;
    private final ModelMapper modelMapper;

    public UserMainView getPatient(Long id) {
        Patient patient = patientRepository.findById(id).orElseThrow(
                () -> new EntityNotFoundException(ErrorMessage.USER_NOT_FOUND.getMessage()));
        return modelMapper.map(patient, UserMainView.class);
    }

    public UserMainView updatePatient(Long id, Map<String, Object> updates) throws JsonMappingException {
        Patient patient = patientRepository.findById(id).orElseThrow(
                () -> new EntityNotFoundException(ErrorMessage.USER_NOT_FOUND.getMessage()));
        boolean passwordUpdate = updates.containsKey("password");
        objectMapper.updateValue(patient, updates);
        var violations = validator.validate(patient);
        if (!violations.isEmpty()) {
            throw new ConstraintViolationException(violations);
        }
        if (passwordUpdate)
            patient.setPassword(passwordEncoder.encode(updates.get("password").toString()));
        return modelMapper.map(patientRepository.save(patient), UserMainView.class);
    }

    public List<DoctorMainView> doctorsSearch(DoctorSearchRequest searchRequest, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        // Case 1: All specialities and cities
        if (searchRequest.getDoctorSpeciality() == DoctorSpeciality.ALL && searchRequest.getCity() == City.ALL) {
            return doctorRepository.findAll(pageable).getContent().stream()
                    .map(doctor -> modelMapper.map(doctor, DoctorMainView.class))
                    .collect(Collectors.toList());
        }
        // Case 2: Specific speciality and all cities
        if (searchRequest.getCity() == City.ALL) {
            return doctorRepository.findByDoctorSpeciality(searchRequest.getDoctorSpeciality(), pageable).getContent()
                    .stream()
                    .map(doctor -> modelMapper.map(doctor, DoctorMainView.class))
                    .collect(Collectors.toList());
        }
        // Case 3: All specialities and specific city
        if (searchRequest.getDoctorSpeciality() == DoctorSpeciality.ALL) {
            return doctorRepository.findByCity(searchRequest.getCity(), pageable).getContent().stream()
                    .map(doctor -> modelMapper.map(doctor, DoctorMainView.class))
                    .collect(Collectors.toList());
        }
        // Case 4: Specific speciality and specific city
        return doctorRepository.findByCityAndDoctorSpeciality(
                searchRequest.getCity(),
                searchRequest.getDoctorSpeciality(),
                pageable).getContent().stream().map(doctor -> modelMapper.map(doctor, DoctorMainView.class))
                .collect(Collectors.toList());
    }

    public DoctorMainView getDoctorById(Long doctorId) {
        Doctor doctor = doctorRepository.findById(doctorId).orElseThrow(
                () -> new EntityNotFoundException(ErrorMessage.USER_NOT_FOUND.getMessage())
        );
        return modelMapper.map(doctor, DoctorMainView.class);
    }
}
