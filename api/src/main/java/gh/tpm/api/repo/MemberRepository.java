package gh.tpm.api.repo;

import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import gh.tpm.api.domain.Member;

public interface MemberRepository extends JpaRepository<Member, UUID> {

    /**
     * The registry's search. Branch is applied as a filter rather than baked in
     * so one query serves both a leader (their branch) and an admin (all of
     * them) — passing null for branchId means church-wide.
     */
    @Query("""
            select m from Member m
            where (:branchId is null or m.branch.id = :branchId)
              and (:query is null or lower(m.firstName) like lower(concat('%', :query, '%'))
                                  or lower(m.lastName) like lower(concat('%', :query, '%'))
                                  or lower(coalesce(m.workerGroup, '')) like lower(concat('%', :query, '%')))
            """)
    Page<Member> search(@Param("branchId") UUID branchId,
                        @Param("query") String query,
                        Pageable pageable);

    long countByBranchId(UUID branchId);
}
