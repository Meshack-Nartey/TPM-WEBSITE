package gh.tpm.api.repo;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import gh.tpm.api.domain.ProfileRequest;
import gh.tpm.api.domain.RequestStatus;

public interface ProfileRequestRepository extends JpaRepository<ProfileRequest, UUID> {

    @Query("""
            select p from ProfileRequest p
            join fetch p.user u
            left join fetch u.branch
            where p.status = :status
            order by p.createdAt asc
            """)
    List<ProfileRequest> findQueue(@Param("status") RequestStatus status);

    List<ProfileRequest> findByUserIdOrderByCreatedAtDesc(UUID userId);

    long countByStatus(RequestStatus status);
}
