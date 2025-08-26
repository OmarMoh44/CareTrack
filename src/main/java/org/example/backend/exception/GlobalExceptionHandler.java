package org.example.backend.exception;

import com.fasterxml.jackson.databind.exc.InvalidFormatException;
import io.jsonwebtoken.JwtException;
import jakarta.persistence.EntityExistsException;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.ConstraintViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {
    // Validation errors (fired by @Valid)
    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleNotValidException(MethodArgumentNotValidException ex) {
        String errorMessage = ex.getBindingResult().getFieldErrors().stream() // Process field-level errors
                .findFirst()
                .map(error -> error.getDefaultMessage())
                .orElseGet(() -> ex.getBindingResult().getGlobalErrors().stream() // Process class-level (global) errors
                        .findFirst()
                        .map(error -> error.getDefaultMessage())
                        .orElse("Validation error occurred"));
        // return only message of first error
        return new ErrorResponse(errorMessage, HttpStatus.BAD_REQUEST.value());
    }

    // Validation errors (fired by validator.validate())
    @ExceptionHandler(ConstraintViolationException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleConstraintViolation(ConstraintViolationException ex) {
        String errorMessage = ex.getConstraintViolations().stream()
                .findFirst()
                .map(violation -> violation.getMessage())
                .orElse("Validation error occurred");
        // return only message of first error
        return new ErrorResponse(errorMessage, HttpStatus.BAD_REQUEST.value());
    }

    // Jackson deserialization errors when using ObjectMapper
    @ExceptionHandler(InvalidFormatException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleInvalidFormatException(InvalidFormatException ex) {
        String targetType = ex.getTargetType().getSimpleName();
        String value = ex.getValue() != null ? ex.getValue().toString() : "null";
        String message = String.format(
                "Invalid value '%s'. Expected type: %s.",
                value, targetType
        );
        return new ErrorResponse(message, HttpStatus.BAD_REQUEST.value());
    }

    // JSON parsing errors when parsing request body
    @ExceptionHandler(HttpMessageNotReadableException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleHttpMessageNotReadableException(HttpMessageNotReadableException ex) {
        String message = "Malformed JSON request";
        if (ex.getCause() instanceof InvalidFormatException) {
            InvalidFormatException invalidFormatException = (InvalidFormatException) ex.getCause();
            message = String.format(
                    "Invalid value '%s' for type '%s'.",
                    invalidFormatException.getValue(),
                    invalidFormatException.getTargetType().getSimpleName()
            );
        }
        return new ErrorResponse(message, HttpStatus.BAD_REQUEST.value());
    }

    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleIllegalArgumentException(IllegalArgumentException ex){
        return new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST.value());
    }

    // JPA entity already exists
    @ExceptionHandler(EntityExistsException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleEntityExistsException(EntityExistsException ex) {
        return new ErrorResponse(ex.getMessage(), HttpStatus.BAD_REQUEST.value());
    }

    // Wrong email/password
    @ExceptionHandler(BadCredentialsException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleBadCredentialsException(BadCredentialsException ex) {
        return new ErrorResponse("Email or password is not correct", HttpStatus.BAD_REQUEST.value());
    }

    // JWT errors (expired, invalid signature, malformed, etc.)
    @ExceptionHandler(JwtException.class)
    @ResponseStatus(HttpStatus.UNAUTHORIZED)
    public ErrorResponse handleJwtException(JwtException jwtException) {
        System.out.println(jwtException.getMessage());
        return new ErrorResponse(jwtException.getMessage(), HttpStatus.UNAUTHORIZED.value());
    }

    // Forbidden (user authenticated but lacks authority/role)
    @ExceptionHandler(AccessDeniedException.class)
    @ResponseStatus(HttpStatus.FORBIDDEN)
    public ErrorResponse handleAccessDeniedException(AccessDeniedException ex) {
        return new ErrorResponse("Access is denied", HttpStatus.FORBIDDEN.value());
    }

    // JPA entity not found
    @ExceptionHandler(EntityNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ErrorResponse handleEntityNotFoundException(EntityNotFoundException ex) {
        return new ErrorResponse(ex.getMessage(), HttpStatus.NOT_FOUND.value());
    }

    // Catch-all handler (fallback)
    @ExceptionHandler(RuntimeException.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ErrorResponse handleRuntimeException(RuntimeException ex) {
        return new ErrorResponse(ex.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR.value());
    }
}
