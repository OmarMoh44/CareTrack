package org.example.backend.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.List;

@AllArgsConstructor
@NoArgsConstructor
@Setter
@Getter
@ToString
@Entity
@Table(name = "doctors")
public class Doctor extends User {
    @Column(nullable = false)
    private String city;

    @Column(nullable = false)
    private String street;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private DoctorSpeciality doctorSpeciality;

    @Column(nullable = false)
    private String info;

    @Column(nullable = false)
    private Long patientNumber;

    @Temporal(TemporalType.DATE)
    @Column(nullable = false)
    private LocalDate startDate;

    @Temporal(TemporalType.DATE)
    @Column(nullable = false)
    private LocalDate endDate;

    @Column(nullable = false)
    private Double consultationFee;

    @ElementCollection
    @Enumerated(EnumType.STRING)
    private List<Day> availableDays;

    @OneToMany(mappedBy = "doctor")
    private List<Appointment> appointments;

    @ManyToMany
    @JoinTable(name = "doctor_medical_records", joinColumns = @JoinColumn(name = "doctor_id"), inverseJoinColumns = @JoinColumn(name = "medical_record_id"))
    private List<MedicalRecord> accessibleMedicalRecords;
}
