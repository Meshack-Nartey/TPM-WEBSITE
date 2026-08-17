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
 * A member asking for one of their own fields to be changed.
 *
 * <p>Members do not own their record — the office does — so an edit is a
 * request, and this row is what the admin approvals queue displays.
 */
@Entity
@Table(name = "profile_requests")
@Getter
@Setter
public class ProfileRequest extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "field_name", nullable = false, length = 60)
    private String fieldName;

    /** Captured when the request is raised, so the queue can show old → new. */
    @Column(name = "old_value", length = 255)
    private String oldValue;

    @Column(name = "new_value", nullable = false, length = 255)
    private String newValue;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 16)
    private RequestStatus status = RequestStatus.PENDING;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reviewed_by_id")
    private User reviewedBy;

    @Column(name = "reviewed_at")
    private Instant reviewedAt;

    @Column(name = "created_at", insertable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at", insertable = false, updatable = false)
    private Instant updatedAt;
}
