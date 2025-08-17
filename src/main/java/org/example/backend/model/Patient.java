package org.example.backend.model;

import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.*;

import java.util.List;

@AllArgsConstructor
@NoArgsConstructor
@Setter
@Getter
@Entity
@Table(name = "patients")
@DiscriminatorValue("PATIENT")
public class Patient extends User {
    @OneToMany(mappedBy = "patient")
    private List<Appointment> appointments;

    @OneToMany(mappedBy = "patient")
    private List<MedicalRecord> medicalRecords;

    @Override
    public Role getRole() {
        return Role.PATIENT;
    }

    @Override
    public String toString() {
        String var10000 = String.valueOf(this.getAppointments());
        return "Patient(appointments=" + var10000 + ", medicalRecords=" + String.valueOf(this.getMedicalRecords()) +
                " " + super.toString() + ")";
    }
}
