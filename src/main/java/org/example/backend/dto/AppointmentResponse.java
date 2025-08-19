package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

@AllArgsConstructor
@NoArgsConstructor
@Setter
@Getter
@Builder
public class AppointmentResponse {
    private Long id;
    
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate date;
    
    private Long patientId;
    private String patientName;
    
    private Long doctorId;
    private String doctorName;
    private String doctorSpecialization;
}
