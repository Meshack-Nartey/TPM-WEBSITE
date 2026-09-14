/// Web build's stand-in — the app never runs as a web app in production
/// (see `audio_download.dart`), so this only needs to compile, not work.
class AudioDownloader {
  const AudioDownloader();

  Future<bool> isDownloaded(String url) async => false;

  Stream<double> download(String url) {
    throw UnsupportedError('Downloads are not supported on this platform.');
  }
}
