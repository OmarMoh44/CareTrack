package org.example.backend.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.*;
import lombok.*;
import org.example.backend.model.City;
import org.example.backend.model.Day;
import org.example.backend.model.DoctorSpeciality;
import org.example.backend.validator.EnumValue;

import java.time.LocalTime;
import java.util.List;

public class DoctorDTO {
    @AllArgsConstructor
    @NoArgsConstructor
    @Getter
    @Setter
    public static class RegistrationRequest extends UserDTO.RegistrationRequest {
        @NotNull(message = "Must be not null")
        @EnumValue(enumClass = City.class, message = "Invalid city")
        private City city;

        @NotBlank(message = "Must be not null")
        @Size(min = 10, message = "Street address is too short")
        private String street;

        @NotNull(message = "Must be not null")
        @EnumValue(enumClass = DoctorSpeciality.class, message = "Invalid doctor speciality")
        private DoctorSpeciality doctorSpeciality;

        @NotBlank(message = "Must be not null")
        @Size(min = 25, max = 500, message = "Information must be between 25 and 500 characters")
        private String info;

        @NotNull(message = "Must not be null")
        @Positive(message = "Must be positive")
        private Long patientNumber;

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
        private List<
                @NotNull(message = "Must not be null")
                @EnumValue(enumClass = Day.class, message = "Invalid day")
                        Day> availableDays;


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


}
