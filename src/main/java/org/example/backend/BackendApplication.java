package org.example.backend;

import org.example.backend.model.User;
import org.example.backend.repository.UserRepository;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.ApplicationContext;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

@SpringBootApplication
@EnableCaching
public class BackendApplication {

    public static void main(String[] args) {
        ApplicationContext applicationContext = SpringApplication.run(BackendApplication.class, args);
    }

}
