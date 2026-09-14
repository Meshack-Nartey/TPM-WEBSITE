import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Downloads an episode's mp3 into the app's own document storage, keyed by
/// the audio URL so re-opening the same episode recognises it's already
/// saved rather than re-downloading.
class AudioDownloader {
  const AudioDownloader();

  Future<String> _pathFor(String url) async {
    final documents = await getApplicationDocumentsDirectory();
    final downloads = Directory('${documents.path}/downloads');
    if (!await downloads.exists()) {
      await downloads.create(recursive: true);
    }
    return '${downloads.path}/${url.hashCode.toRadixString(16)}.mp3';
  }

  Future<bool> isDownloaded(String url) async {
    return File(await _pathFor(url)).exists();
  }

  /// Emits progress from 0 to 1 as bytes arrive, ending at 1 once the file
  /// is fully written to disk.
  Stream<double> download(String url) async* {
    final request = http.Request('GET', Uri.parse(url));
    final response = await request.send();
    final total = response.contentLength ?? 0;
    var received = 0;

    final sink = File(await _pathFor(url)).openWrite();
    try {
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        yield total > 0 ? received / total : 0;
      }
      await sink.flush();
    } finally {
      await sink.close();
    }
    yield 1;
  }
}
