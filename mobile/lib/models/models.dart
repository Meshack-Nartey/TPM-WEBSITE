import 'package:flutter/material.dart';

/// Who is holding the phone. Drives which home screen you land on, whether the
/// portal entry appears under More, and which bottom bar is shown.
enum AppRole { guest, member, leader, admin }

extension AppRoleX on AppRole {
  String get label => switch (this) {
    AppRole.guest => 'Guest',
    AppRole.member => 'Member',
    AppRole.leader => 'Church Leader',
    AppRole.admin => 'Administrator',
  };

  String get blurb => switch (this) {
    AppRole.guest => 'Browse, not signed in',
    AppRole.member => 'Signed-in individual',
    AppRole.leader => 'One branch only',
    AppRole.admin => "Pastor's office",
  };

  /// Leaders and admins can cross into the work portal; members cannot.
  bool get hasPortal => this == AppRole.leader || this == AppRole.admin;
}

/// Maps the API's `Role` enum ('MEMBER' | 'LEADER' | 'ADMIN') onto [AppRole].
AppRole roleFromApi(String? value) => switch (value) {
  'ADMIN' => AppRole.admin,
  'LEADER' => AppRole.leader,
  'MEMBER' => AppRole.member,
  _ => AppRole.guest,
};

/// The signed-in person, as the API returns them (`publicUser` in
/// `backend/src/lib/serialize.js` — everything but the password hash).
class AppUser {
  const AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.role,
    this.branch,
    this.phone,
    this.department,
    this.fellowship,
    this.dateJoined,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final AppRole role;
  final String? branch;

  // The registration form doesn't collect these yet, so a real account's
  // values are the schema defaults ('') until that changes — treated the
  // same as null wherever they're displayed.
  final String? phone;
  final String? department;
  final String? fellowship;
  final String? dateJoined;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    fullName: json['fullName'] as String? ?? '',
    email: json['email'] as String? ?? '',
    role: roleFromApi(json['role'] as String?),
    branch: json['branch'] as String?,
    phone: json['phone'] as String?,
    department: json['department'] as String?,
    fellowship: json['fellowship'] as String?,
    dateJoined: json['dateJoined'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'fullName': fullName,
    'email': email,
    'role': role.name.toUpperCase(),
    'branch': branch,
    'phone': phone,
    'department': department,
    'fellowship': fellowship,
    'dateJoined': dateJoined,
  };
}

/// The first letter of up to the first two words of a name — used for the
/// avatar initials on the home greeting and the profile screen alike.
String initialsOf(String fullName) {
  final parts = fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty);
  return parts.take(2).map((p) => p[0].toUpperCase()).join();
}

class Announcement {
  const Announcement({
    this.id,
    required this.tag,
    required this.title,
    this.excerpt = '',
    this.date = '',
    this.body = '',
    this.flyer,
  });

  /// Null for the design board's mock entries — set for anything that came
  /// from the real API.
  final String? id;

  final String tag;
  final String title;

  /// Longer teaser used in the news feed list.
  final String excerpt;
  final String date;
  final String body;

  /// The event's printed flyer, when one exists — shown in place of the tag
  /// pill so the announcement reads the same as it does on the website. Real
  /// announcements never carry one; the API has no field for it yet.
  final String? flyer;

  /// The real API only stores one block of text (`body`) — the list's
  /// shorter teaser is derived from it here rather than being a second
  /// field someone has to fill in separately.
  factory Announcement.fromJson(Map<String, dynamic> json) {
    final body = json['body'] as String? ?? '';
    const excerptLength = 120;
    final excerpt = body.length > excerptLength
        ? '${body.substring(0, excerptLength).trimRight()}…'
        : body;
    return Announcement(
      id: json['id'] as String?,
      tag: json['tag'] as String? ?? '',
      title: json['title'] as String? ?? '',
      excerpt: excerpt,
      date: json['date'] as String? ?? '',
      body: body,
    );
  }
}

enum MediaKind { sermon, teaching, podcast }

