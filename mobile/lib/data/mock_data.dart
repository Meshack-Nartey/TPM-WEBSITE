import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/tpm_theme.dart';

/// Seed content for the prototype.
///
/// Everything here is placeholder copy carried over from the design board so
/// the 29 screens can be walked end to end without a backend. Names, figures
/// and sermon titles are invented; only the photography, book covers and
/// giving-channel marks are real TPM assets. Swap this file for the API
/// client once the Spring Boot service is serving live data.
class MockData {
  const MockData._();

  // ---- Signed-in person ----
  static const String firstName = 'Ama';
  static const String fullName = 'Ama Boateng';
  static const String initials = 'AB';
  static const String homeBranch = 'Kumasi Central';

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
  };

  static (Color, Color) tagColor(String tag) =>
      tagColors[tag] ?? (TpmColors.navy, TpmColors.tintIndigo);

  // ---- Home carousel ----
  static const List<Announcement> carousel = [
    Announcement(
      tag: 'Conference',
      title: 'Kingdom Advance 2026',
      meta: 'Aug 14–16 · Main Auditorium',
    ),
    Announcement(
      tag: 'Weekly Service',
      title: 'Communion Sunday',
      meta: 'This Sunday · All branches',
    ),
    Announcement(
      tag: 'Camp',
      title: 'Youth Discipleship Camp',
      meta: 'Sep 5–8 · Aburi Hills',
    ),
  ];

  static const String serviceLabel = 'Sun · 9:00 AM';
  static const String serviceTimes = 'Sun 9:00 AM · Wed 6:00 PM · Fri 6:30 PM';

  // ---- Media ----
  static const MediaItem featured = MediaItem(
    kind: MediaKind.sermon,
    title: 'The Weight of Glory',
    meta: 'Rev. Daniel Owusu · 42 min',
    image: 'assets/media/sunday-service.png',
    downloaded: true,
  );

  static const List<String> mediaFilters = ['All', 'Sermons', 'Teachings', 'Podcasts'];

  static const List<MediaItem> media = [
    MediaItem(
      kind: MediaKind.sermon,
      title: 'The Weight of Glory',
      meta: 'Rev. Daniel Owusu · 42 min',
      image: 'assets/media/sunday-service.png',
      downloaded: true,
    ),
    MediaItem(
      kind: MediaKind.teaching,
      title: 'Foundations of Faith',
      meta: 'Pastor Grace Mensah · 28 min',
      image: 'assets/media/pure-word.jpg',
    ),
    MediaItem(
      kind: MediaKind.podcast,
      title: 'Everyday Discipleship',
      meta: 'TPM Voices · Ep. 12 · 35 min',
      image: 'assets/media/podcast.jpg',
    ),
    MediaItem(
      kind: MediaKind.sermon,
      title: 'A Living Sacrifice',
      meta: 'Rev. Daniel Owusu · 39 min',
      image: 'assets/media/music.jpg',
    ),
  ];

  // ---- Events ----
  static const List<EventItem> events = [
    EventItem(
      day: '14',
      month: 'Aug',
      tag: 'Conference',
      title: 'Kingdom Advance 2026',
      location: 'Main Auditorium, Kumasi',
      when: 'Aug 14–16, 2026 · 5:00 PM',
      description:
          'Three days of teaching, worship and impartation as we press into a new season. '
          'Guest ministers from across the region join us for Kingdom Advance.',
      image: 'assets/photos/gathering.jpg',
    ),
    EventItem(
      day: '05',
      month: 'Sep',
      tag: 'Camp',
      title: 'Youth Discipleship Camp',
      location: 'Aburi Hills Retreat',
      when: 'Sep 5–8, 2026 · All day',
      description:
          'A four-day residential camp for ages 13–25. Registration is required; talk to '
          'your branch youth leader for details and transport.',
      image: 'assets/photos/community.jpg',
    ),
    EventItem(
      day: '21',
      month: 'Jul',
      tag: 'Weekly Service',
      title: 'Communion Sunday',
      location: 'All branches',
      when: 'Sun Jul 21 · 9:00 AM',
      description:
          'We gather at the Lord’s table across every branch. Come prepared in heart '
          'for a time of remembrance and thanksgiving.',
      image: 'assets/photos/communion.jpg',
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

  /// The real giving channels already advertised on the website.
  static const List<GivingChannel> givingChannels = [
    GivingChannel(
      name: 'MTN Mobile Money',
      logo: 'assets/give/mtn-momo.png',
      detail: 'Merchant ID on the giving page',
    ),
    GivingChannel(
      name: 'Telecel Cash',
      logo: 'assets/give/telecel-cash.png',
      detail: 'Merchant ID on the giving page',
    ),
    GivingChannel(
      name: 'Stanbic Bank',
      logo: 'assets/give/stanbic-bank.png',
      detail: 'Account details on the giving page',
    ),
  ];

  // ---- News feed ----
  static const List<Announcement> newsFeed = [
    Announcement(
      tag: 'Conference',
      title: 'Kingdom Advance 2026 registration is open',
      excerpt: 'Secure your seat for three days of teaching and worship this August.',
      date: '2 days ago',
      body:
          'Registration for Kingdom Advance 2026 is now open across all branches. This year '
          'we welcome guest ministers from across the region for three days of teaching, '
          'worship and impartation. Speak with your branch office to reserve your place and '
          'arrange transport.',
    ),
    Announcement(
      tag: 'Weekly Service',
      title: 'Communion Sunday this week',
      excerpt: 'We gather at the Lord’s table across every branch this Sunday.',
      date: '4 days ago',
      body:
          'This Sunday is Communion Sunday. Every branch will observe the Lord’s table '
          'together. Come prepared in heart, and invite someone who needs the family of God '
          'this week.',
    ),
    Announcement(
      tag: 'Camp',
      title: 'Youth Camp — early-bird closes Friday',
      excerpt: 'Ages 13–25. Register through your branch youth leader.',
      date: '1 week ago',
      body:
          'The early-bird rate for Youth Discipleship Camp closes this Friday. The camp runs '
          'Sep 5–8 at the Aburi Hills Retreat. Register through your branch youth leader.',
    ),
    Announcement(
      tag: 'Upcoming Event',
      title: 'Leaders’ prayer & planning retreat',
      excerpt: 'A day set apart for our branch leaders and workers.',
      date: '1 week ago',
      body:
          'All branch leaders and workers are invited to a day of prayer and planning as we '
          'look toward the next quarter. Details will follow from the pastor’s office.',
    ),
  ];

  // ---- Branches ----
  static const List<Branch> branches = [
    Branch(name: 'Kumasi Central', region: 'Ashanti', address: 'Adum High St, Kumasi'),
    Branch(name: 'Accra Ridge', region: 'Greater Accra', address: '14 Independence Ave, Accra'),
    Branch(name: 'Cape Coast', region: 'Central', address: 'Chapel Sq, Cape Coast'),
  ];

  /// Offered in the register screen's home-branch picker.
  static const List<String> branchNames = [
    'Kumasi Central',
    'Accra Ridge',
    'Cape Coast',
    'Takoradi',
  ];

  // ---- Books ----
  static const List<Book> books = [
    Book(
      title: 'Daily Dose of Truth',
      author: 'Volume I · TPM Press',
      cover: 'assets/books/ddot-1.png',
    ),
    Book(
      title: 'Daily Dose of Truth',
      author: 'Volume II · TPM Press',
      cover: 'assets/books/ddot-2.jpg',
    ),
    Book(
      title: 'Crossing the Red Sea',
      author: 'TPM Press',
      cover: 'assets/books/red-sea.jpg',
    ),
    Book(
      title: 'The Transformed Life',
      author: 'Rev. Daniel Owusu',
      cover: 'assets/books/cover-3.png',
    ),
    Book(
      title: 'Foundations',
      author: 'TPM Discipleship',
      cover: 'assets/books/cover-4.png',
    ),
    Book(
      title: 'Prayer that Moves',
      author: 'Pastor Grace Mensah',
      cover: 'assets/books/cover-5.png',
    ),
    Book(
      title: 'Stewardship',
      author: 'TPM Press',
      cover: 'assets/books/cover-6.png',
    ),
  ];

  // ---- Profile ----
  static const List<ProfileField> profileFields = [
    ProfileField(label: 'Full name', value: 'Ama Boateng'),
    ProfileField(label: 'Email', value: 'ama.b@email.com'),
    ProfileField(label: 'Phone', value: '+233 24 000 0000'),
    ProfileField(label: 'Branch', value: 'Kumasi Central'),
  ];

  static const List<NotificationSetting> notificationSettings = [
    NotificationSetting(label: 'Service reminders', enabled: true),
    NotificationSetting(label: 'New sermons', enabled: true),
    NotificationSetting(label: 'Events & camps', enabled: false),
  ];

  // ---- Leader dashboard ----
  static const String leaderBranch = 'Kumasi Central Branch';

  static const List<StatTile> leaderStats = [
    StatTile(label: 'Attendance', value: '238', icon: Icons.groups_rounded, trend: '+9%'),
    StatTile(label: 'Tithe (GHS)', value: '18.4k', icon: Icons.savings_rounded, trend: '+4%'),
    StatTile(label: 'Souls won', value: '12', icon: Icons.volunteer_activism_rounded, trend: '+3'),
    StatTile(label: 'Members', value: '486', icon: Icons.contacts_rounded, trend: '+5'),
  ];

  /// Eight-week attendance line, as a 0–1 fraction of the chart height.
  static const List<double> attendanceTrend = [0.33, 0.43, 0.38, 0.58, 0.52, 0.68, 0.63, 0.78];
  static const String attendanceAverage = 'avg 214';

  /// Six weeks of tithe, labelled W1–W6.
  static const List<double> titheBars = [0.52, 0.64, 0.48, 0.78, 0.70, 0.92];

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
    ReportField(label: 'Worker group', hint: 'e.g. Ushering, Choir', icon: Icons.diversity_3_rounded),
  ];

  static const List<String> memberStatuses = ['Member', 'Visitor', 'Worker'];

  // ---- Registry ----
  static const String registrySubtitle = 'Kumasi Central · 486 members';

  static final List<MemberRecord> members = [
    MemberRecord(
      name: 'Kwame Asante',
      group: 'Ushering Team',
      status: 'Worker',
      avatarColor: avatarFor(0),
    ),
    MemberRecord(
      name: 'Abena Osei',
      group: 'Choir',
      status: 'Member',
      avatarColor: avatarFor(1),
    ),
    MemberRecord(
      name: 'Yaw Darko',
      group: 'New convert',
      status: 'Visitor',
      avatarColor: avatarFor(2),
    ),
    MemberRecord(
      name: 'Efua Mensah',
      group: 'Women’s Fellowship',
      status: 'Member',
      avatarColor: avatarFor(3),
    ),
    MemberRecord(
      name: 'Kojo Antwi',
      group: 'Media Team',
      status: 'Worker',
      avatarColor: avatarFor(4),
    ),
    MemberRecord(
      name: 'Adjoa Frimpong',
      group: 'Prayer Team',
      status: 'Member',
      avatarColor: avatarFor(0),
    ),
  ];

  /// Status pill colouring in the registry — foreground then background.
  static const Map<String, (Color, Color)> statusColors = {
    'Member': (TpmColors.success, Color(0x1F4ADE80)),
    'Visitor': (TpmColors.portalGold, Color(0x1FC9A84C)),
    'Worker': (TpmColors.info, Color(0x1F60A5FA)),
  };

  static (Color, Color) statusColor(String status) =>
      statusColors[status] ?? (TpmColors.portalGold, const Color(0x1FC9A84C));

  // ---- Administrator ----
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
    BranchRank(name: 'Kumasi Central', value: 486, fraction: 1.0),
    BranchRank(name: 'Accra Ridge', value: 412, fraction: 0.85),
    BranchRank(name: 'Cape Coast', value: 305, fraction: 0.63),
    BranchRank(name: 'Takoradi', value: 268, fraction: 0.55),
  ];

  static final List<ApprovalRequest> approvals = [
    ApprovalRequest(
      name: 'Abena Osei',
      branch: 'Kumasi Central',
      field: 'Phone',
      oldValue: '+233 24 111 1111',
      newValue: '+233 20 222 2222',
      avatarColor: avatarFor(1),
    ),
    ApprovalRequest(
      name: 'Yaw Darko',
      branch: 'Accra Ridge',
      field: 'Branch',
      oldValue: 'Accra Ridge',
      newValue: 'Cape Coast',
      avatarColor: avatarFor(2),
    ),
    ApprovalRequest(
      name: 'Efua Mensah',
      branch: 'Cape Coast',
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
      branch: 'Kumasi Central',
      role: 'Member',
      avatarColor: avatarFor(0),
    ),
    AccessUser(
      name: 'Kwame Asante',
      branch: 'Kumasi Central',
      role: 'Worker',
      avatarColor: avatarFor(1),
    ),
    AccessUser(
      name: 'Grace Mensah',
      branch: 'Accra Ridge',
      role: 'Leader',
      avatarColor: avatarFor(2),
    ),
    AccessUser(
      name: 'Daniel Owusu',
      branch: "Pastor's Office",
      role: 'Admin',
      avatarColor: avatarFor(3),
    ),
  ];

  static const List<ManageListEntry> manageLists = [
    ManageListEntry(label: 'Leaders directory', count: '14 leaders', icon: Icons.badge_rounded),
    ManageListEntry(label: 'Branches', count: '14 branches', icon: Icons.location_on_rounded),
    ManageListEntry(label: 'Worker groups', count: '9 groups', icon: Icons.diversity_3_rounded),
  ];

  static const List<String> composeTags = [
    'Upcoming Event',
    'Camp',
    'Weekly Service',
    'Conference',
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
