import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/tpm_theme.dart';

/// Content for the prototype.
///
/// Where the real thing exists, this is the real thing: the nine SPRING
/// branches, the ministry's reference lists, actual service times, the books
/// TPM publishes, the announcements on the website, and head-office contact
/// details. Those come from `frontend/` and `backend/prisma/seed.js`.
///
/// The design board used invented names (Kumasi Central, Accra Ridge) because
/// it was drawn before those lists were to hand. None of that survives here.
///
/// Still invented, because there is no real source for them: the signed-in
/// user, the member registry rows, and the dashboard figures. All are marked
/// below. Replace this file with the API client once the endpoints land.
class MockData {
  const MockData._();

  // ---- Ministry ----
  static const String ministryName = 'Transformation Project Ministries';
  static const String tagline = 'Transforming Lives';
  static const String founder = 'Apostle Andrews Amoh Ofori';
  static const String officeEmail = 'tprojectministries@gmail.com';
  static const String officePhone = '0554476730';
  static const String officeAddress = 'MC3V+2JF, Kumasi';

  // ---- Signed-in person (placeholder — there is no real "current user") ----
  static const String firstName = 'Ama';
  static const String fullName = 'Ama Boateng';
  static const String initials = 'AB';
  static const String homeBranch = 'DAYSPRING';

  /// Avatar palette, cycled by index so any list of people looks varied.
  static const List<Color> avatarPalette = [
    TpmColors.navy,
    TpmColors.violet,
    TpmColors.goldDeep,
    Color(0xFF0F766E),
    TpmColors.blue,
  ];

  static Color avatarFor(int index) => avatarPalette[index % avatarPalette.length];

  /// Tag colouring for announcements — foreground then background.
  static const Map<String, (Color, Color)> tagColors = {
    'Conference': (TpmColors.violet, TpmColors.tintViolet),
    'Camp': (TpmColors.green, TpmColors.tintGreen),
    'Weekly Service': (TpmColors.navy, TpmColors.tintIndigo),
    'Upcoming Event': (TpmColors.goldDeep, TpmColors.tintAmber),
    'Prayer': (Color(0xFF0F766E), Color(0xFFCCFBF1)),
  };

  static (Color, Color) tagColor(String tag) =>
      tagColors[tag] ?? (TpmColors.navy, TpmColors.tintIndigo);

  // ---- Services (from the website) ----
  static const List<ServiceTime> serviceTimes = [
    ServiceTime(name: '1st Service', day: 'Sundays', time: '8:00 AM – 10:00 AM'),
    ServiceTime(name: '2nd Service', day: 'Sundays', time: '10:30 AM – 12:30 PM'),
    ServiceTime(name: 'Evening Feast', day: 'Sundays', time: '4:00 PM – 7:00 PM'),
    ServiceTime(name: 'Love Therapy', day: 'Fridays', time: '6:00 PM'),
  ];

  /// The countdown on the home screen tracks the first Sunday service.
  static const String nextServiceLabel = 'Sun · 8:00 AM';
  static const int nextServiceHour = 8;
  static const String serviceSummary = 'Sun 8:00 AM & 10:30 AM · Fri 6:00 PM';

  // ---- Announcements (from announcements.html) ----
  static const List<Announcement> carousel = [
    Announcement(
      tag: 'Upcoming Event',
      title: 'Holy Ghost Festival 2026',
      meta: 'Date to be announced',
    ),
    Announcement(
      tag: 'Weekly Service',
      title: 'Love Therapy — Fridays',
      meta: 'Every Friday · 6:00 PM',
    ),
    Announcement(
      tag: 'Camp',
      title: 'Sharpening Camp',
      meta: 'Date to be announced',
    ),
  ];