extension MediaKindX on MediaKind {
  String get label => switch (this) {
    MediaKind.sermon => 'Sermon',
    MediaKind.teaching => 'Teaching',
    MediaKind.podcast => 'Podcast',
  };

  IconData get icon => switch (this) {
    MediaKind.sermon => Icons.play_arrow_rounded,
    MediaKind.teaching => Icons.school_rounded,
    MediaKind.podcast => Icons.mic_rounded,
  };
}

class MediaItem {
  const MediaItem({
    required this.kind,
    required this.title,
    required this.meta,
    required this.image,
    this.downloaded = false,
    this.youtubeId,
    this.audioUrl,
    this.thumbnailUrl,
    this.duration,
  });

  final MediaKind kind;
  final String title;
  final String meta;
  final String image;

  /// Saved for offline — shows a green check instead of the download arrow.
  final bool downloaded;

  /// The real video's ID on `@TPMLIVE`, when this message has one. Plays in
  /// an embedded YouTube player rather than handing off to the YouTube app —
  /// but per YouTube's terms that also means it can never be downloaded, so
  /// [downloaded] and the download action are meaningless when this is set.
  final String? youtubeId;

  /// Direct mp3 URL from the ministry's audio-message podcast feed (hosted
  /// free on Anchor/Spotify's own CDN). Unlike YouTube, this one genuinely
  /// can be downloaded for offline listening.
  final String? audioUrl;

  /// The episode's own artwork from the podcast feed (Anchor/Spotify's
  /// CDN) — the real cover art the show was published with, rather than
  /// [image]'s generic stand-in photo.
  final String? thumbnailUrl;

  /// The feed's own `itunes:duration`, when it has one — used in place of
  /// the audio player's own reading, which some of these episodes' mp3s
  /// (missing a proper VBR header) leave it under-reporting by up to an
  /// hour on files over about 40 minutes long.
  final Duration? duration;

  bool get hasVideo => youtubeId != null;
  bool get hasAudio => audioUrl != null;
}

class EventItem {
  const EventItem({
    this.day,
    this.month,
    required this.tag,
    required this.title,
    required this.location,
    required this.when,
    required this.description,
    required this.image,
  });

  /// Null when the date has not been announced. Several of the ministry's
  /// events are genuinely "Date: TBA", and showing an invented day would be
  /// worse than showing none.
  final String? day;
  final String? month;

  final String tag;
  final String title;
  final String location;
  final String when;
  final String description;
  final String image;

  bool get isDated => day != null && month != null;
}

class GiveOption {
  const GiveOption({
    required this.label,
    required this.blurb,
    required this.icon,
    required this.tintBg,
    required this.tintFg,
  });

  final String label;
  final String blurb;
  final IconData icon;
  final Color tintBg;
  final Color tintFg;
}

class GivingChannel {
  const GivingChannel({
    required this.name,
    required this.logo,
    required this.accountName,
    required this.number,
    required this.numberLabel,
    this.isBank = false,
  });

  final String name;
  final String logo;

  /// Whose account it is. Not always the ministry — the Telecel Cash line is
  /// held in the founder's name, and saying so avoids a giver second-guessing
  /// the name that comes up on their phone.
  final String accountName;

  /// Grouped for reading (`055 447 6730`), not for dialling.
  final String number;

  /// What the number is called on this channel — a MoMo Pay ID, a phone
  /// number and a bank account number are not interchangeable.
  final String numberLabel;

  final bool isBank;

  /// Spaces stripped, so what lands on the clipboard can be pasted straight
  /// into a transfer form.
  String get copyValue => number.replaceAll(' ', '');
}

class Branch {
  const Branch({
    required this.name,
    required this.region,
    required this.address,
    this.phone,
    this.email,
  });

  final String name;
  final String region;
  final String address;
  final String? phone;
  final String? email;
}

