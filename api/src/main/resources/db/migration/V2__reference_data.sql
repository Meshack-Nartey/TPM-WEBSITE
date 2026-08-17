-- Reference data the app cannot usefully start without.
--
-- Branches and lookup lists only. No users and no invite codes: the first admin
-- and the real invite codes are created by an operator with secrets that must
-- never live in a migration file committed to the repository.

INSERT INTO branches (name, region, address, sort_order) VALUES
    ('Kumasi Central', 'Ashanti',       'Adum High St, Kumasi',          1),
    ('Accra Ridge',    'Greater Accra', '14 Independence Ave, Accra',    2),
    ('Cape Coast',     'Central',       'Chapel Sq, Cape Coast',         3),
    ('Takoradi',       'Western',       'Market Circle, Takoradi',       4)
ON CONFLICT (name) DO NOTHING;

INSERT INTO lookups (category, value, sort_order) VALUES
    ('MEETING_TYPE', 'Sunday Service',      1),
    ('MEETING_TYPE', 'Midweek Service',     2),
    ('MEETING_TYPE', 'Friday Prayer',       3),
    ('MEETING_TYPE', 'Special Service',     4),

    ('MEMBERSHIP_STATUS', 'Member',  1),
    ('MEMBERSHIP_STATUS', 'Visitor', 2),
    ('MEMBERSHIP_STATUS', 'Worker',  3),

    ('GENDER', 'Male',   1),
    ('GENDER', 'Female', 2),

    ('DEPARTMENT', 'Ushering',            1),
    ('DEPARTMENT', 'Choir',               2),
    ('DEPARTMENT', 'Media',               3),
    ('DEPARTMENT', 'Prayer',              4),
    ('DEPARTMENT', 'Protocol',            5),
    ('DEPARTMENT', 'Hospitality',         6),
    ('DEPARTMENT', 'Finance',             7),
    ('DEPARTMENT', 'Missions',            8),

    ('FELLOWSHIP', 'Women''s Fellowship', 1),
    ('FELLOWSHIP', 'Men''s Fellowship',   2),
    ('FELLOWSHIP', 'Youth Fellowship',    3),
    ('FELLOWSHIP', 'Children',            4),

    ('ANNOUNCEMENT_TAG', 'Upcoming Event', 1),
    ('ANNOUNCEMENT_TAG', 'Weekly Service', 2),
    ('ANNOUNCEMENT_TAG', 'Conference',     3),
    ('ANNOUNCEMENT_TAG', 'Camp',           4)
ON CONFLICT (category, value) DO NOTHING;
