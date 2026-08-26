package gh.tpm.api.repo;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import gh.tpm.api.domain.Announcement;

public interface AnnouncementRepository extends JpaRepository<Announcement, UUID> {

    /**
     * A member's feed: everything addressed to all branches, plus anything
     * addressed to theirs. A null branchId (guest, or an admin browsing) sees
     * only the church-wide posts.
     */
    @Query("""
            select a from Announcement a
            where a.active = true
              and (a.branch is null or a.branch.id = :branchId)
            order by a.sortOrder asc, a.publishedAt desc
            """)
    List<Announcement> findFeedForBranch(@Param("branchId") UUID branchId);
}