  static const List<Announcement> newsFeed = [
    Announcement(
      tag: 'Upcoming Event',
      title: 'Holy Ghost Festival 2026',
      excerpt: 'The annual festival hosted by ${MockData.founder}.',
      date: 'Date: TBA',
      body:
          'The Holy Ghost Festival returns in 2026. Dates will be announced from the '
          'pastor’s office — speak with your branch leader to register your interest and '
          'arrange transport.',
    ),
    Announcement(
      tag: 'Weekly Service',
      title: 'Love Therapy — Fridays',
      excerpt: 'Our weekly Friday gathering, every week at 6:00 PM.',
      date: 'Every Friday',
      body:
          'Love Therapy runs every Friday at 6:00 PM. Come as you are, and bring someone '
          'who needs the family of God this week.',
    ),
    Announcement(
      tag: 'Camp',
      title: 'Sharpening Camp',
      excerpt: 'A season set apart to be sharpened in the Word.',
      date: 'Date: TBA',
      body:
          'Sharpening Camp is a set-apart season of teaching and consecration. Dates will '
          'be announced; registration runs through your branch.',
    ),
    Announcement(
      tag: 'Prayer',
      title: 'Corporate Prayer Night',
      excerpt: 'The whole church on its knees together.',
      date: 'Last Friday of every month',
      body:
          'Corporate Prayer Night is held on the last Friday of every month. Every branch '
          'joins for a night of intercession.',
    ),
    Announcement(
      tag: 'Conference',
      title: 'Transformation Conference',
      excerpt: 'Our flagship gathering across all branches.',
      date: 'Date: TBA',
      body:
          'The Transformation Conference brings every branch together. Dates will be '
          'announced from the pastor’s office.',
    ),
  ];

  // ---- Media (real messages from the ministry's YouTube) ----
  static const MediaItem featured = MediaItem(
    kind: MediaKind.sermon,
    title: 'Surround Yourself With Good People',
    meta: founder,
    image: 'assets/media/sunday-service.png',
    downloaded: true,
  );

  static const List<String> mediaFilters = ['All', 'Sermons', 'Teachings', 'Podcasts'];

  static const List<MediaItem> media = [
    MediaItem(
      kind: MediaKind.sermon,
      title: 'Surround Yourself With Good People',
      meta: founder,
      image: 'assets/media/sunday-service.png',
      downloaded: true,
    ),
    MediaItem(
      kind: MediaKind.sermon,
      title: 'Work As Though Unto The Lord',
      meta: founder,
      image: 'assets/media/pure-word.jpg',
    ),
    MediaItem(
      kind: MediaKind.teaching,
      title: 'Pure Word',
      meta: 'Teaching series',
      image: 'assets/media/music.jpg',
    ),
    MediaItem(
      kind: MediaKind.podcast,
      title: 'TPM Live',
      meta: 'Streamed on YouTube · @TPMLIVE',
      image: 'assets/media/podcast.jpg',
    ),
  ];

  // ---- Events (from the website; several are genuinely undated) ----
  static const List<EventItem> events = [
    EventItem(
      tag: 'Upcoming Event',
      title: 'Holy Ghost Festival 2026',
      location: 'All branches',
      when: 'Date to be announced',
      description:
          'The annual Holy Ghost Festival hosted by $founder. Dates will be announced '
          'from the pastor’s office.',
      image: 'assets/photos/gathering.jpg',
    ),
    EventItem(
      tag: 'Camp',
      title: 'Sharpening Camp',
      location: 'To be announced',
      when: 'Date to be announced',
      description:
          'A set-apart season of teaching and consecration. Registration runs through '
          'your branch.',
      image: 'assets/photos/community.jpg',
    ),
    EventItem(
      day: 'FRI',
      month: 'Weekly',
      tag: 'Weekly Service',
      title: 'Love Therapy',
      location: 'All branches',
      when: 'Every Friday · 6:00 PM',
      description:
          'Our weekly Friday gathering. Come as you are, and bring someone who needs the '
          'family of God this week.',
      image: 'assets/photos/communion.jpg',
    ),
    EventItem(
      tag: 'Prayer',
      title: 'Corporate Prayer Night',
      location: 'All branches',
      when: 'Last Friday of every month',
      description: 'Every branch joins for a night of intercession.',
      image: 'assets/photos/prayer.jpg',
    ),
  ];

  // ---- Give ----
  static const List<GiveOption> giveOptions = [
    GiveOption(
      label: 'Tithe',
      blurb: 'Honour the Lord',
      icon: Icons.eco_rounded,
      tintBg: TpmColors.tintGreen,
      tintFg: TpmColors.green,
    ),
    GiveOption(
      label: 'Offering',
      blurb: 'Freewill gift',
      icon: Icons.card_giftcard_rounded,
      tintBg: TpmColors.tintBlue,
      tintFg: TpmColors.navy,
    ),
    GiveOption(
      label: 'Building',
      blurb: 'Church project',
      icon: Icons.account_balance_rounded,
      tintBg: TpmColors.tintAmber,
      tintFg: TpmColors.goldDeep,
    ),
    GiveOption(
      label: 'Partnership',
      blurb: 'Stand with us',
      icon: Icons.handshake_rounded,
      tintBg: TpmColors.tintViolet,
      tintFg: TpmColors.violet,
    ),
  ];

