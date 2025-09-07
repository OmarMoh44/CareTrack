package org.example.backend.jwt;

import jakarta.persistence.EntityNotFoundException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.example.backend.exception.ErrorMessage;
import org.example.backend.model.User;
import org.example.backend.repository.UserRepository;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
@RequiredArgsConstructor
public class JwtFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final UserRepository userRepository;

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getServletPath();
        // paths of requests that are permitAll in security config
        // these paths do not require authentication
        return path.startsWith("/login")
                || path.startsWith("/register")
                || path.equals("/forget-password")
                || path.startsWith("/swagger-ui")
                || path.equals("/swagger-ui.html")
                || path.startsWith("/v3/api-docs")
                || path.startsWith("/swagger-resources")
                || path.startsWith("/webjars");
    }

    // the filter’s purpose is to authenticate the request before it reaches your controllers.
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        String token = null;
        Long id = null;

        if (request.getCookies() != null) {
            for (Cookie cookie : request.getCookies()) {
                if ("token".equals(cookie.getName())) {
                    token = cookie.getValue();
                    break;
                }
            }
        }

        if (token == null) {
            String authHeader = request.getHeader("Authorization");
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                token = authHeader.substring(7);
            }
        }

        if (token != null) {
            id = jwtService.extractId(token);
        }
        // check if id is extracted and the user is not yet authenticated and set in the security context
        if (id != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            User user = userRepository.findById(id).orElseThrow(
                    () -> new EntityNotFoundException(ErrorMessage.USER_NOT_FOUND.getMessage())
            );

            if (jwtService.validateToken(token, user)) {
                // create an authentication object using the user's details and set it in the security context
                // as, controller methods can use @AuthenticationPrincipal to access the authenticated user in authentication object in the security context
                // and @PreAuthorize can use it for authorization
                UsernamePasswordAuthenticationToken authenticationToken =
                        // principal is an object of the authenticated user
                        new UsernamePasswordAuthenticationToken(user, null, user.getAuthorities());
                authenticationToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authenticationToken);
            }
        }

        filterChain.doFilter(request, response);
    }
}
