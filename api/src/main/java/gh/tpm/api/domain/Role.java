package gh.tpm.api.domain;

/**
 * What a signed-in account may do.
 *
 * <p>The three roles map onto the two surfaces in the design: {@code MEMBER}
 * sees only the light member app, while {@code LEADER} and {@code ADMIN} may
 * additionally cross into the portal. A leader is scoped to their own branch;
 * an admin sees every branch.
 */
public enum Role {
    MEMBER,
    LEADER,
    ADMIN;

    /** Spring Security expects authorities to carry the {@code ROLE_} prefix. */
    public String authority() {
        return "ROLE_" + name();
    }

    public boolean canEnterPortal() {
        return this == LEADER || this == ADMIN;
    }

    /** Admins are the only role whose reach is church-wide. */
    public boolean isChurchWide() {
        return this == ADMIN;
    }
}
