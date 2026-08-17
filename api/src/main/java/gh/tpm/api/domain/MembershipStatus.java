package gh.tpm.api.domain;

/**
 * Where someone stands with the church, as recorded by their branch leader.
 *
 * <p>These four are the ministry's own, carried from the reference lists the
 * portal already uses. The design board sketched a member/visitor/worker triple
 * instead — that was placeholder copy, and matching it would have made the API
 * reject real records.
 */
public enum MembershipStatus {
    NEW_CONVERT("New Convert"),
    REGULAR_MEMBER("Regular Member"),
    WORKER("Worker"),
    LEADER("Leader");

    private final String label;

    MembershipStatus(String label) {
        this.label = label;
    }

    /** How the status is written everywhere a person will read it. */
    public String label() {
        return label;
    }
}
