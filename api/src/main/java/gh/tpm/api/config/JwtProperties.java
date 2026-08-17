package gh.tpm.api.config;

import java.time.Duration;

import org.springframework.boot.context.properties.ConfigurationProperties;

import jakarta.validation.constraints.NotBlank;

/**
 * JWT signing configuration.
 *
 * <p>The secret is required and validated at startup: a token signed with a
 * weak or absent key is worse than no authentication, because it looks like it
 * works.
 */
@ConfigurationProperties(prefix = "tpm.jwt")
public record JwtProperties(
        @NotBlank String secret,
        String issuer,
        Duration expiry) {

    public JwtProperties {
        if (issuer == null || issuer.isBlank()) {
            issuer = "tpm-api";
        }
        if (expiry == null) {
            expiry = Duration.ofHours(12);
        }
        // HS256 needs at least 256 bits of key material. Anything shorter is
        // rejected by the library at signing time — fail at boot instead.
        if (secret != null && secret.getBytes().length < 32) {
            throw new IllegalStateException(
                    "tpm.jwt.secret must be at least 32 bytes; generate one with "
                            + "`openssl rand -base64 48`");
        }
    }
}
