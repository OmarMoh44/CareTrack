package org.example.backend.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.EntityExistsException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.example.backend.dto.UserDTO;
import org.example.backend.exception.ErrorMessage;
import org.example.backend.jwt.JwtService;
import org.example.backend.model.User;
import org.example.backend.repository.UserRepository;
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
    private final ObjectMapper objectMapper;

    public String login(UserDTO.LoginRequest loginRequest) {
        // runs UserDetailsService bean to find user from DB and compares passwords
        Authentication authentication = authenticationManager.authenticate
                (new UsernamePasswordAuthenticationToken(loginRequest.getEmail(), loginRequest.getPassword()));
        if (authentication.isAuthenticated()) {
            String jwtToken = jwtService.generateToken(loginRequest.getEmail());
            return jwtToken;
        }
        return null;
    }

    public <T extends User> Map<String, Object> register(UserDTO.RegistrationRequest registrationRequest, Class <T> targetClass) {
        T user = objectMapper.convertValue(registrationRequest, targetClass);
        Optional<User> userExisted = userRepository.findByEmailOrPhoneNumber(user.getEmail(), user.getPhoneNumber());
        if(userExisted.isPresent())
            throw new EntityExistsException(ErrorMessage.USER_EXIT.getMessage());
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        User createdUser = userRepository.save(user);
        String jwtToken = jwtService.generateToken(user.getEmail());
        Map<String, Object> map = new HashMap<>();
        map.put("user", createdUser);
        map.put("token", jwtToken);
        return map;
    }

}
