package org.example.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class CorsConfig {
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/**")
                        .allowedOrigins(
                            "http://localhost:5174",  // Flutter web dev server
                            "http://localhost:5000",  // Flutter web alternative port
                            "http://localhost:8080",  // Flutter web alternative port
                            "capacitor://localhost",  // For mobile web view
                            "http://localhost"        // Generic localhost
                        )
                        .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH", "HEAD")
                        .allowedHeaders(
                            "Authorization",
                            "Content-Type", 
                            "Origin",
                            "Accept", 
                            "X-Requested-With",
                            "Access-Control-Request-Method",
                            "Access-Control-Request-Headers",
                            "Access-Control-Allow-Origin"
                        )
                        .exposedHeaders(
                            "Authorization",
                            "Access-Control-Allow-Origin",
                            "Access-Control-Allow-Credentials"
                        )
                        .allowCredentials(true)
                        .maxAge(3600); // Cache preflight requests for 1 hour
            }
        };
    }
}
