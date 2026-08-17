package gh.tpm.api.web;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import gh.tpm.api.repo.UserRepository;
import gh.tpm.api.security.AppPrincipal;
import gh.tpm.api.web.dto.AuthDtos.AuthResponse;
import gh.tpm.api.web.dto.AuthDtos.LoginRequest;
import gh.tpm.api.web.dto.AuthDtos.RegisterRequest;
import gh.tpm.api.web.dto.AuthDtos.UserResponse;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;
    private final UserRepository users;

    public AuthController(AuthService authService, UserRepository users) {
        this.authService = authService;
        this.users = users;
    }

    @PostMapping("/register")
    public AuthResponse register(@Valid @RequestBody RegisterRequest request) {
        return authService.register(request);
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request) {
        return authService.login(request);
    }

    /**
     * Re-reads the user rather than reflecting the token back, so a role or
     * branch changed by an admin takes effect on the app's next launch instead
     * of waiting for the token to expire.
     */
    @GetMapping("/me")
    public UserResponse me(@AuthenticationPrincipal AppPrincipal principal) {
        return users.findWithBranchById(principal.id())
                .map(UserResponse::from)
                .orElseThrow(() -> ApiException.notFound("Account"));
    }
}
