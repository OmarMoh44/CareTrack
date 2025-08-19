package org.example.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;
import org.example.backend.model.City;
import org.example.backend.model.DoctorSpeciality;


@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@ToString
public class DoctorSearchRequest{
    @NotNull(message = "Must not be null")
    private City city;

    @NotBlank(message = "Must be not null")
    @Size(min = 5, message = "Street address is too short")
    private String street;

    @NotNull(message = "Must not be null")
    private DoctorSpeciality doctorSpeciality;
}
