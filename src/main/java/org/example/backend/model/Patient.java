package org.example.backend.model;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.util.List;

@AllArgsConstructor
@NoArgsConstructor
@Setter
@Getter
@SuperBuilder
@Entity
@Table(name = "patients")
@DiscriminatorValue("PATIENT")
public class Patient extends User {

    @OneToMany(mappedBy = "patient", cascade = {CascadeType.PERSIST, CascadeType.MERGE}, orphanRemoval = true)
    private List<Appointment> appointments;

    @OneToMany(mappedBy = "patient", cascade = {CascadeType.PERSIST, CascadeType.MERGE}, orphanRemoval = true)
    private List<MedicalRecord> medicalRecords;

    @Override
    public Role getRole() {
        return Role.PATIENT;
    }

    @Override
    public String toString() {
        return "Patient(" +
                "appointmentsCount=" + (appointments != null ? appointments.size() : 0) +
                ", medicalRecordsCount=" + (medicalRecords != null ? medicalRecords.size() : 0) +
                ", " + super.toString() +
                ")";
    }
}
