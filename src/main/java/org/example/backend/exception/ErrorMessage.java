package org.example.backend.exception;

import lombok.Getter;

@Getter
public enum ErrorMessage {
    JWT_ERROR("Unauthorized access. Login again."),
    USER_NOT_FOUND("User not found."),
    USER_EXIT("User is already exist");


    private String message;

    ErrorMessage(String message) {
        this.message = message;
    }
}