  /// The real giving channels advertised on the website.
  static const List<GivingChannel> givingChannels = [
    GivingChannel(
      name: 'MTN Mobile Money',
      logo: 'assets/give/mtn-momo.png',
      detail: 'Merchant details on the giving page',
    ),
    GivingChannel(
      name: 'Telecel Cash',
      logo: 'assets/give/telecel-cash.png',
      detail: 'Merchant details on the giving page',
    ),
    GivingChannel(
      name: 'Stanbic Bank',
      logo: 'assets/give/stanbic-bank.png',
      detail: 'Account details on the giving page',
    ),
  ];

  // ---- Branches: the nine SPRING congregations ----
  static const List<Branch> branches = [
    Branch(
      name: 'DAYSPRING',
      region: 'Head office',
      address: officeAddress,
      phone: officePhone,
      email: officeEmail,
    ),
    Branch(name: 'GLORYSPRING', region: 'Branch', address: 'Kumasi'),
    Branch(name: 'GOODNEWSSPRING', region: 'Branch', address: 'Kumasi'),
    Branch(name: 'FAITHSPRING', region: 'Branch', address: 'Kumasi'),
    Branch(name: 'LOYALTYSPRING', region: 'Branch', address: 'Kumasi'),
    Branch(name: 'GRACESPRING', region: 'Branch', address: 'Kumasi'),
    Branch(name: 'UNITYSPRING', region: 'Branch', address: 'Kumasi'),
    Branch(name: 'PEACESPRING', region: 'Branch', address: 'Kumasi'),
    Branch(name: 'SALVATIONSPRING', region: 'Branch', address: 'Kumasi'),
  ];

  static List<String> get branchNames => branches.map((b) => b.name).toList();

  // ---- Reference lists (backend/prisma/seed.js) ----
  static const List<String> memberStatuses = [
    'New Convert',
    'Regular Member',
    'Worker',
    'Leader',
  ];

  static const List<String> meetingTypes = [
    'LOUCS Report',
    'Basenia',
    'Friday Service',
    'General Meeting',
    'Tithe Collection',
    'Souls Won',
  ];

  static const List<String> fellowships = [
    'Transformed Men Fellowship',
    'Transformed Law',
    'Transformed Shepherds',
    'Transformed Couples',
    'Transformed Women Fellowship',
    'Transformed Youth Fellowship',
  ];

  static const List<String> basenias = [
    'HeavenSpring Basenia',
    'LoveSpring Basenia',
    'GraceSpring Basenia',
    'FaithSpring Basenia',
    'HopeSpring Basenia',
    'JoySpring Basenia',
    'PeaceSpring Basenia',
    'GlorySpring Basenia',
  ];

  /// Shown as "Worker Groups" in the portal.
  static const List<String> departments = [
    'Communion Stewards',
    'Ushering',
    'Protocol',
    'Hospitality and Welfare',
    'Pure Word',
    'Media and Publicity',
    'Music',
    'Theatre and Arts',
    'Finance',
    'Organizing',
    'Sounds and Technical',
    'Growth',
    'Literature',
    'Miscellaneous',
    "The Pastor's Office",
  ];

  static const List<String> composeTags = [
    'Upcoming Event',
    'Camp',
    'Weekly Service',
    'Conference',
    'Prayer',
  ];

  // ---- Books published by the ministry ----
  static const List<Book> books = [
    Book(
      title: 'Daily Drops of Transformation',
      author: 'Volume I · $founder',
      cover: 'assets/books/ddot-1.png',
    ),
    Book(
      title: 'Daily Drops of Transformation',
      author: 'Volume II · $founder',
      cover: 'assets/books/ddot-2.jpg',
    ),
    Book(
      title: 'Crossing the Red Sea',
      author: founder,
      cover: 'assets/books/red-sea.jpg',
    ),
    Book(
      title: 'New Believer’s Handbook',
      author: 'TPM Discipleship',
      cover: 'assets/books/cover-3.png',
    ),
    Book(
      title: 'Prayer & Fasting Guide',
      author: 'TPM Discipleship',
      cover: 'assets/books/cover-4.png',
    ),
    Book(
      title: 'Worker’s Commitment Guide',
      author: 'TPM Discipleship',
      cover: 'assets/books/cover-5.png',
    ),
    Book(
      title: 'TPM Welcome Guide',
      author: 'TPM Discipleship',
      cover: 'assets/books/cover-6.png',
    ),
  ];

