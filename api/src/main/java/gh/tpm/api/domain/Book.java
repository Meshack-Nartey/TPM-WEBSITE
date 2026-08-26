package gh.tpm.api.domain;

import java.time.Instant;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

/** A book or study guide offered in the app. */
@Entity
@Table(name = "books")
@Getter
@Setter
public class Book extends BaseEntity {

    @Column(nullable = false, length = 200)
    private String title;

    @Column(length = 160)
    private String author;

    @Column(columnDefinition = "text")
    private String description;

    @Column(name = "cover_url", length = 500)
    private String coverUrl;

    @Column(name = "file_url", length = 500)
    private String fileUrl;

    @Column(nullable = false)
    private boolean active = true;

    @Column(name = "sort_order", nullable = false)
    private int sortOrder;

    @Column(name = "created_at", insertable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at", insertable = false, updatable = false)
    private Instant updatedAt;
}
