package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.example.backend.model.City;
import org.example.backend.model.Day;
import org.example.backend.model.DoctorSpeciality;
import org.example.backend.validator.FieldsComparison;
import org.example.backend.validator.NoDuplicates;

import java.time.LocalTime;
import java.util.List;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@FieldsComparison(smallerField = "startTime", biggerField = "endTime", message = "End time must be after start time")
public class DoctorRegisterRequest extends UserRegisterRequest {
    @NotNull(message = "Must not be null")
    private City city;

    @NotBlank(message = "Must be not null")
    @Size(min = 10, message = "Street address is too short")
    private String street;

    @NotNull(message = "Must not be null")
    private DoctorSpeciality doctorSpeciality;

    @NotBlank(message = "Must be not null")
    @Size(min = 25, max = 500, message = "Information must be between 25 and 500 characters")
    private String info;

    @NotNull(message = "Must not be null")
    @Positive(message = "Must be positive")
    private Integer patientNumber;

    @NotNull(message = "Must not be null")
    @JsonFormat(pattern = "HH:mm")
    private LocalTime startTime;

    @NotNull(message = "Must not be null")
    @JsonFormat(pattern = "HH:mm")
    private LocalTime endTime;

    @NotNull(message = "Must not be null")
    @Positive(message = "Must be positive")
    private Double consultationFee;

    @NotNull(message = "Must not be null")
    @Size(max = 7, message = "No more than 7 days")
    @NoDuplicates
    private List<@NotNull(message = "Must not be null") Day> availableDays;


    @Override
    public String toString() {
        String var10000 = String.valueOf(this.getCity());
        return "DoctorDTO.RegistrationRequest(city=" + var10000 + ", street=" + this.getStreet() +
                ", doctorSpeciality=" + String.valueOf(this.getDoctorSpeciality()) +
                ", info=" + this.getInfo() + ", patientNumber=" + this.getPatientNumber() +
                ", startTime=" + String.valueOf(this.getStartTime()) + ", endTime=" + String.valueOf(this.getEndTime()) +
                ", consultationFee=" + this.getConsultationFee() + ", availableDays=" + String.valueOf(this.getAvailableDays()) +
                ", " + super.toString() + ")";
    }
}