  // ---- Profile (placeholder person, real reference values) ----
  static const List<ProfileField> profileFields = [
    ProfileField(label: 'Full name', value: fullName),
    ProfileField(label: 'Email', value: 'ama.b@email.com'),
    ProfileField(label: 'Phone', value: '+233 24 000 0000'),
    ProfileField(label: 'Branch', value: homeBranch),
    ProfileField(label: 'Fellowship', value: 'Transformed Women Fellowship'),
  ];

  static const List<NotificationSetting> notificationSettings = [
    NotificationSetting(label: 'Service reminders', enabled: true),
    NotificationSetting(label: 'New sermons', enabled: true),
    NotificationSetting(label: 'Events & camps', enabled: false),
  ];

  // ---- Leader dashboard (figures are invented; no real data source) ----
  static const String leaderBranch = 'DAYSPRING';

  static const List<StatTile> leaderStats = [
    StatTile(label: 'Attendance', value: '238', icon: Icons.groups_rounded, trend: '+9%'),
    StatTile(label: 'Tithe (GHS)', value: '18.4k', icon: Icons.savings_rounded, trend: '+4%'),
    StatTile(label: 'Souls won', value: '12', icon: Icons.volunteer_activism_rounded, trend: '+3'),
    StatTile(label: 'Members', value: '486', icon: Icons.contacts_rounded, trend: '+5'),
  ];

  static const List<int> attendanceTrend = [190, 200, 196, 218, 208, 230, 232, 238];

  static const List<double> titheWeeks = [10.4, 12.8, 9.6, 15.6, 14.0, 18.4];
  static const double titheAxisMax = 20.0;
  static const List<String> weekLabels = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6'];

  static const List<ReportField> reportFields = [
    ReportField(label: 'Total attendance', hint: 'e.g. 238', icon: Icons.groups_rounded),
    ReportField(label: 'Tithe collected (GHS)', hint: 'e.g. 18400', icon: Icons.savings_rounded),
    ReportField(label: 'Souls won', hint: 'e.g. 12', icon: Icons.volunteer_activism_rounded),
    ReportField(label: 'First-time visitors', hint: 'e.g. 9', icon: Icons.person_add_rounded),
  ];

  static const List<ReportField> newMemberFields = [
    ReportField(label: 'Full name', hint: 'e.g. Kwame Asante', icon: Icons.person_rounded),
    ReportField(label: 'Phone', hint: '+233 …', icon: Icons.phone_rounded),
    ReportField(label: 'Email (optional)', hint: 'name@email.com', icon: Icons.email_rounded),
    ReportField(label: 'Worker group', hint: 'e.g. Ushering, Music', icon: Icons.diversity_3_rounded),
  ];

  // ---- Registry (invented people; the real system seeds none) ----
  static const String registrySubtitle = 'DAYSPRING · 486 members';

  static final List<MemberRecord> members = [
    MemberRecord(
      name: 'Kwame Asante',
      group: 'Ushering',
      status: 'Worker',
      avatarColor: avatarFor(0),
      branch: 'DAYSPRING',
    ),
    MemberRecord(
      name: 'Abena Osei',
      group: 'Music',
      status: 'Regular Member',
      avatarColor: avatarFor(1),
      branch: 'DAYSPRING',
    ),
    MemberRecord(
      name: 'Yaw Darko',
      group: 'Growth',
      status: 'New Convert',
      avatarColor: avatarFor(2),
      branch: 'DAYSPRING',
    ),
    MemberRecord(
      name: 'Efua Mensah',
      group: 'Transformed Women Fellowship',
      status: 'Regular Member',
      avatarColor: avatarFor(3),
      branch: 'DAYSPRING',
    ),
    MemberRecord(
      name: 'Kojo Antwi',
      group: 'Media and Publicity',
      status: 'Worker',
      avatarColor: avatarFor(4),
      branch: 'DAYSPRING',
    ),
    MemberRecord(
      name: 'Adjoa Frimpong',
      group: 'Pure Word',
      status: 'Leader',
      avatarColor: avatarFor(0),
      branch: 'DAYSPRING',
    ),
  ];

