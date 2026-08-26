package gh.tpm.api.domain;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

/**
 * An entry in the public leadership directory.
 *
 * <p>Separate from {@link User}: this is presentation copy for the website and
 * the app, and most people listed here have no portal account.
 */
@Entity
@Table(name = "leaders")
@Getter
@Setter
public class Leader extends BaseEntity {

    @Column(nullable = false, length = 160)
    private String name;

    @Column(length = 160)
    private String title;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "branch_id")
    private Branch branch;

    @Column(length = 120)
    private String fellowship;

    @Column(columnDefinition = "text")
    private String quote;

    @Column(columnDefinition = "text")
    private String bio;

    /** Postgres text[]; Hibernate needs the array type spelled out. */
    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(columnDefinition = "text[]", nullable = false)
    private List<String> highlights = new ArrayList<>();

    @Column(name = "photo_url", length = 500)
    private String photoUrl;

    @Column(length = 160)
    private String email;

    @Column(length = 40)
    private String phone;

    @Column(nullable = false)
    private boolean active = true;

    @Column(name = "sort_order", nullable = false)
    private int sortOrder;

    @Column(name = "created_at", insertable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at", insertable = false, updatable = false)
    private Instant updatedAt;
}
