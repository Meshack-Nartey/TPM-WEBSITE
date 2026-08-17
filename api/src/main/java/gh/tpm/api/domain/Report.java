package gh.tpm.api.domain;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

/**
 * A branch's weekly return: attendance, tithe and souls won.
 *
 * <p>Totals are generated columns in Postgres, so they are read-only here — a
 * total that disagrees with its parts is not something the API should be able
 * to express.
 */
@Entity
@Table(name = "reports")
@Getter
@Setter
public class Report extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "branch_id", nullable = false)
    private Branch branch;

    @Column(name = "meeting_type", nullable = false, length = 60)
    private String meetingType;

    @Column(name = "service_date", nullable = false)
    private LocalDate serviceDate;

    @Column(name = "attendance_male", nullable = false)
    private int attendanceMale;

    @Column(name = "attendance_female", nullable = false)
    private int attendanceFemale;

    @Column(name = "attendance_total", insertable = false, updatable = false)
    private Integer attendanceTotal;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal tithe = BigDecimal.ZERO;

    @Column(name = "souls_male", nullable = false)
    private int soulsMale;

    @Column(name = "souls_female", nullable = false)
    private int soulsFemale;

    @Column(name = "souls_total", insertable = false, updatable = false)
    private Integer soulsTotal;

    @Column(name = "first_time_visitors", nullable = false)
    private int firstTimeVisitors;

    @Column(columnDefinition = "text")
    private String notes;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "submitted_by_id")
    private User submittedBy;

    /**
     * When the leader filled this in, as reported by the device. Reports are
     * written offline and may not reach us for hours, so this is not the same
     * as {@link #createdAt}.
     */
    @Column(name = "recorded_at")
    private Instant recordedAt;

    @Column(name = "created_at", insertable = false, updatable = false)
    private Instant createdAt;
}
