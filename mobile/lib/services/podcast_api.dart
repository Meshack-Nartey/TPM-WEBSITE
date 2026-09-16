import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../models/models.dart';

/// Thrown when the feed can't be reached or doesn't parse as RSS.
class PodcastApiException implements Exception {
  PodcastApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Reads the ministry's audio-message podcast feed — published free to
/// Anchor/Spotify for Podcasters, so every episode's actual mp3 lives on
/// their CDN at no hosting cost to TPM. This is the real audio-message
/// library; `MockData.media`'s sermon items are a placeholder until this
/// call is wired into the Watch & Listen screen.
class PodcastApi {
  const PodcastApi({this.feedUrl = 'https://anchor.fm/s/981d59f0/podcast/rss'});

  final String feedUrl;

  /// Newest-first. [limit] caps how many of the feed's (currently ~1,300)
  /// episodes to parse — set high enough to cover the whole feed, so search
  /// on the Watch & Listen screen can reach every episode, not just the
  /// most recent page of them.
  Future<List<MediaItem>> fetchEpisodes({int limit = 5000}) async {
    final http.Response response;
    try {
      response = await http
          .get(Uri.parse(feedUrl))
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw PodcastApiException("Can't reach the podcast feed right now.");
    }

    if (response.statusCode >= 400) {
      throw PodcastApiException('The podcast feed returned an error.');
    }

    final XmlDocument document;
    try {
      document = XmlDocument.parse(response.body);
    } catch (_) {
      throw PodcastApiException(
        "The podcast feed didn't come back as valid RSS.",
      );
    }

    final items = document.findAllElements('item').take(limit);
    final episodes = <MediaItem>[];

    for (final item in items) {
      final title = _child(item, 'title')?.innerText.trim();
      final audioUrl = _child(item, 'enclosure')?.getAttribute('url');
      if (title == null || title.isEmpty || audioUrl == null) continue;

      episodes.add(
        MediaItem(
          kind: MediaKind.podcast,
          title: title,
          meta: _formatDate(_child(item, 'pubDate')?.innerText),
          // Falls back to this asset if the episode has no artwork of its
          // own, or if that network image fails to load — see BrandedPhoto.
          image: 'assets/media/podcast.jpg',
          audioUrl: audioUrl,
          thumbnailUrl: _child(item, 'image')?.getAttribute('href'),
          duration: _parseDuration(_child(item, 'duration')?.innerText),
          description: _cleanDescription(
            _child(item, 'description')?.innerText,
          ),
        ),
      );
    }

    return episodes;
  }

  /// Matches by local name only, so the `itunes:` namespace prefix on tags
  /// like `<itunes:duration>` doesn't need special-casing.
  XmlElement? _child(XmlElement parent, String localName) {
    for (final child in parent.childElements) {
      if (child.name.local == localName) return child;
    }
    return null;
  }

  /// RSS's `pubDate` is RFC 822 ("Mon, 31 Aug 2026 02:51:31 GMT"). Avoiding
  /// `dart:io`'s `HttpDate` here deliberately — it doesn't compile for web,
  /// and this same screen renders under `main_preview.dart`'s Chrome target.
  String _formatDate(String? pubDate) {
    if (pubDate == null) return '';
    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    final parts = pubDate.trim().split(RegExp(r'\s+'));
    // ['Mon,', '31', 'Aug', '2026', '02:51:31', 'GMT']
    if (parts.length < 4) return pubDate;
    final day = int.tryParse(parts[1]);
    final month = months[parts[2]];
    final year = parts[3];
    if (day == null || month == null) return pubDate;
    const monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${monthNames[month]} $day, $year';
  }

  /// Anchor/Spotify's `<description>` is written for the podcast apps that
  /// render it as HTML — `<p>`, `<br>`, the odd link. Strips markup down to
  /// plain text for display here, same as any other podcast client would.
  String? _cleanDescription(String? raw) {
    if (raw == null) return null;
    final withoutTags = raw
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#39;', "'")
        .replaceAll('&quot;', '"')
        .trim();
    return withoutTags.isEmpty ? null : withoutTags;
  }

  /// `itunes:duration` is either `HH:MM:SS`/`MM:SS`, or a bare seconds count
  /// — the spec allows both, and this feed's episodes use either depending
  /// on how they were uploaded.
  Duration? _parseDuration(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;

    final parts = trimmed.split(':').map(int.tryParse).toList();
    if (parts.any((p) => p == null)) return null;

    return switch (parts.length) {
      3 => Duration(hours: parts[0]!, minutes: parts[1]!, seconds: parts[2]!),
      2 => Duration(minutes: parts[0]!, seconds: parts[1]!),
      1 => Duration(seconds: parts[0]!),
      _ => null,
    };
  }
}
