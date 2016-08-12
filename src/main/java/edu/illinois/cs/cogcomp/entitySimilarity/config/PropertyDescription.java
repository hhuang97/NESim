package edu.illinois.cs.cogcomp.entitySimilarity.config;

import java.lang.annotation.*;

@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface PropertyDescription {
    String purpose();

    String defaultValue();

    String[] options() default "";
}
