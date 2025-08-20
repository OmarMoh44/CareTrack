package org.example.backend.repository;

import org.example.backend.model.City;
import org.example.backend.model.Doctor;
import org.example.backend.model.DoctorSpeciality;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;


@Repository
public interface DoctorRepository extends JpaRepository<Doctor, Long> {
    Page<Doctor> findByCityAndDoctorSpeciality
            (City city, DoctorSpeciality doctorSpeciality, Pageable pageable);
}
