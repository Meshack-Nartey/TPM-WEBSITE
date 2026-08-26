package gh.tpm.api.security;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.UUID;

import org.junit.jupiter.api.Test;

import gh.tpm.api.domain.Role;

class AppPrincipalTest {

    private static final UUID KUMASI = UUID.randomUUID();
    private static final UUID ACCRA = UUID.randomUUID();

    private static AppPrincipal principal(Role role, UUID branchId) {
        return new AppPrincipal(UUID.randomUUID(), "user@example.com", role, branchId, true);
    }

    @Test
    void aLeaderIsScopedToTheirOwnBranch() {
        AppPrincipal leader = principal(Role.LEADER, KUMASI);

        assertThat(leader.scopedBranchId()).isEqualTo(KUMASI);
        assertThat(leader.canReachBranch(KUMASI)).isTrue();
        assertThat(leader.canReachBranch(ACCRA)).isFalse();
    }

    @Test
    void anAdminIsChurchWide() {
        AppPrincipal admin = principal(Role.ADMIN, null);

        // Null means "no branch filter" to every scoped query.
        assertThat(admin.scopedBranchId()).isNull();
        assertThat(admin.canReachBranch(KUMASI)).isTrue();
        assertThat(admin.canReachBranch(ACCRA)).isTrue();
    }

    @Test
    void aMemberWithoutABranchReachesNothing() {
        AppPrincipal member = principal(Role.MEMBER, null);

        assertThat(member.canReachBranch(KUMASI)).isFalse();
    }

    @Test
    void authoritiesCarryTheRolePrefix() {
        assertThat(principal(Role.LEADER, KUMASI).getAuthorities())
                .extracting(Object::toString)
                .containsExactly("ROLE_LEADER");
    }

    @Test
    void onlyLeadersAndAdminsMayEnterThePortal() {
        assertThat(Role.MEMBER.canEnterPortal()).isFalse();
        assertThat(Role.LEADER.canEnterPortal()).isTrue();
        assertThat(Role.ADMIN.canEnterPortal()).isTrue();
        assertThat(Role.LEADER.isChurchWide()).isFalse();
        assertThat(Role.ADMIN.isChurchWide()).isTrue();
    }

    @Test
    void aDeactivatedAccountIsDisabled() {
        var disabled = new AppPrincipal(UUID.randomUUID(), "x@y.z", Role.MEMBER, null, false);

        assertThat(disabled.isEnabled()).isFalse();
    }
}
