package gh.tpm.api.domain;

import java.time.Instant;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

/**
 * Gates registration at anything above member.
 *
 * <p>Validated server-side only. The previous implementation compared codes in
 * client-side JavaScript, which meant anyone who opened dev tools could grant
 * themselves the portal.
 */
@Entity
@Table(name = "invite_codes")
@Getter
@Setter
public class InviteCode extends BaseEntity {

    @Column(nullable = false, unique = true, length = 80)
    private String code;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 16)
    private Role role;

    /** When set, the code can only grant leadership of this branch. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "branch_id")
    private Branch branch;

    /** Null means unlimited. */
    @Column(name = "max_uses")
    private Integer maxUses;

    @Column(name = "used_count", nullable = false)
    private int usedCount;

    @Column(name = "expires_at")
    private Instant expiresAt;

    @Column(nullable = false)
    private boolean active = true;

    @Column(name = "created_at", insertable = false, updatable = false)
    private Instant createdAt;

    /** A code is only usable if it is active, unexpired and has uses left. */
    public boolean isRedeemable(Instant now) {
        if (!active) {
            return false;
        }
        if (expiresAt != null && !expiresAt.isAfter(now)) {
            return false;
        }
        return maxUses == null || usedCount < maxUses;
    }
}
