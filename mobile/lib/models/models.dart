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
  });

  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final AppRole role;
  final String? branch;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: roleFromApi(json['role'] as String?),
        branch: json['branch'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'fullName': fullName,
        'email': email,
        'role': role.name.toUpperCase(),
        'branch': branch,
      };
}

class Announcement {
  const Announcement({
    required this.tag,
    required this.title,
    this.meta = '',
    this.excerpt = '',
    this.date = '',
    this.body = '',
    this.flyer,
  });

  final String tag;
  final String title;

  /// Short line under the title on the home carousel.
  final String meta;

  /// Longer teaser used in the news feed list.
  final String excerpt;
  final String date;
  final String body;

  /// The event's printed flyer, when one exists — shown in place of the tag
  /// pill so the announcement reads the same as it does on the website.
  final String? flyer;
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
  });

  final MediaKind kind;
  final String title;
  final String meta;
  final String image;

  /// Saved for offline — shows a green check instead of the download arrow.
  final bool downloaded;
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
  const GivingChannel({required this.name, required this.logo, required this.detail});

  final String name;
  final String logo;
  final String detail;
}

class Branch {
  const Branch({
    required this.name,
    required this.region,
    required this.address,
    this.phone,
    this.email,
    this.photo,
  });

  final String name;
  final String region;
  final String address;
  final String? phone;
  final String? email;

  /// The branch's resident pastor — shown as a small avatar on the card.
  final String? photo;
}

/// One of the fifteen worker groups members can serve in — the website's
/// "Get Involved" tabs, ported over with the same photo and copy.
class WorkerGroup {
  const WorkerGroup({required this.name, required this.photo, required this.blurb});

  final String name;
  final String photo;
  final String blurb;
}

/// One of the ministry's weekly gatherings.
class ServiceTime {
  const ServiceTime({required this.name, required this.day, required this.time});

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
    required this.trend,
    this.up = true,
  });

  final String label;
  final String value;
  final IconData icon;
  final String trend;
  final bool up;
}

class BranchRank {
  const BranchRank({required this.name, required this.value, required this.fraction});

  final String name;
  final int value;

  /// 0–1, relative to the strongest branch.
  final double fraction;
}

class ReportField {
  const ReportField({required this.label, required this.hint, required this.icon});

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
