-- Reference data the app cannot usefully start without.
--
-- Every list here is the ministry's own, carried across from
-- backend/prisma/seed.js so the new service and the one it replaces agree.
-- The design board used invented names (Kumasi Central, Accra Ridge) because it
-- was drawn before these lists were to hand — none of that is real, and none of
-- it is here.
--
-- No users and no invite codes: the first admin and the real codes are created
-- by an operator with secrets that must never live in a committed migration.

-- The nine branches, in the ministry's own order.
INSERT INTO branches (name, sort_order) VALUES
    ('DAYSPRING',       1),
    ('GLORYSPRING',     2),
    ('GOODNEWSSPRING',  3),
    ('FAITHSPRING',     4),
    ('LOYALTYSPRING',   5),
    ('GRACESPRING',     6),
    ('UNITYSPRING',     7),
    ('PEACESPRING',     8),
    ('SALVATIONSPRING', 9)
ON CONFLICT (name) DO NOTHING;

-- The head office, so "find us" has somewhere to point. Plus code and contact
-- details come from the website's contact page.
UPDATE branches
   SET region  = 'Ashanti',
       address = 'MC3V+2JF, Kumasi',
       phone   = '0554476730',
       email   = 'tprojectministries@gmail.com'
 WHERE name = 'DAYSPRING'
   AND address IS NULL;

INSERT INTO lookups (category, value, sort_order) VALUES
    -- Meeting types drive the weekly report. "LOUCS Report" and "Basenia" are
    -- ministry-specific and have no generic equivalent.
    ('MEETING_TYPE', 'LOUCS Report',     1),
    ('MEETING_TYPE', 'Basenia',          2),
    ('MEETING_TYPE', 'Friday Service',   3),
    ('MEETING_TYPE', 'General Meeting',  4),
    ('MEETING_TYPE', 'Tithe Collection', 5),
    ('MEETING_TYPE', 'Souls Won',        6),

    ('MEMBERSHIP_STATUS', 'New Convert',    1),
    ('MEMBERSHIP_STATUS', 'Regular Member', 2),
    ('MEMBERSHIP_STATUS', 'Worker',         3),
    ('MEMBERSHIP_STATUS', 'Leader',         4),

    ('GENDER', 'Male',   1),
    ('GENDER', 'Female', 2),

    ('FELLOWSHIP', 'Transformed Men Fellowship',   1),
    ('FELLOWSHIP', 'Transformed Law',              2),
    ('FELLOWSHIP', 'Transformed Shepherds',        3),
    ('FELLOWSHIP', 'Transformed Couples',          4),
    ('FELLOWSHIP', 'Transformed Women Fellowship', 5),
    ('FELLOWSHIP', 'Transformed Youth Fellowship', 6),

    ('BASENIA', 'HeavenSpring Basenia', 1),
    ('BASENIA', 'LoveSpring Basenia',   2),
    ('BASENIA', 'GraceSpring Basenia',  3),
    ('BASENIA', 'FaithSpring Basenia',  4),
    ('BASENIA', 'HopeSpring Basenia',   5),
    ('BASENIA', 'JoySpring Basenia',    6),
    ('BASENIA', 'PeaceSpring Basenia',  7),
    ('BASENIA', 'GlorySpring Basenia',  8),

    -- Shown as "Worker Groups" in the portal; names match join-us.html.
    ('DEPARTMENT', 'Communion Stewards',       1),
    ('DEPARTMENT', 'Ushering',                 2),
    ('DEPARTMENT', 'Protocol',                 3),
    ('DEPARTMENT', 'Hospitality and Welfare',  4),
    ('DEPARTMENT', 'Pure Word',                5),
    ('DEPARTMENT', 'Media and Publicity',      6),
    ('DEPARTMENT', 'Music',                    7),
    ('DEPARTMENT', 'Theatre and Arts',         8),
    ('DEPARTMENT', 'Finance',                  9),
    ('DEPARTMENT', 'Organizing',              10),
    ('DEPARTMENT', 'Sounds and Technical',    11),
    ('DEPARTMENT', 'Growth',                  12),
    ('DEPARTMENT', 'Literature',              13),
    ('DEPARTMENT', 'Miscellaneous',           14),
    ('DEPARTMENT', 'The Pastor''s Office',    15),

    ('ANNOUNCEMENT_TAG', 'Weekly Service', 1),
    ('ANNOUNCEMENT_TAG', 'Camp',           2),
    ('ANNOUNCEMENT_TAG', 'Conference',     3),
    ('ANNOUNCEMENT_TAG', 'Upcoming Event', 4)
ON CONFLICT (category, value) DO NOTHING;
