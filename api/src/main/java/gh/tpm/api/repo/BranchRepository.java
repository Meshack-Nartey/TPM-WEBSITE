package gh.tpm.api.repo;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import gh.tpm.api.domain.Branch;

public interface BranchRepository extends JpaRepository<Branch, UUID> {

    List<Branch> findByActiveTrueOrderBySortOrderAscNameAsc();

    Optional<Branch> findByNameIgnoreCase(String name);
}
