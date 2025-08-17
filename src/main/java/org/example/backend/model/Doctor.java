package org.example.backend.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalTime;
import java.util.List;

@AllArgsConstructor
@NoArgsConstructor
@Setter
@Getter
@Entity
@Table(name = "doctors")
@DiscriminatorValue("DOCTOR")
public class Doctor extends User {
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private City city;

    @Column(nullable = false)
    private String street;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private DoctorSpeciality doctorSpeciality;

    @Column(nullable = false)
    private String info;

    @Column(nullable = false)
    private Long patientNumber;

    @Temporal(TemporalType.TIME)
    @Column(nullable = false)
    private LocalTime startTime;

    @Temporal(TemporalType.TIME)
    @Column(nullable = false)
    private LocalTime endTime;

    @Column(nullable = false)
    private Double consultationFee;

    @ElementCollection
    @Enumerated(EnumType.STRING)
    private List<Day> availableDays;

    @OneToMany(mappedBy = "doctor")
    private List<Appointment> appointments;

    @OneToMany(mappedBy = "doctor")
    private List<MedicalRecord> medicalRecords;

    @Override
    public Role getRole() {
        return Role.DOCTOR;
    }

    @Override
    public String toString() {
        String var10000 = String.valueOf(this.getCity());
        return "Doctor(city=" + var10000 + ", street=" + this.getStreet() +
                ", doctorSpeciality=" + String.valueOf(this.getDoctorSpeciality()) +
                ", info=" + this.getInfo() + ", patientNumber=" + this.getPatientNumber() +
                ", startTime=" + String.valueOf(this.getStartTime()) + ", endTime=" + String.valueOf(this.getEndTime()) +
                ", consultationFee=" + this.getConsultationFee() + ", availableDays=" +
                String.valueOf(this.getAvailableDays()) + ", appointments=" +
                String.valueOf(this.getAppointments()) + ", medicalRecords=" +
                String.valueOf(this.getMedicalRecords()) + ", " + super.toString() + ")";
    }
}
