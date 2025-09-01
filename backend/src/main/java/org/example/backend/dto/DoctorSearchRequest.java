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

    @NotNull(message = "Must not be null")
    private DoctorSpeciality doctorSpeciality;
}
