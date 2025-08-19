package org.example.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class UserRegisterRequest extends LoginRequest {
    @NotBlank(message = "Must be not null")
    @Size(min = 7, max = 50, message = "Full name must be between 7 and 50 characters")
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