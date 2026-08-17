-- Transformation Project Ministries — initial schema.
--
-- This is a fresh, Flyway-owned schema rather than an adoption of the tables the
-- previous Node/Prisma service created. Three things change deliberately:
--
--   1. Branch is a table, not a free-text column. Leader scoping, the branch
--      rankings and the mobile app's "find us" screen all key off branch, and
--      matching on a typed string is how you end up with "Kumasi Central" and
--      "Kumasi central" as different branches.
--   2. Real column types. Dates are date, money is numeric(12,2), timestamps are
--      timestamptz — the old schema stored several of these as text.
--   3. Enumerated values are varchar + CHECK rather than Postgres enum types.
--      Adding a value to a CHECK is an ordinary migration; adding one to a PG
--      enum is not, and these lists will grow.
--
-- Identifiers are uuid defaulted by gen_random_uuid(), built into Postgres 13+.

-- ---------------------------------------------------------------------------
-- Shared: keep updated_at honest without relying on the application layer.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS trigger AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------------
-- Branches
-- ---------------------------------------------------------------------------
CREATE TABLE branches (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name        varchar(120) NOT NULL UNIQUE,
    region      varchar(80),
    address     varchar(255),
    phone       varchar(40),
    email       varchar(160),
    whatsapp    varchar(40),
    latitude    numeric(9, 6),
    longitude   numeric(9, 6),
    active      boolean NOT NULL DEFAULT true,
    sort_order  integer NOT NULL DEFAULT 0,
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER branches_set_updated_at
    BEFORE UPDATE ON branches
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---------------------------------------------------------------------------
-- Portal accounts
-- ---------------------------------------------------------------------------
CREATE TABLE users (
    id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name    varchar(80) NOT NULL,
    last_name     varchar(80) NOT NULL,
    email         varchar(160) NOT NULL UNIQUE,
    password_hash varchar(100) NOT NULL,
    phone         varchar(40),
    role          varchar(16) NOT NULL DEFAULT 'MEMBER'
                  CONSTRAINT users_role_check CHECK (role IN ('MEMBER', 'LEADER', 'ADMIN')),
    -- A leader is scoped to exactly one branch; admins see every branch, so
    -- theirs may be null.
    branch_id     uuid REFERENCES branches (id) ON DELETE SET NULL,
    department    varchar(120),
    fellowship    varchar(120),
    date_joined   date,
    active        boolean NOT NULL DEFAULT true,
    created_at    timestamptz NOT NULL DEFAULT now(),
    updated_at    timestamptz NOT NULL DEFAULT now()
);

-- Email is compared case-insensitively at login, so the uniqueness guarantee
-- has to be case-insensitive too.
CREATE UNIQUE INDEX users_email_lower_key ON users (lower(email));
CREATE INDEX users_role_idx ON users (role);
CREATE INDEX users_branch_idx ON users (branch_id);

CREATE TRIGGER users_set_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---------------------------------------------------------------------------
-- Church member registry — people entered by leaders, who may never sign in.
-- ---------------------------------------------------------------------------
CREATE TABLE members (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name              varchar(80) NOT NULL,
    middle_name             varchar(80),
    last_name               varchar(80) NOT NULL,
    date_of_birth           date,
    gender                  varchar(20),
    phone                   varchar(40),
    email                   varchar(160),
    address                 varchar(255),
    branch_id               uuid REFERENCES branches (id) ON DELETE SET NULL,
    department              varchar(120),
    fellowship              varchar(120),
    worker_group            varchar(120),
    date_joined             date,
    membership_status       varchar(20) NOT NULL DEFAULT 'MEMBER'
                            CONSTRAINT members_status_check
                            CHECK (membership_status IN ('MEMBER', 'VISITOR', 'WORKER')),
    emergency_contact_name  varchar(120),
    emergency_contact_phone varchar(40),
    registered_by_id        uuid REFERENCES users (id) ON DELETE SET NULL,
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX members_branch_idx ON members (branch_id);
CREATE INDEX members_status_idx ON members (membership_status);
-- Backs the registry's search-as-you-type over name.
CREATE INDEX members_name_idx ON members (lower(first_name), lower(last_name));

CREATE TRIGGER members_set_updated_at
    BEFORE UPDATE ON members
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---------------------------------------------------------------------------
-- Weekly reports submitted by branch leaders.
-- ---------------------------------------------------------------------------
CREATE TABLE reports (
    id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id        uuid NOT NULL REFERENCES branches (id) ON DELETE CASCADE,
    meeting_type     varchar(60) NOT NULL,
    service_date     date NOT NULL,
    attendance_male  integer NOT NULL DEFAULT 0 CHECK (attendance_male >= 0),
    attendance_female integer NOT NULL DEFAULT 0 CHECK (attendance_female >= 0),
    -- Derived rather than sent by the client: the app shows totals everywhere,
    -- and a total that disagrees with its parts is a support ticket.
    attendance_total integer GENERATED ALWAYS AS (attendance_male + attendance_female) STORED,
    tithe            numeric(12, 2) NOT NULL DEFAULT 0 CHECK (tithe >= 0),
    souls_male       integer NOT NULL DEFAULT 0 CHECK (souls_male >= 0),
    souls_female     integer NOT NULL DEFAULT 0 CHECK (souls_female >= 0),
    souls_total      integer GENERATED ALWAYS AS (souls_male + souls_female) STORED,
    first_time_visitors integer NOT NULL DEFAULT 0 CHECK (first_time_visitors >= 0),
    notes            text,
    submitted_by_id  uuid REFERENCES users (id) ON DELETE SET NULL,
    -- Set by the device, not the server: reports are filled in offline and may
    -- arrive hours later, so "when it was written" and "when it landed" differ.
    recorded_at      timestamptz,
    created_at       timestamptz NOT NULL DEFAULT now(),

    -- One report per branch per meeting per day. A queued report that syncs
    -- twice on a flaky connection must not double-count attendance.
    CONSTRAINT reports_unique_per_meeting UNIQUE (branch_id, meeting_type, service_date)
);

CREATE INDEX reports_branch_date_idx ON reports (branch_id, service_date DESC);
CREATE INDEX reports_date_idx ON reports (service_date DESC);

-- ---------------------------------------------------------------------------
-- Member-initiated changes to their own details, approved by the office.
-- ---------------------------------------------------------------------------
CREATE TABLE profile_requests (
    id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id        uuid REFERENCES users (id) ON DELETE CASCADE,
    field_name     varchar(60) NOT NULL,
    old_value      varchar(255),
    new_value      varchar(255) NOT NULL,
    status         varchar(16) NOT NULL DEFAULT 'PENDING'
                   CONSTRAINT profile_requests_status_check
                   CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    reviewed_by_id uuid REFERENCES users (id) ON DELETE SET NULL,
    reviewed_at    timestamptz,
    created_at     timestamptz NOT NULL DEFAULT now(),
    updated_at     timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX profile_requests_status_idx ON profile_requests (status, created_at DESC);

CREATE TRIGGER profile_requests_set_updated_at
    BEFORE UPDATE ON profile_requests
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---------------------------------------------------------------------------
-- Announcements — the news feed on the member surface.
-- ---------------------------------------------------------------------------
CREATE TABLE announcements (
    id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tag          varchar(60) NOT NULL,
    title        varchar(200) NOT NULL,
    excerpt      varchar(400),
    body         text NOT NULL,
    -- Null audience means every branch. The composer makes this an explicit
    -- choice, so the column has to be able to say "all".
    branch_id    uuid REFERENCES branches (id) ON DELETE CASCADE,
    published_at timestamptz NOT NULL DEFAULT now(),
    active       boolean NOT NULL DEFAULT true,
    sort_order   integer NOT NULL DEFAULT 0,
    created_by_id uuid REFERENCES users (id) ON DELETE SET NULL,
    created_at   timestamptz NOT NULL DEFAULT now(),
    updated_at   timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX announcements_feed_idx ON announcements (active, published_at DESC);

CREATE TRIGGER announcements_set_updated_at
    BEFORE UPDATE ON announcements
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---------------------------------------------------------------------------
-- Events
-- ---------------------------------------------------------------------------
CREATE TABLE events (
    id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tag          varchar(60) NOT NULL,
    title        varchar(200) NOT NULL,
    description  text,
    location     varchar(255),
    starts_at    timestamptz NOT NULL,
    ends_at      timestamptz,
    all_day      boolean NOT NULL DEFAULT false,
    branch_id    uuid REFERENCES branches (id) ON DELETE CASCADE,
    image_url    varchar(500),
    active       boolean NOT NULL DEFAULT true,
    created_by_id uuid REFERENCES users (id) ON DELETE SET NULL,
    created_at   timestamptz NOT NULL DEFAULT now(),
    updated_at   timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT events_ends_after_starts CHECK (ends_at IS NULL OR ends_at >= starts_at)
);

CREATE INDEX events_upcoming_idx ON events (active, starts_at);

CREATE TRIGGER events_set_updated_at
    BEFORE UPDATE ON events
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---------------------------------------------------------------------------
-- Media library — sermons, teachings, podcasts.
-- ---------------------------------------------------------------------------
CREATE TABLE media_items (
    id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    kind             varchar(20) NOT NULL
                     CONSTRAINT media_kind_check CHECK (kind IN ('SERMON', 'TEACHING', 'PODCAST')),
    title            varchar(200) NOT NULL,
    speaker          varchar(120),
    scripture        varchar(120),
    duration_seconds integer CHECK (duration_seconds IS NULL OR duration_seconds > 0),
    audio_url        varchar(500),
    video_url        varchar(500),
    image_url        varchar(500),
    published_at     timestamptz NOT NULL DEFAULT now(),
    -- Whether the app may offer this for offline download; some content is
    -- stream-only for licensing reasons.
    downloadable     boolean NOT NULL DEFAULT true,
    active           boolean NOT NULL DEFAULT true,
    created_at       timestamptz NOT NULL DEFAULT now(),
    updated_at       timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX media_library_idx ON media_items (active, kind, published_at DESC);

CREATE TRIGGER media_items_set_updated_at
    BEFORE UPDATE ON media_items
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---------------------------------------------------------------------------
-- Books & study resources
-- ---------------------------------------------------------------------------
CREATE TABLE books (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    title       varchar(200) NOT NULL,
    author      varchar(160),
    description text,
    cover_url   varchar(500),
    file_url    varchar(500),
    active      boolean NOT NULL DEFAULT true,
    sort_order  integer NOT NULL DEFAULT 0,
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER books_set_updated_at
    BEFORE UPDATE ON books
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---------------------------------------------------------------------------
-- Leadership directory (shown on the public website and the app).
-- ---------------------------------------------------------------------------
CREATE TABLE leaders (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name       varchar(160) NOT NULL,
    title      varchar(160),
    branch_id  uuid REFERENCES branches (id) ON DELETE SET NULL,
    fellowship varchar(120),
    quote      text,
    bio        text,
    highlights text[] NOT NULL DEFAULT '{}',
    photo_url  varchar(500),
    email      varchar(160),
    phone      varchar(40),
    active     boolean NOT NULL DEFAULT true,
    sort_order integer NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER leaders_set_updated_at
    BEFORE UPDATE ON leaders
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---------------------------------------------------------------------------
-- Reference lists: departments, fellowships, meeting types, genders, …
-- ---------------------------------------------------------------------------
CREATE TABLE lookups (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    category   varchar(60) NOT NULL,
    value      varchar(120) NOT NULL,
    sort_order integer NOT NULL DEFAULT 0,
    active     boolean NOT NULL DEFAULT true,

    CONSTRAINT lookups_unique_value UNIQUE (category, value)
);

CREATE INDEX lookups_category_idx ON lookups (category, sort_order);

-- ---------------------------------------------------------------------------
-- Invite codes gating leader/admin registration. Validated server-side only.
-- ---------------------------------------------------------------------------
CREATE TABLE invite_codes (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    code       varchar(80) NOT NULL UNIQUE,
    role       varchar(16) NOT NULL
               CONSTRAINT invite_codes_role_check CHECK (role IN ('MEMBER', 'LEADER', 'ADMIN')),
    -- A code may be tied to one branch, so a leader code for Kumasi cannot be
    -- used to claim leadership of Accra.
    branch_id  uuid REFERENCES branches (id) ON DELETE CASCADE,
    max_uses   integer CHECK (max_uses IS NULL OR max_uses > 0),
    used_count integer NOT NULL DEFAULT 0 CHECK (used_count >= 0),
    expires_at timestamptz,
    active     boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now()
);
