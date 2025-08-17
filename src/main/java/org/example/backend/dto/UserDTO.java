package org.example.backend.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.*;

public class UserDTO {
    @AllArgsConstructor
    @NoArgsConstructor
    @Getter
    @Setter
    @ToString
    public static class LoginRequest {
        @NotBlank(message = "Must be not null")
        @Pattern(regexp = "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$", message = "Must be in email format")
        @Pattern(
                regexp = "^[^\\s@]+@(gmail|yahoo|hotmail|outlook)\\.(com|net|org)$",
                message = "Must be in email format"
        )
        private String email;

        @NotBlank(message = "Must be not null")
        @Size(min = 6, message = "Password must be more than 5 characters")
        private String password;
    }

    @AllArgsConstructor
    @NoArgsConstructor
    @Getter
    @Setter
    public static class RegistrationRequest extends LoginRequest {
        @NotBlank(message = "Must be not null")
        @Size(min = 10, max = 50, message = "Full name must be between 10 and 50 characters")
        private String fullName;

        @NotBlank(message = "Must be not null")
        @Size(min = 11, max = 11, message = "Phone number must be 11 number")
        @Pattern(regexp = "^(010|011|012|015)\\d{8}$", message = "Invalid phone number")
        private String phoneNumber;

        @Override
        public String toString() {
            String var10000 = this.getFullName();
            return "UserDTO.RegistrationRequest(fullName=" + var10000 +
                    ", phoneNumber=" + this.getPhoneNumber() + ", " + super.toString() + ")";
        }
    }
}
