package gh.tpm.api.repo;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import gh.tpm.api.domain.User;

public interface UserRepository extends JpaRepository<User, UUID> {

    /**
     * Sign-in lookup. Case-insensitive because people type their email how they
     * please; the matching unique index is on lower(email).
     */
    @Query("select u from User u left join fetch u.branch where lower(u.email) = lower(:email)")
    Optional<User> findByEmailIgnoreCase(@Param("email") String email);

    boolean existsByEmailIgnoreCase(String email);
}
