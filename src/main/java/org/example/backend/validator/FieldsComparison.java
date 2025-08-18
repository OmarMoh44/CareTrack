package org.example.backend.validator;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Constraint(validatedBy = FieldsComparisonValidator.class)
@Target({ ElementType.TYPE })
@Retention(RetentionPolicy.RUNTIME)
public @interface FieldsComparison {
    String message();
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};

    String smallerField();  // field name in annotated object that is supposed to be smaller value
    String biggerField();   // field name in annotated object that is supposed to be bigger value
}