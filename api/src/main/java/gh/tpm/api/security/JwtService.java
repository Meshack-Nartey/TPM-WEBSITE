package gh.tpm.api.security;

import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import java.util.UUID;

import javax.crypto.SecretKey;

import org.springframework.stereotype.Service;

import gh.tpm.api.config.JwtProperties;
import gh.tpm.api.domain.Role;
import gh.tpm.api.domain.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

/** Issues and verifies the bearer tokens the apps carry. */
@Service
public class JwtService {

    private final JwtProperties properties;
    private final SecretKey key;

    public JwtService(JwtProperties properties) {
        this.properties = properties;
        this.key = Keys.hmacShaKeyFor(properties.secret().getBytes(StandardCharsets.UTF_8));
    }

    public String issue(User user) {
        Instant now = Instant.now();
        var builder = Jwts.builder()
                .subject(user.getId().toString())
                .issuer(properties.issuer())
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plus(properties.expiry())))
                .claim("email", user.getEmail())
                .claim("role", user.getRole().name());

        // Present only for branch-scoped roles, so its absence is meaningful
        // rather than ambiguous.
        if (user.getBranch() != null) {
            builder.claim("branch", user.getBranch().getId().toString());
        }
        return builder.signWith(key).compact();
    }

    /**
     * Verifies signature and expiry and rebuilds the principal from the claims.
     *
     * @return the principal, or null if the token is missing, malformed,
     *         expired or signed with the wrong key — all of which mean the same
     *         thing to a caller, so none of them are distinguished.
     */
    public AppPrincipal verify(String token) {
        if (token == null || token.isBlank()) {
            return null;
        }
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(key)
                    .requireIssuer(properties.issuer())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();

            String branch = claims.get("branch", String.class);
            return new AppPrincipal(
                    UUID.fromString(claims.getSubject()),
                    claims.get("email", String.class),
                    Role.valueOf(claims.get("role", String.class)),
                    branch == null ? null : UUID.fromString(branch),
                    true);
        } catch (JwtException | IllegalArgumentException e) {
            return null;
        }
    }
}
