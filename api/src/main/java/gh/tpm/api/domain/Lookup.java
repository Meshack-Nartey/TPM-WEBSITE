package gh.tpm.api.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

/**
 * A reference-list value — departments, fellowships, meeting types.
 *
 * <p>These live in the database rather than in an enum because the office adds
 * to them without a deploy.
 */
@Entity
@Table(name = "lookups")
@Getter
@Setter
public class Lookup extends BaseEntity {

    @Column(nullable = false, length = 60)
    private String category;

    @Column(nullable = false, length = 120)
    private String value;

    @Column(name = "sort_order", nullable = false)
    private int sortOrder;

    @Column(nullable = false)
    private boolean active = true;
}
