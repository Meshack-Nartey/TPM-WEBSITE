package gh.tpm.api.web.dto;

import java.util.UUID;

import gh.tpm.api.domain.Role;
import gh.tpm.api.domain.User;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Request and response shapes for the authentication endpoints. */
public final class AuthDtos {

    private AuthDtos() {
    }

    public record RegisterRequest(
            @NotBlank @Size(max = 80) String firstName,
            @NotBlank @Size(max = 80) String lastName,
            @NotBlank @Email @Size(max = 160) String email,
            // 10 rather than 8: this is the only credential most members will
            // have, and the cost of a longer minimum is paid once.
            @NotBlank @Size(min = 10, max = 100) String password,
            @Size(max = 40) String phone,
            String branchName,
            /** Required for anything above member; ignored otherwise. */
            String inviteCode) {
    }

    public record LoginRequest(
            @NotBlank @Email String email,
            @NotBlank String password) {
    }

    /** What the apps store after a successful sign-in. */
    public record AuthResponse(String token, UserResponse user) {
    }

    public record UserResponse(
            UUID id,
            String firstName,
            String lastName,
            String fullName,
            String email,
            String phone,
            Role role,
            UUID branchId,
            String branchName,
            boolean canEnterPortal) {

        public static UserResponse from(User user) {
            return new UserResponse(
                    user.getId(),
                    user.getFirstName(),
                    user.getLastName(),
                    user.fullName(),
                    user.getEmail(),
                    user.getPhone(),
                    user.getRole(),
                    user.getBranch() == null ? null : user.getBranch().getId(),
                    user.getBranch() == null ? null : user.getBranch().getName(),
                    user.getRole().canEnterPortal());
        }
    }
}
