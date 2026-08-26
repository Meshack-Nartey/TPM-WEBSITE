package gh.tpm.api.domain;

import java.time.Instant;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

/** A sermon, teaching or podcast episode in the media library. */
@Entity
@Table(name = "media_items")
@Getter
@Setter
public class MediaItem extends BaseEntity {

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private MediaKind kind;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(length = 120)
    private String speaker;

    @Column(length = 120)
    private String scripture;

    @Column(name = "duration_seconds")
    private Integer durationSeconds;

    @Column(name = "audio_url", length = 500)
    private String audioUrl;

    @Column(name = "video_url", length = 500)
    private String videoUrl;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(name = "published_at", nullable = false)
    private Instant publishedAt = Instant.now();

    /** Some content is stream-only; the app hides the download affordance then. */
    @Column(nullable = false)
    private boolean downloadable = true;

    @Column(nullable = false)
    private boolean active = true;

    @Column(name = "created_at", insertable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at", insertable = false, updatable = false)
    private Instant updatedAt;
}