  /// Status pill colouring in the registry — foreground then background.
  static const Map<String, (Color, Color)> statusColors = {
    'New Convert': (TpmColors.portalGold, Color(0x1FC9A84C)),
    'Regular Member': (TpmColors.success, Color(0x1F4ADE80)),
    'Worker': (TpmColors.info, Color(0x1F60A5FA)),
    'Leader': (Color(0xFFC084FC), Color(0x1FC084FC)),
  };

  static (Color, Color) statusColor(String status) =>
      statusColors[status] ?? (TpmColors.portalGold, const Color(0x1FC9A84C));

  // ---- Administrator (figures invented; branch names real) ----
  static const List<StatTile> adminStats = [
    StatTile(label: 'Total members', value: '6,240', icon: Icons.groups_rounded, trend: '+3%'),
    StatTile(
      label: 'Weekly attendance',
      value: '3,180',
      icon: Icons.self_improvement_rounded,
      trend: '+6%',
    ),
    StatTile(label: 'Tithe (GHS)', value: '242k', icon: Icons.savings_rounded, trend: '+5%'),
    StatTile(
      label: 'Souls won (mo)',
      value: '146',
      icon: Icons.volunteer_activism_rounded,
      trend: '+18',
    ),
  ];

  static const List<BranchRank> branchRanks = [
    BranchRank(name: 'DAYSPRING', value: 486, fraction: 1.0),
    BranchRank(name: 'GLORYSPRING', value: 412, fraction: 0.85),
    BranchRank(name: 'FAITHSPRING', value: 305, fraction: 0.63),
    BranchRank(name: 'GRACESPRING', value: 268, fraction: 0.55),
  ];

  static final List<ApprovalRequest> approvals = [
    ApprovalRequest(
      name: 'Abena Osei',
      branch: 'DAYSPRING',
      field: 'Phone',
      oldValue: '+233 24 111 1111',
      newValue: '+233 20 222 2222',
      avatarColor: avatarFor(1),
    ),
    ApprovalRequest(
      name: 'Yaw Darko',
      branch: 'GLORYSPRING',
      field: 'Branch',
      oldValue: 'GLORYSPRING',
      newValue: 'FAITHSPRING',
      avatarColor: avatarFor(2),
    ),
    ApprovalRequest(
      name: 'Efua Mensah',
      branch: 'PEACESPRING',
      field: 'Email',
      oldValue: 'efua@old.com',
      newValue: 'efua.m@email.com',
      avatarColor: avatarFor(3),
    ),
  ];

  static const List<String> accessTabs = ['Members', 'Leaders', 'Admins'];

  static final List<AccessUser> accessList = [
    AccessUser(
      name: 'Ama Boateng',
      branch: 'DAYSPRING',
      role: 'Member',
      avatarColor: avatarFor(0),
    ),
    AccessUser(
      name: 'Kwame Asante',
      branch: 'DAYSPRING',
      role: 'Worker',
      avatarColor: avatarFor(1),
    ),
    AccessUser(
      name: 'Grace Mensah',
      branch: 'GLORYSPRING',
      role: 'Leader',
      avatarColor: avatarFor(2),
    ),
    AccessUser(
      name: 'TPM Admin',
      branch: "The Pastor's Office",
      role: 'Admin',
      avatarColor: avatarFor(3),
    ),
  ];

  static const List<ManageListEntry> manageLists = [
    ManageListEntry(label: 'Leaders directory', count: 'Pastors & branch leaders',
        icon: Icons.badge_rounded),
    ManageListEntry(label: 'Branches', count: '9 branches', icon: Icons.location_on_rounded),
    ManageListEntry(label: 'Worker groups', count: '15 departments',
        icon: Icons.diversity_3_rounded),
    ManageListEntry(label: 'Fellowships & Basenias', count: '6 fellowships · 8 basenias',
        icon: Icons.groups_2_rounded),
  ];

  /// Splash collage — five real photographs behind the logo lockup.
  static const List<String> splashCollage = [
    'assets/photos/worship.jpg',
    'assets/photos/congregation.jpg',
    'assets/photos/choir.jpg',
    'assets/photos/prayer.jpg',
    'assets/photos/community.jpg',
  ];
}
