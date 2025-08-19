package org.example.backend.service;

import jakarta.persistence.EntityExistsException;
import lombok.RequiredArgsConstructor;
import org.example.backend.dto.DoctorMainView;
import org.example.backend.dto.LoginRequest;
import org.example.backend.dto.UserMainView;
import org.example.backend.dto.UserRegisterRequest;
import org.example.backend.exception.ErrorMessage;
import org.example.backend.jwt.JwtService;
import org.example.backend.model.Patient;
import org.example.backend.model.User;
import org.example.backend.repository.UserRepository;
import org.modelmapper.ModelMapper;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final PasswordEncoder passwordEncoder;
    private final UserRepository userRepository;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final ModelMapper modelMapper;

    public String login(LoginRequest loginRequest) {
        // runs UserDetailsService bean to find user from DB and compares passwords
        Authentication authentication = authenticationManager.authenticate
                (new UsernamePasswordAuthenticationToken(loginRequest.getEmail(), loginRequest.getPassword()));
        if (authentication.isAuthenticated()) {
            String jwtToken = jwtService.generateToken(loginRequest.getEmail());
            return jwtToken;
        }
        return null;
    }

    public <T extends User> Map<String, Object> register(UserRegisterRequest registrationRequest, Class<T> targetClass) {
        T user = modelMapper.map(registrationRequest, targetClass);
        Optional<User> userExisted = userRepository.findByEmailOrPhoneNumber(user.getEmail(), user.getPhoneNumber());
        if (userExisted.isPresent())
            throw new EntityExistsException(ErrorMessage.USER_EXIT.getMessage());
        user.setPassword(passwordEncoder.encode(registrationRequest.getPassword()));
        T createdUser = userRepository.save(user);
        String jwtToken = jwtService.generateToken(user.getEmail());
        Map<String, Object> map = new HashMap<>();
        if (createdUser instanceof Patient)
            map.put("user", modelMapper.map(createdUser, UserMainView.class));
        else
            map.put("user", modelMapper.map(createdUser, DoctorMainView.class));
        map.put("token", jwtToken);
        return map;
    }

    public void deleteAccount(User authenticatedUser) {
        userRepository.deleteById(authenticatedUser.getId());
    }
}
