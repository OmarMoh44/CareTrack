package org.example.backend.validator;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Constraint(validatedBy = NoDuplicatesValidator.class)
@Target({ ElementType.FIELD, ElementType.METHOD })
@Retention(RetentionPolicy.RUNTIME)
public @interface NoDuplicates {
    String message() default "List contains duplicate values";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}
