package org.example.backend.validator;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

import java.util.Arrays;

public class EnumValidator implements ConstraintValidator<EnumValue, Object> {
    private Class<? extends Enum<?>> enumClass;

    @Override
    public void initialize(EnumValue constraintAnnotation) {
        this.enumClass = constraintAnnotation.enumClass();
    }

    @Override
    public boolean isValid(Object value, ConstraintValidatorContext context) {
        if (value == null) return true;

        if (value instanceof String strVal) {
            return Arrays.stream(enumClass.getEnumConstants())
                    .anyMatch(e -> e.name().equalsIgnoreCase(strVal));
        } else if (value.getClass().isEnum()) {
            return Arrays.stream(enumClass.getEnumConstants())
                    .anyMatch(e -> e.equals(value));
        }

        return false;
    }
}


