package org.example.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.*;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@ToString
public class LoginRequest {
    @NotBlank(message = "Must be not null")
    @Pattern(
            regexp = "^[^\\s@]+@(gmail|yahoo|hotmail|outlook)\\.(com|net|org)$",
            message = "Must be in email format"
    )
    private String email;

    @NotBlank(message = "Must be not null")
    @Size(min = 6, message = "Password must be more than 5 characters")
    private String password;
}
