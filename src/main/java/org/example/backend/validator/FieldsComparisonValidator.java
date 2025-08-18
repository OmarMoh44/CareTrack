package org.example.backend.validator;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

import java.lang.reflect.Field;

public class FieldsComparisonValidator implements ConstraintValidator<FieldsComparison, Object> {
    private String smallerField; // field name in annotated object that represents smaller value
    private String biggerField;  // field name in annotated object that represents bigger value

    @Override
    public void initialize(FieldsComparison constraintAnnotation) {
        this.smallerField = constraintAnnotation.smallerField();
        this.biggerField = constraintAnnotation.biggerField();
    }

    @Override
    public boolean isValid(Object value, ConstraintValidatorContext context) {
        try {
            Field startField = value.getClass().getDeclaredField(smallerField);
            Field endField = value.getClass().getDeclaredField(biggerField);

            startField.setAccessible(true); // bypass private access
            endField.setAccessible(true);   // bypass private access

            Object startValue = startField.get(value);
            Object endValue = endField.get(value);

            if (startValue == null || endValue == null) {
                return true; // Null values are considered valid
            }

            if (startValue instanceof Comparable && endValue instanceof Comparable) {
                Comparable<Object> startComparable = (Comparable<Object>) startValue;
                return startComparable.compareTo(endValue) < 0; // Check if startValue < endValue
            }

            return false; // Invalid if fields are not comparable
        } catch (Exception e) {
            return false; // Invalid if reflection fails
        }
    }
}