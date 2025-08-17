package org.example.backend.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.*;
import lombok.experimental.SuperBuilder;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.*;

@AllArgsConstructor
@NoArgsConstructor
@Setter
@Getter
@ToString(exclude = {"password"})
@SuperBuilder
@Entity
@Table(name = "users")
@Inheritance(strategy = InheritanceType.JOINED)
@DiscriminatorColumn(name = "type", discriminatorType = DiscriminatorType.STRING)
@DiscriminatorValue("USER")
public class User implements UserDetails {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    protected Long id;

    @NotBlank(message = "Must be not null")
    @Size(min = 7, max = 50, message = "Full name must be between 7 and 50 characters")
    @Column(nullable = false)
    protected String fullName;

    @NotBlank(message = "Must be not null")
    @Pattern(
            regexp = "^[^\\s@]+@(gmail|yahoo|hotmail|outlook)\\.(com|net|org)$",
            message = "Must be in email format"
    )
    @Column(nullable = false, unique = true)
    protected String email;

    @NotBlank(message = "Must be not null")
    @Size(min = 6, message = "Password must be more than 5 characters")
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    @Column(nullable = false)
    protected String password;

    @NotBlank(message = "Must be not null")
    @Size(min = 11, max = 11, message = "Phone number must be 11 number")
    @Pattern(regexp = "^(010|011|012|015)\\d{8}$", message = "Invalid phone number")
    @Column(nullable = false, length = 11, unique = true)
    protected String phoneNumber;

    public Role getRole() {
        return Role.USER;
    }

//    public Map<String, Method> getMethodMap() throws NoSuchMethodException{
//        Map<String, Method> methodMap = new HashMap<>();
//        methodMap.put("fullName", this.getClass().getMethod("setFullName", String.class));
//        methodMap.put("email", this.getClass().getMethod("setEmail", String.class));
//        methodMap.put("password", this.getClass().getMethod("setPassword", String.class));
//        methodMap.put("phoneNumber", this.getClass().getMethod("setPhoneNumber", String.class));
//        return methodMap;
//    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return Collections.singleton(() -> getRole().name());
    }

    @Override
    public String getUsername() {
        return this.email;
    }

    @Override
    public boolean isAccountNonExpired() { return true; }

    @Override
    public boolean isAccountNonLocked() { return true; }

    @Override
    public boolean isCredentialsNonExpired() { return true; }

    @Override
    public boolean isEnabled() { return true; }
}
