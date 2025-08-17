package org.example.backend.validator;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import java.util.HashSet;
import java.util.List;

public class NoDuplicatesValidator implements ConstraintValidator<NoDuplicates, List<?>> {

    @Override
    public boolean isValid(List<?> value, ConstraintValidatorContext context) {
        if (value == null) {
            return true; // Null values are considered valid
        }
        return value.size() == new HashSet<>(value).size(); // Check for duplicates
    }
}