/// One of the fifteen worker groups members can serve in — the website's
/// "Get Involved" tabs, ported over with the same photo and copy.
class WorkerGroup {
  const WorkerGroup({
    required this.name,
    required this.photo,
    required this.blurb,
  });

  final String name;
  final String photo;
  final String blurb;
}

/// One of the ministry's weekly gatherings.
class ServiceTime {
  const ServiceTime({
    required this.name,
    required this.day,
    required this.time,
  });

  final String name;
  final String day;
  final String time;
}

class Book {
  const Book({required this.title, required this.author, required this.cover});

  final String title;
  final String author;
  final String cover;
}

/// A person in the branch registry. Not necessarily a portal account holder —
/// leaders enter visitors and members who never sign in.
class MemberRecord {
  const MemberRecord({
    required this.name,
    required this.group,
    required this.status,
    required this.avatarColor,
    this.branch = 'DAYSPRING',
    this.since = '2021',
    this.phone = '+233 24 000 0000',
    this.email = 'member@email.com',
    this.joined = 'March 2021',
    this.attendance = const [true, true, false, true, true, true],
  });

  final String name;
  final String group;

  /// One of the ministry's four: New Convert, Regular Member, Worker, Leader.
  final String status;
  final Color avatarColor;
  final String branch;
  final String since;
  final String phone;
  final String email;
  final String joined;

  /// Last six weeks — true is present.
  final List<bool> attendance;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.map((w) => w[0]).take(2).join();
  }
}

/// A person in the branch registry, as `backend/src/routes/members.routes.js`
/// returns them — the real record [MemberRecord] stands in for on the design
/// board.
class Member {
  const Member({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.fullName,
    required this.dob,
    required this.gender,
    required this.phone,
    required this.email,
    required this.address,
    required this.branch,
    required this.department,
    required this.fellowship,
    required this.dateJoined,
    required this.membershipStatus,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
  });

  final String id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String fullName;
  final String dob;
  final String gender;
  final String phone;
  final String email;
  final String address;
  final String branch;
  final String department;
  final String fellowship;
  final String dateJoined;
  final String membershipStatus;
  final String emergencyContactName;
  final String emergencyContactPhone;

  factory Member.fromJson(Map<String, dynamic> json) => Member(
    id: json['id'] as String,
    firstName: json['firstName'] as String? ?? '',
    middleName: json['middleName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    fullName: json['fullName'] as String? ?? '',
    dob: json['dob'] as String? ?? '',
    gender: json['gender'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String? ?? '',
    address: json['address'] as String? ?? '',
    branch: json['branch'] as String? ?? '',
    department: json['department'] as String? ?? '',
    fellowship: json['fellowship'] as String? ?? '',
    dateJoined: json['dateJoined'] as String? ?? '',
    membershipStatus: json['membershipStatus'] as String? ?? '',
    emergencyContactName: json['emergencyContactName'] as String? ?? '',
    emergencyContactPhone: json['emergencyContactPhone'] as String? ?? '',
  );

  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }
}

/// A meeting/attendance/tithe/souls record a leader submits, as
/// `backend/src/routes/reports.routes.js` returns it.
class ReportRecord {
  const ReportRecord({
    required this.id,
    required this.meetingType,
    required this.branch,
    required this.date,
    required this.attMale,
    required this.attFemale,
    required this.tithe,
    required this.soulsMale,
    required this.soulsFemale,
    required this.notes,
  });

  final String id;
  final String meetingType;
  final String branch;
  final String date;
  final int attMale;
  final int attFemale;
  final double tithe;
  final int soulsMale;
  final int soulsFemale;
  final String notes;

  int get attendance => attMale + attFemale;
  int get souls => soulsMale + soulsFemale;

