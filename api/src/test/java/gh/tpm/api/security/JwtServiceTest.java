package gh.tpm.api.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.time.Duration;
import java.util.UUID;

import org.junit.jupiter.api.Test;

import gh.tpm.api.config.JwtProperties;
import gh.tpm.api.domain.Branch;
import gh.tpm.api.domain.Role;
import gh.tpm.api.domain.User;

class JwtServiceTest {

    private static final String SECRET = "a-test-signing-secret-that-is-long-enough-32";

    private final JwtService jwt = new JwtService(
            new JwtProperties(SECRET, "tpm-api", Duration.ofHours(12)));

    private static User user(Role role, UUID branchId) {
        var user = new User();
        user.setId(UUID.randomUUID());
        user.setFirstName("Ama");
        user.setLastName("Boateng");
        user.setEmail("ama@example.com");
        user.setRole(role);
        if (branchId != null) {
            var branch = new Branch();
            branch.setId(branchId);
            branch.setName("Kumasi Central");
            user.setBranch(branch);
        }
        return user;
    }

    @Test
    void roundTripsIdentityRoleAndBranch() {
        UUID branchId = UUID.randomUUID();
        User leader = user(Role.LEADER, branchId);

        AppPrincipal principal = jwt.verify(jwt.issue(leader));

        assertThat(principal).isNotNull();
        assertThat(principal.id()).isEqualTo(leader.getId());
        assertThat(principal.email()).isEqualTo("ama@example.com");
        assertThat(principal.role()).isEqualTo(Role.LEADER);
        assertThat(principal.branchId()).isEqualTo(branchId);
    }

    @Test
    void omitsBranchClaimWhenTheAccountHasNoBranch() {
        AppPrincipal principal = jwt.verify(jwt.issue(user(Role.ADMIN, null)));

        assertThat(principal.branchId()).isNull();
    }

    @Test
    void rejectsATokenSignedWithADifferentKey() {
        var other = new JwtService(
                new JwtProperties("a-completely-different-secret-key-32-bytes", "tpm-api", null));

        String forged = other.issue(user(Role.ADMIN, null));

        assertThat(jwt.verify(forged)).isNull();
    }

    @Test
    void rejectsExpiredMalformedAndMissingTokens() {
        var expired = new JwtService(
                new JwtProperties(SECRET, "tpm-api", Duration.ofSeconds(-1)));

        assertThat(jwt.verify(expired.issue(user(Role.MEMBER, null)))).isNull();
        assertThat(jwt.verify("not-a-jwt")).isNull();
        assertThat(jwt.verify("")).isNull();
        assertThat(jwt.verify(null)).isNull();
    }

    @Test
    void rejectsATokenFromAnotherIssuer() {
        var foreign = new JwtService(new JwtProperties(SECRET, "somebody-else", null));

        assertThat(jwt.verify(foreign.issue(user(Role.ADMIN, null)))).isNull();
    }

    @Test
    void refusesToStartWithAShortSecret() {
        assertThatThrownBy(() -> new JwtProperties("too-short", "tpm-api", null))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("at least 32 bytes");
    }
}
