package gh.tpm.api.repo;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import gh.tpm.api.domain.MediaItem;
import gh.tpm.api.domain.MediaKind;

public interface MediaItemRepository extends JpaRepository<MediaItem, UUID> {

    /** A null kind is the library's "All" filter. */
    @Query("""
            select m from MediaItem m
            where m.active = true
              and (:kind is null or m.kind = :kind)
            order by m.publishedAt desc
            """)
    List<MediaItem> findLibrary(@Param("kind") MediaKind kind);
}
