import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../models/models.dart';

/// Thrown when the channel's video feed can't be reached or doesn't parse.
class YoutubeApiException implements Exception {
  YoutubeApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Reads the ministry's `@TPMLIVE` channel via YouTube's own free, keyless
/// uploads feed — no API key to manage, same shape of trade-off as
/// `PodcastApi`: whatever the channel publishes shows up here automatically,
/// livestreams included once they go up as a normal video. What this feed
/// can't do is flag a broadcast as "live right now" — YouTube only exposes
/// that through the quota-metered Data API, which this app doesn't use.
class YoutubeApi {
  const YoutubeApi({
    this.channelId = 'UCgQ4iAGKiRnPzVdz0ihSWXg', // @TPMLIVE
  });

  final String channelId;

  /// Newest-first. YouTube's feed caps at its own most recent ~15 uploads —
  /// there's no paging on the free feed, so [limit] can only narrow that,
  /// not extend it.
  Future<List<MediaItem>> fetchVideos({int limit = 15}) async {
    final uri = Uri.https('www.youtube.com', '/feeds/videos.xml', {
      'channel_id': channelId,
    });

    final http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 15));
    } catch (_) {
      throw YoutubeApiException("Can't reach the YouTube feed right now.");
    }

    if (response.statusCode >= 400) {
      throw YoutubeApiException('The YouTube feed returned an error.');
    }

    final XmlDocument document;
    try {
      document = XmlDocument.parse(response.body);
    } catch (_) {
      throw YoutubeApiException("The YouTube feed didn't come back as valid.");
    }

    final entries = document.findAllElements('entry').take(limit);
    final videos = <MediaItem>[];

    for (final entry in entries) {
      final title = _child(entry, 'title')?.innerText.trim();
      final videoId = _child(entry, 'videoId')?.innerText.trim();
      if (title == null ||
          title.isEmpty ||
          videoId == null ||
          videoId.isEmpty) {
        continue;
      }

      final group = _child(entry, 'group');
      final thumbnailUrl = group == null
          ? null
          : _child(group, 'thumbnail')?.getAttribute('url');

      videos.add(
        MediaItem(
          kind: MediaKind.sermon,
          title: title,
          meta: _formatDate(_child(entry, 'published')?.innerText),
          // Falls back to this asset if the thumbnail URL ever fails to
          // load — see BrandedPhoto.
          image: 'assets/media/sunday-service.png',
          youtubeId: videoId,
          thumbnailUrl: thumbnailUrl,
        ),
      );
    }

    return videos;
  }

  /// Matches by local name only, so the `yt:`/`media:` namespace prefixes
  /// (e.g. `<yt:videoId>`, `<media:thumbnail>`) don't need special-casing.
  XmlElement? _child(XmlElement parent, String localName) {
    for (final child in parent.childElements) {
      if (child.name.local == localName) return child;
    }
    return null;
  }

  /// `<published>` is a real ISO 8601 timestamp (unlike RSS's `pubDate`), so
  /// `DateTime.parse` handles it directly — no manual parsing needed.
  String _formatDate(String? published) {
    if (published == null) return '';
    final date = DateTime.tryParse(published);
    if (date == null) return '';
    const months = [
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
    return '${months[date.month]} ${date.day}, ${date.year}';
  }
}
