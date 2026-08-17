package gh.tpm.api.domain;

import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.MappedSuperclass;
import lombok.Getter;
import lombok.Setter;

/**
 * Identity shared by every table.
 *
 * <p>Hibernate assigns the UUID when the entity is persisted, which saves a
 * round-trip to read a database-generated key back. The columns also default to
 * {@code gen_random_uuid()}, so rows inserted by a migration or a psql session
 * get one too — both paths produce the same kind of id.
 *
 * <p>Equality is by id and null-safe for unsaved instances, and hashCode is
 * constant across a save so an entity stays findable in a set it was added to
 * before being persisted.
 */
@MappedSuperclass
@Getter
@Setter
public abstract class BaseEntity {

    @Id
    @GeneratedValue
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @Override
    public boolean equals(Object other) {
        if (this == other) {
            return true;
        }
        if (!(other instanceof BaseEntity that) || !getClass().equals(other.getClass())) {
            return false;
        }
        // Two unsaved entities are only equal if they are the same instance,
        // which the identity check above already covered.
        return id != null && id.equals(that.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }
}