  factory ReportRecord.fromJson(Map<String, dynamic> json) => ReportRecord(
    id: json['id'] as String? ?? '',
    meetingType: json['meetingType'] as String? ?? '',
    branch: json['branch'] as String? ?? '',
    date: json['date'] as String? ?? '',
    attMale: (json['attMale'] as num?)?.toInt() ?? 0,
    attFemale: (json['attFemale'] as num?)?.toInt() ?? 0,
    tithe: (json['tithe'] as num?)?.toDouble() ?? 0,
    soulsMale: (json['soulsMale'] as num?)?.toInt() ?? 0,
    soulsFemale: (json['soulsFemale'] as num?)?.toInt() ?? 0,
    notes: json['notes'] as String? ?? '',
  );
}

/// The leader/admin dashboard's real aggregates, from
/// `backend/src/routes/statistics.routes.js` — scoped to the caller's own
/// branch for a leader, church-wide for an admin.
class DashboardStatistics {
  const DashboardStatistics({
    required this.totalMembers,
    required this.attendanceThisWeek,
    required this.titheThisMonth,
    required this.soulsWon,
    required this.attendanceTrend,
  });

  final int totalMembers;
  final int attendanceThisWeek;
  final double titheThisMonth;
  final int soulsWon;

  /// Headcount for each of the most recent distinct report dates — not
  /// necessarily calendar weeks, just however often reports actually land.
  final List<int> attendanceTrend;

  factory DashboardStatistics.fromJson(Map<String, dynamic> json) {
    final stats = json['statistics'] as Map<String, dynamic>? ?? const {};
    final trend = json['attendanceTrends'] as Map<String, dynamic>? ?? const {};
    final data = trend['data'] as List? ?? const [];
    return DashboardStatistics(
      totalMembers: (stats['totalMembers'] as num?)?.toInt() ?? 0,
      attendanceThisWeek: (stats['attendanceThisWeek'] as num?)?.toInt() ?? 0,
      titheThisMonth: (stats['titheThisMonth'] as num?)?.toDouble() ?? 0,
      soulsWon: (stats['soulsWon'] as num?)?.toInt() ?? 0,
      attendanceTrend: data.map((v) => (v as num?)?.toInt() ?? 0).toList(),
    );
  }
}

/// A member-initiated change to their own details, waiting on the pastor's
/// office to approve or reject it.
class ApprovalRequest {
  const ApprovalRequest({
    required this.name,
    required this.branch,
    required this.field,
    required this.oldValue,
    required this.newValue,
    required this.avatarColor,
  });

  final String name;
  final String branch;
  final String field;
  final String oldValue;
  final String newValue;
  final Color avatarColor;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.map((w) => w[0]).take(2).join();
  }
}

class AccessUser {
  const AccessUser({
    required this.name,
    required this.branch,
    required this.role,
    required this.avatarColor,
  });

  final String name;
  final String branch;
  final String role;
  final Color avatarColor;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.map((w) => w[0]).take(2).join();
  }
}

class StatTile {
  const StatTile({
    required this.label,
    required this.value,
    required this.icon,
    this.trend,
    this.up = true,
  });

  final String label;
  final String value;
  final IconData icon;

  /// A "vs last period" change, e.g. "+9%" — null when there's nothing to
  /// compare against (a real figure with no prior-period aggregate yet).
  final String? trend;
  final bool up;
}

class BranchRank {
  const BranchRank({
    required this.name,
    required this.value,
    required this.fraction,
  });

  final String name;
  final int value;

  /// 0–1, relative to the strongest branch.
  final double fraction;
}

class ReportField {
  const ReportField({
    required this.label,
    required this.hint,
    required this.icon,
  });

  final String label;
  final String hint;
  final IconData icon;
}

/// Where a weekly report has got to on its way to the office. Leaders work in
/// places with patchy signal, so queued and syncing are first-class states.
enum SyncStatus { idle, queued, syncing, synced }

class ProfileField {
  const ProfileField({required this.label, required this.value});

  final String label;
  final String value;
}

class NotificationSetting {
  const NotificationSetting({required this.label, required this.enabled});

  final String label;
  final bool enabled;
}

class ManageListEntry {
  const ManageListEntry({
    required this.label,
    required this.count,
    required this.icon,
  });

  final String label;
  final String count;
  final IconData icon;
}
