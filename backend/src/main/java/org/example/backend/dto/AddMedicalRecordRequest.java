package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.*;

import java.time.LocalDate;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@ToString
public class AddMedicalRecordRequest {
    @NotNull(message = "Must be not null")
    @PositiveOrZero(message = "Must be positive or zero")
    private Long patientId;

    @NotBlank(message = "Must be not null")
    private String content;

    @NotNull(message = "Must be not null")
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate date;

}
