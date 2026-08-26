package gh.tpm.api.repo;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import gh.tpm.api.domain.InviteCode;

public interface InviteCodeRepository extends JpaRepository<InviteCode, UUID> {

    @Query("select c from InviteCode c left join fetch c.branch where c.code = :code")
    Optional<InviteCode> findByCode(@Param("code") String code);
}
