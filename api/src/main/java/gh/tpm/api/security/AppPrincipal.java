package gh.tpm.api.security;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import gh.tpm.api.domain.Role;
import gh.tpm.api.domain.User;

/**
 * The signed-in user, as the rest of the application sees them.
 *
 * <p>Carries the branch id because almost every authorisation question in this
 * system is "your branch or not?", and answering it should not require another
 * trip to the database.
 */
public record AppPrincipal(UUID id, String email, Role role, UUID branchId, boolean active)
        implements UserDetails {

    public static AppPrincipal from(User user) {
        return new AppPrincipal(
                user.getId(),
                user.getEmail(),
                user.getRole(),
                user.getBranch() == null ? null : user.getBranch().getId(),
                user.isActive());
    }

    /**
     * Which branch this principal may read. Admins are church-wide, so they get
     * null, which every scoped query treats as "no filter".
     */
    public UUID scopedBranchId() {
        return role.isChurchWide() ? null : branchId;
    }

    public boolean canReachBranch(UUID target) {
        return role.isChurchWide() || (branchId != null && branchId.equals(target));
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority(role.authority()));
    }

    /** Never leaves the database; authentication happens before this is built. */
    @Override
    public String getPassword() {
        return null;
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public boolean isEnabled() {
        return active;
    }
}
