package org.example.backend.model;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.*;
import lombok.experimental.SuperBuilder;
import org.example.backend.validator.FieldsComparison;
import org.example.backend.validator.NoDuplicates;

import java.time.LocalTime;
import java.util.*;

@AllArgsConstructor
@NoArgsConstructor
@Setter
@Getter
@SuperBuilder
@Entity
@Table(name = "doctors")
@DiscriminatorValue("DOCTOR")
@FieldsComparison(smallerField = "startTime", biggerField = "endTime", message = "End time must be after start time")
@JsonIdentityInfo(generator = ObjectIdGenerators.PropertyGenerator.class, property = "id")
public class Doctor extends User {
    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (o == null || getClass() != o.getClass())
            return false;
        Doctor doctor = (Doctor) o;
        return Objects.equals(getId(), doctor.getId());
    }

    @Override
    public int hashCode() {
        return Objects.hash(getId());
    }

    @NotNull(message = "Must not be null")
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private City city;

    @NotBlank(message = "Must be not null")
    @Size(min = 5, message = "Street address is too short")
    @Column(nullable = false)
    private String street;

    @NotNull(message = "Must not be null")
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private DoctorSpeciality doctorSpeciality;

    @NotBlank(message = "Must be not null")
    @Size(min = 25, max = 500, message = "Information must be between 25 and 500 characters")
    @Column(nullable = false, columnDefinition = "TEXT")
    private String info;

    @NotNull(message = "Must not be null")
    @Positive(message = "Must be positive")
    @Column(nullable = false)
    private Integer patientNumber;

    @NotNull(message = "Must not be null")
    @JsonFormat(pattern = "HH:mm")
    @Column(nullable = false)
    private LocalTime startTime;

    @NotNull(message = "Must not be null")
    @JsonFormat(pattern = "HH:mm")
    @Column(nullable = false)
    private LocalTime endTime;

    @NotNull(message = "Must not be null")
    @Positive(message = "Must be positive")
    @Column(nullable = false)
    private Double consultationFee;

    @NotNull(message = "Must not be null")
    @Size(max = 7, message = "No more than 7 days")
    @NoDuplicates
    @ElementCollection(targetClass = Day.class)
    @Enumerated(EnumType.STRING)
    @CollectionTable(name = "doctor_available_days", joinColumns = @JoinColumn(name = "doctor_id"))
    @Column(name = "day", nullable = false)
    private List<@NotNull(message = "Must not be null") Day> availableDays;

    @OneToMany(mappedBy = "doctor", cascade = { CascadeType.PERSIST, CascadeType.MERGE }, orphanRemoval = true)
    private List<Appointment> appointments;

    @ManyToMany
    @JoinTable(name = "doctor_medical_records", joinColumns = @JoinColumn(name = "doctor_id"), inverseJoinColumns = @JoinColumn(name = "medical_record_id"))
    private List<MedicalRecord> accessibleMedicalRecords;

    @OneToMany(mappedBy = "doctor", cascade = { CascadeType.PERSIST, CascadeType.MERGE }, orphanRemoval = true)
    private List<MedicalRecord> medicalRecords;

    @Override
    public Role getRole() {
        return Role.DOCTOR;
    }

    @Override
    public String toString() {
        return "Doctor(" +
                "city=" + city +
                ", street=" + street +
                ", doctorSpeciality=" + doctorSpeciality +
                ", info=" + info +
                ", patientNumber=" + patientNumber +
                ", startTime=" + startTime +
                ", endTime=" + endTime +
                ", consultationFee=" + consultationFee +
                ", availableDays=" + availableDays +
                ", appointmentsCount=" + (appointments != null ? appointments.size() : 0) +
                ", medicalRecordsCount=" + (medicalRecords != null ? medicalRecords.size() : 0) +
                ", " + super.toString() +
                ")";
    }
}
