package org.example.backend.controller;

import io.jsonwebtoken.JwtException;
import io.swagger.v3.oas.annotations.StringToClassMapItem;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.example.backend.dto.*;
import org.example.backend.exception.ErrorMessage;
import org.example.backend.model.Doctor;
import org.example.backend.model.Patient;
import org.example.backend.service.AuthService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class AuthController {
    @Value("${jwt.expiration-ms}")
    private Integer cookieExpire;

    private final AuthService authService;

    @ApiResponse(responseCode = "200", description = "Successfully logged in", content = @Content(
            mediaType = "application/json",
            schema = @Schema(
                    type = "object",
                    properties = {},
                    example = """
                            {
                                "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                            }
                            """
            )
    ))
    @PostMapping("/login")
    public Map<String, Object> login(@RequestBody @Valid LoginRequest loginRequest, HttpServletResponse response) {
        String jwtToken = authService.login(loginRequest);
        if (jwtToken == null)
            throw new JwtException(ErrorMessage.JWT_ERROR.getMessage());
        addCookie(response, jwtToken);
        Map<String, Object> body = new HashMap<>();
        body.put("token", jwtToken);
        return body;
    }

    @ApiResponse(responseCode = "200", description = "Successfully logged in", content = @Content(
            mediaType = "application/json",
            schema = @Schema(
                    type = "object",
                    properties = {
                            @StringToClassMapItem(key = "token", value = String.class),
                            @StringToClassMapItem(key = "user", value = UserMainView.class)
                    },
                    example = """
                            {
                                "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                                "user": {}
                            }
                            """
            )
    ))
    @PostMapping("/register/patient")
    public Map<String, Object> registerPatient(@RequestBody @Valid UserRegisterRequest registrationRequest,
                                               HttpServletResponse response) {
        Map<String, Object> body = authService.register(registrationRequest, Patient.class);
        addCookie(response, body.get("token").toString());
        return body;
    }

    @ApiResponse(responseCode = "200", description = "Successfully logged in", content = @Content(
            mediaType = "application/json",
            schema = @Schema(
                    type = "object",
                    properties = {
                            @StringToClassMapItem(key = "token", value = String.class),
                            @StringToClassMapItem(key = "user", value = DoctorMainView.class)
                    },
                    example = """
                            {
                                "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                                "user": {}
                            }
                            """
            )
    ))
    @PostMapping("/register/doctor")
    public Map<String, Object> registerDoctor(@RequestBody @Valid DoctorRegisterRequest registrationRequest,
                                              HttpServletResponse response) {
        Map<String, Object> body = authService.register(registrationRequest, Doctor.class);
        addCookie(response, body.get("token").toString());
        return body;
    }

    @GetMapping("/logout")
    public String logout(HttpServletResponse response, HttpServletRequest request) {
        Cookie cookie = new Cookie("token", null);
        // To clear token cookie, we must set the cookie with the same settings as when it was created except setMaxAge
        cookie.setHttpOnly(true);
        cookie.setPath("/api");
        cookie.setMaxAge(0);
        response.addCookie(cookie);
        return "Logged out successfully";
    }

    private void addCookie(HttpServletResponse response, String jwtToken) {
        Cookie cookie = new Cookie("token", jwtToken);
        cookie.setHttpOnly(true);
        cookie.setPath("/api"); // base of request paths the browser will send the cookie to.
        cookie.setMaxAge((int) (cookieExpire / 1000));
        response.addCookie(cookie);
    }

}
