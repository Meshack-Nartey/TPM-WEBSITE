/// Saves an episode's mp3 to disk for offline playback. Split by platform —
/// `dart:io` (used by the real implementation) doesn't exist on the web, and
/// this same player screen is rendered by `main_preview.dart`'s Chrome
/// target, so the web build gets a stub that reports nothing as downloaded.
library;

export 'audio_download_stub.dart' if (dart.library.io) 'audio_download_io.dart';
