package gh.tpm.api.repo;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import gh.tpm.api.domain.Leader;

public interface LeaderRepository extends JpaRepository<Leader, UUID> {

    List<Leader> findByActiveTrueOrderBySortOrderAscNameAsc();
}
