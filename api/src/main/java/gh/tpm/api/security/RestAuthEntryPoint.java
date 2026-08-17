package gh.tpm.api.security;

import java.io.IOException;
import java.time.Instant;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Answers unauthenticated requests with 401, not Spring's default 403.
 *
 * <p>The distinction matters to the apps: 401 means "your token is missing or
 * expired, sign in again", while 403 means "you are signed in and this is not
 * yours". Collapsing both into 403 would send a member with an expired token to
 * an error screen instead of the login screen.
 */
@Component
public class RestAuthEntryPoint implements AuthenticationEntryPoint {

    @Override
    public void commence(HttpServletRequest request,
                         HttpServletResponse response,
                         AuthenticationException authException) throws IOException {

        response.setStatus(HttpStatus.UNAUTHORIZED.value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.getWriter().write("""
                {"timestamp":"%s","status":401,"error":"Unauthorized",\
                "message":"Sign in to continue"}"""
                .formatted(Instant.now()));
    }
}
