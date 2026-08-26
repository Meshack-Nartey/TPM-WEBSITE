package gh.tpm.api.repo;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import gh.tpm.api.domain.Event;

public interface EventRepository extends JpaRepository<Event, UUID> {

    @Query("""
            select e from Event e
            where e.active = true
              and (e.branch is null or e.branch.id = :branchId)
              and coalesce(e.endsAt, e.startsAt) >= :now
            order by e.startsAt asc
            """)
    List<Event> findUpcomingForBranch(@Param("branchId") UUID branchId,
                                      @Param("now") Instant now);
}
