package org.example.backend.exception;

import lombok.Getter;

@Getter
public enum ErrorMessage {
    JWT_ERROR("Unauthorized access. Login again."),
    USER_NOT_FOUND("User not found."),
    USER_EXIT("User is already exist"),
    DOCTOR_NOT_AVAILABLE("Doctor is not available on this day."),
    DOCTOR_CAPACITY_FULL("Doctor has reached maximum patient capacity for this date."),
    APPOINTMENT_EXISTS("Appointment already exists for this doctor on this date."),
    APPOINTMENT_NOT_FOUND("Appointment not found."),
    APPOINTMENT_PAST("Cannot modify or cancel past appointments.");

    private String message;

    ErrorMessage(String message) {
        this.message = message;
    }
}
