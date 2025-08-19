package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalTime;

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
    private String doctorCity;
    private String doctorStreet;
    private String doctorSpecialization;
    private LocalTime doctorStartTime;
    private LocalTime doctorEndTime;
    private Double doctorConsultationFee;
}
