package gh.tpm.api.web;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.Duration;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

import gh.tpm.api.config.JwtProperties;
import gh.tpm.api.domain.Branch;
import gh.tpm.api.domain.InviteCode;
import gh.tpm.api.domain.Role;
import gh.tpm.api.domain.User;
import gh.tpm.api.repo.BranchRepository;
import gh.tpm.api.repo.InviteCodeRepository;
import gh.tpm.api.repo.UserRepository;
import gh.tpm.api.security.JwtService;
import gh.tpm.api.web.dto.AuthDtos.LoginRequest;
import gh.tpm.api.web.dto.AuthDtos.RegisterRequest;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock private UserRepository users;
    @Mock private BranchRepository branches;
    @Mock private InviteCodeRepository inviteCodes;

    // Cost 4 rather than the production 12: these tests hash a lot and the
    // work factor is not what is under test.
    private final PasswordEncoder encoder = new BCryptPasswordEncoder(4);
    private final JwtService jwt = new JwtService(
            new JwtProperties("a-test-signing-secret-that-is-long-enough-32", "tpm-api",
                    Duration.ofHours(1)));

    private AuthService service;

    private Branch kumasi;

    @BeforeEach
    void setUp() {
        service = new AuthService(users, branches, inviteCodes, encoder, jwt);
        kumasi = new Branch();
        kumasi.setId(UUID.randomUUID());
        kumasi.setName("Kumasi Central");
    }

    private static RegisterRequest registration(String inviteCode, String branchName) {
        return new RegisterRequest("Ama", "Boateng", "Ama@Example.com  ",
                "a-long-enough-password", "+233240000000", branchName, inviteCode);
    }

    private void echoSavedUser() {
        when(users.save(any(User.class))).thenAnswer(call -> {
            User saved = call.getArgument(0);
            saved.setId(UUID.randomUUID());
            return saved;
        });
    }

    @Test
    void registrationWithoutACodeCreatesAPlainMember() {
        when(users.existsByEmailIgnoreCase("ama@example.com")).thenReturn(false);
        when(branches.findByNameIgnoreCase("Kumasi Central")).thenReturn(Optional.of(kumasi));
        echoSavedUser();

        var response = service.register(registration(null, "Kumasi Central"));

        assertThat(response.user().role()).isEqualTo(Role.MEMBER);
        assertThat(response.user().canEnterPortal()).isFalse();
        assertThat(response.user().branchName()).isEqualTo("Kumasi Central");
        assertThat(response.token()).isNotBlank();
    }

    @Test
    void emailIsNormalisedBeforeItIsStored() {
        when(users.existsByEmailIgnoreCase("ama@example.com")).thenReturn(false);
        echoSavedUser();

        service.register(registration(null, null));

        var captor = ArgumentCaptor.forClass(User.class);
        verify(users).save(captor.capture());
        assertThat(captor.getValue().getEmail()).isEqualTo("ama@example.com");
    }

    @Test
    void passwordIsHashedNotStored() {
        when(users.existsByEmailIgnoreCase("ama@example.com")).thenReturn(false);
        echoSavedUser();

        service.register(registration(null, null));

        var captor = ArgumentCaptor.forClass(User.class);
        verify(users).save(captor.capture());
        assertThat(captor.getValue().getPasswordHash())
                .isNotEqualTo("a-long-enough-password")
                .startsWith("$2");
    }

    @Test
    void aValidInviteCodeGrantsItsRoleAndPinsItsBranch() {
        var invite = new InviteCode();
        invite.setCode("LEAD-KUMASI");
        invite.setRole(Role.LEADER);
        invite.setBranch(kumasi);
        invite.setActive(true);

        when(users.existsByEmailIgnoreCase("ama@example.com")).thenReturn(false);
        when(inviteCodes.findByCode("LEAD-KUMASI")).thenReturn(Optional.of(invite));
        echoSavedUser();

        // Asks for Accra, but the code is pinned to Kumasi — the code wins.
        var response = service.register(registration("LEAD-KUMASI", "Accra Ridge"));

        assertThat(response.user().role()).isEqualTo(Role.LEADER);
        assertThat(response.user().branchName()).isEqualTo("Kumasi Central");
        assertThat(invite.getUsedCount()).isEqualTo(1);
    }

    @Test
    void roleCannotBeSelfAssignedWithoutACode() {
        when(users.existsByEmailIgnoreCase("ama@example.com")).thenReturn(false);
        echoSavedUser();

        // The request body has no role field at all; the only path to LEADER is
        // a code. This is the regression guard for the old client-side check.
        var response = service.register(registration(null, null));

        assertThat(response.user().role()).isEqualTo(Role.MEMBER);
        verify(inviteCodes, never()).findByCode(any());
    }

    @Test
    void anExhaustedCodeIsRejected() {
        var invite = new InviteCode();
        invite.setCode("SPENT");
        invite.setRole(Role.LEADER);
        invite.setBranch(kumasi);
        invite.setMaxUses(1);
        invite.setUsedCount(1);

        when(users.existsByEmailIgnoreCase("ama@example.com")).thenReturn(false);
        when(inviteCodes.findByCode("SPENT")).thenReturn(Optional.of(invite));

        assertThatThrownBy(() -> service.register(registration("SPENT", null)))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("no longer valid");
        verify(users, never()).save(any());
    }

    @Test
    void anExpiredCodeIsRejected() {
        var invite = new InviteCode();
        invite.setCode("OLD");
        invite.setRole(Role.ADMIN);
        invite.setExpiresAt(Instant.now().minusSeconds(60));

        when(users.existsByEmailIgnoreCase("ama@example.com")).thenReturn(false);
        when(inviteCodes.findByCode("OLD")).thenReturn(Optional.of(invite));

        assertThatThrownBy(() -> service.register(registration("OLD", null)))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("no longer valid");
    }

    @Test
    void anUnknownCodeIsRejected() {
        when(users.existsByEmailIgnoreCase("ama@example.com")).thenReturn(false);
        when(inviteCodes.findByCode("NOPE")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.register(registration("NOPE", null)))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("not valid");
    }

    @Test
    void aLeaderCodeWithNoBranchAnywhereIsRejected() {
        var invite = new InviteCode();
        invite.setCode("LEAD-ANY");
        invite.setRole(Role.LEADER);

        when(users.existsByEmailIgnoreCase("ama@example.com")).thenReturn(false);
        when(inviteCodes.findByCode("LEAD-ANY")).thenReturn(Optional.of(invite));

        assertThatThrownBy(() -> service.register(registration("LEAD-ANY", null)))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("must belong to a branch");
    }

    @Test
    void aDuplicateEmailIsAConflict() {
        when(users.existsByEmailIgnoreCase("ama@example.com")).thenReturn(true);

        assertThatThrownBy(() -> service.register(registration(null, null)))
                .isInstanceOf(ApiException.class)
                .satisfies(e -> assertThat(((ApiException) e).status())
                        .isEqualTo(HttpStatus.CONFLICT));
    }

    @Test
    void anUnknownBranchIsRejected() {
        when(users.existsByEmailIgnoreCase("ama@example.com")).thenReturn(false);
        when(branches.findByNameIgnoreCase("Atlantis")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.register(registration(null, "Atlantis")))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("Unknown branch");
    }

    @Test
    void loginSucceedsWithTheRightPassword() {
        var user = new User();
        user.setId(UUID.randomUUID());
        user.setFirstName("Ama");
        user.setLastName("Boateng");
        user.setEmail("ama@example.com");
        user.setRole(Role.LEADER);
        user.setBranch(kumasi);
        user.setPasswordHash(encoder.encode("correct-horse-battery"));

        when(users.findByEmailIgnoreCase("ama@example.com")).thenReturn(Optional.of(user));

        var response = service.login(new LoginRequest("Ama@Example.com", "correct-horse-battery"));

        assertThat(response.token()).isNotBlank();
        assertThat(response.user().canEnterPortal()).isTrue();
    }

    @Test
    void loginFailsIdenticallyForAWrongPasswordAndAnUnknownEmail() {
        var user = new User();
        user.setId(UUID.randomUUID());
        user.setFirstName("Ama");
        user.setLastName("Boateng");
        user.setEmail("ama@example.com");
        user.setRole(Role.MEMBER);
        user.setPasswordHash(encoder.encode("the-real-password"));

        when(users.findByEmailIgnoreCase("ama@example.com")).thenReturn(Optional.of(user));
        when(users.findByEmailIgnoreCase("nobody@example.com")).thenReturn(Optional.empty());

        var wrongPassword = assertThatThrownBy(
                () -> service.login(new LoginRequest("ama@example.com", "guess")));
        var unknownEmail = assertThatThrownBy(
                () -> service.login(new LoginRequest("nobody@example.com", "guess")));

        // Same status and same wording: the response must not reveal whether an
        // account exists.
        wrongPassword.isInstanceOf(ApiException.class)
                .hasMessage("Email or password is incorrect");
        unknownEmail.isInstanceOf(ApiException.class)
                .hasMessage("Email or password is incorrect");
    }

    @Test
    void aDeactivatedAccountCannotSignIn() {
        var user = new User();
        user.setId(UUID.randomUUID());
        user.setFirstName("Ama");
        user.setLastName("Boateng");
        user.setEmail("ama@example.com");
        user.setRole(Role.MEMBER);
        user.setActive(false);
        user.setPasswordHash(encoder.encode("the-real-password"));

        when(users.findByEmailIgnoreCase("ama@example.com")).thenReturn(Optional.of(user));

        assertThatThrownBy(
                () -> service.login(new LoginRequest("ama@example.com", "the-real-password")))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("deactivated");
    }
}
