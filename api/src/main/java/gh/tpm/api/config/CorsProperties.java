package gh.tpm.api.config;

import java.util.List;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Browser origins allowed to call the API.
 *
 * <p>Only the website needs this. The Flutter app is not a browser origin and
 * is unaffected by CORS.
 */
@ConfigurationProperties(prefix = "tpm.cors")
public record CorsProperties(List<String> allowedOrigins) {

    public CorsProperties {
        allowedOrigins = allowedOrigins == null ? List.of() : List.copyOf(allowedOrigins);
    }
}
