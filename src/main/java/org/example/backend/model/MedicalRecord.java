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
@Table(name = "medical_records")
public class MedicalRecord {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String content;

    @Column(nullable = false)
    @Temporal(TemporalType.DATE)
    private LocalDate date;

    // The doctor who created the record (optional, can be null if not needed)
    @ManyToOne
    @JoinColumn(name = "doctor_id")
    private Doctor creatorDoctor;

    // Doctors who have access to this record
    @ManyToMany(mappedBy = "accessibleMedicalRecords")
    private List<Doctor> sharedWithDoctors;

    @ManyToOne
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;
}
