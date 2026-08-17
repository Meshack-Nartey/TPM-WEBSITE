package gh.tpm.api.web;

import java.time.Instant;
import java.util.Locale;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import gh.tpm.api.domain.Branch;
import gh.tpm.api.domain.InviteCode;
import gh.tpm.api.domain.Role;
import gh.tpm.api.domain.User;
import gh.tpm.api.repo.BranchRepository;
import gh.tpm.api.repo.InviteCodeRepository;
import gh.tpm.api.repo.UserRepository;
import gh.tpm.api.security.JwtService;
import gh.tpm.api.web.dto.AuthDtos.AuthResponse;
import gh.tpm.api.web.dto.AuthDtos.LoginRequest;
import gh.tpm.api.web.dto.AuthDtos.RegisterRequest;
import gh.tpm.api.web.dto.AuthDtos.UserResponse;

/** Registration and sign-in. */
@Service
public class AuthService {

    private final UserRepository users;
    private final BranchRepository branches;
    private final InviteCodeRepository inviteCodes;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthService(UserRepository users,
                       BranchRepository branches,
                       InviteCodeRepository inviteCodes,
                       PasswordEncoder passwordEncoder,
                       JwtService jwtService) {
        this.users = users;
        this.branches = branches;
        this.inviteCodes = inviteCodes;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        String email = normalise(request.email());
        if (users.existsByEmailIgnoreCase(email)) {
            // Registration is a deliberate exception to the "don't reveal
            // whether an account exists" rule: without it, a member who has
            // forgotten they signed up cannot tell why the form keeps failing.
            throw ApiException.conflict("An account with that email already exists");
        }

        var user = new User();
        user.setFirstName(request.firstName().trim());
        user.setLastName(request.lastName().trim());
        user.setEmail(email);
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        user.setPhone(blankToNull(request.phone()));

        // Role comes from the invite code, never from the request body.
        if (blankToNull(request.inviteCode()) == null) {
            user.setRole(Role.MEMBER);
            user.setBranch(resolveBranch(request.branchName()));
        } else {
            InviteCode code = redeem(request.inviteCode().trim());
            user.setRole(code.getRole());
            // A code tied to a branch pins the account to it, so a Kumasi leader
            // code cannot be used to claim Accra. The requested branch is then
            // irrelevant and is not even looked up — a code that already decides
            // the branch should not fail because of a name the caller sent.
            user.setBranch(code.getBranch() != null
                    ? code.getBranch()
                    : resolveBranch(request.branchName()));
        }

        if (user.getRole() == Role.LEADER && user.getBranch() == null) {
            throw ApiException.badRequest("A leader account must belong to a branch");
        }

        User saved = users.save(user);
        return new AuthResponse(jwtService.issue(saved), UserResponse.from(saved));
    }

    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest request) {
        User user = users.findByEmailIgnoreCase(normalise(request.email())).orElse(null);

        // Hash even when the user is missing, so a wrong email and a wrong
        // password take the same time and cannot be told apart by timing.
        String hash = user != null ? user.getPasswordHash() : PLACEHOLDER_HASH;
        boolean matches = passwordEncoder.matches(request.password(), hash);

        if (user == null || !matches) {
            throw ApiException.unauthorized("Email or password is incorrect");
        }
        if (!user.isActive()) {
            throw ApiException.forbidden("This account has been deactivated");
        }
        return new AuthResponse(jwtService.issue(user), UserResponse.from(user));
    }

    private InviteCode redeem(String code) {
        InviteCode invite = inviteCodes.findByCode(code)
                .orElseThrow(() -> ApiException.badRequest("That invite code is not valid"));

        if (!invite.isRedeemable(Instant.now())) {
            throw ApiException.badRequest("That invite code is no longer valid");
        }
        invite.setUsedCount(invite.getUsedCount() + 1);
        inviteCodes.save(invite);
        return invite;
    }

    private Branch resolveBranch(String name) {
        String branchName = blankToNull(name);
        if (branchName == null) {
            return null;
        }
        return branches.findByNameIgnoreCase(branchName.trim())
                .orElseThrow(() -> ApiException.badRequest("Unknown branch: " + branchName));
    }

    private static String normalise(String email) {
        return email == null ? null : email.trim().toLowerCase(Locale.ROOT);
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value;
    }

    /**
     * A real BCrypt hash of an unguessable value. Only ever used to burn the
     * same CPU as a genuine comparison when the email does not exist.
     */
    private static final String PLACEHOLDER_HASH =
            "$2a$12$C6UzMDM.H6dfI/f/IKcEe.ZxvxJHkxFTNlKD7Yl7YoLHKUUxL7Wgy";
}
