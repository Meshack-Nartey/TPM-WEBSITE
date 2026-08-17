package gh.tpm.api.repo;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import gh.tpm.api.domain.Lookup;

public interface LookupRepository extends JpaRepository<Lookup, UUID> {

    List<Lookup> findByActiveTrueOrderByCategoryAscSortOrderAscValueAsc();
}
