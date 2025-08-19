package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.*;

import java.time.LocalDate;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@ToString
public class ModifyAppointmentRequest {
    @NotNull(message = "Must be not null")
    @FutureOrPresent(message = "Date must be in the future")
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate date;

    @NotNull(message = "Must be not null")
    @PositiveOrZero(message = "Must be positive or zero")
    private Long id;
}