package gh.tpm.api.repo;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import gh.tpm.api.domain.Book;

public interface BookRepository extends JpaRepository<Book, UUID> {

    List<Book> findByActiveTrueOrderBySortOrderAscTitleAsc();
}
