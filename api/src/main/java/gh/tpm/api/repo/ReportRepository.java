package gh.tpm.api.repo;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import gh.tpm.api.domain.Report;

public interface ReportRepository extends JpaRepository<Report, UUID> {

    /**
     * Guards the offline queue: a report that syncs twice must update, not
     * insert a second row. Mirrors the unique constraint in V1.
     */
    Optional<Report> findByBranchIdAndMeetingTypeAndServiceDate(
            UUID branchId, String meetingType, LocalDate serviceDate);

    @Query("""
            select r from Report r
            join fetch r.branch
            where (:branchId is null or r.branch.id = :branchId)
              and (cast(:from as date) is null or r.serviceDate >= :from)
              and (cast(:to as date) is null or r.serviceDate <= :to)
            order by r.serviceDate desc
            """)
    List<Report> findForScope(@Param("branchId") UUID branchId,
                              @Param("from") LocalDate from,
                              @Param("to") LocalDate to);
}
