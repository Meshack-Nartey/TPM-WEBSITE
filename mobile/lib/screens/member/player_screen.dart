import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../models/models.dart';
import '../../services/audio_download.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

enum _DownloadState { idle, downloading, done }

/// Immersive playback. The one member screen that goes full-bleed dark, because
/// listening to a message should not compete with the rest of the app.
///
/// Dispatches to whichever real source the item actually has — an embedded
/// YouTube player, or real streamed audio — rather than one screen trying to
/// fake both.
class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key, required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    if (item.hasVideo) return _VideoPlayerHost(item: item);
    if (item.hasAudio) return _AudioPlayer(item: item);
    return _NoPlayableSource(item: item);
  }
}

/// Owns the [YoutubePlayerController]'s lifecycle — it must exist before
/// [_VideoPlayer] builds, and video items always carry a [MediaItem.youtubeId].
class _VideoPlayerHost extends StatefulWidget {
  const _VideoPlayerHost({required this.item});

  final MediaItem item;

  @override
  State<_VideoPlayerHost> createState() => _VideoPlayerHostState();
}

class _VideoPlayerHostState extends State<_VideoPlayerHost> {
  late final YoutubePlayerController _controller =
      YoutubePlayerController.fromVideoId(
        videoId: widget.item.youtubeId!,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
        ),
      );

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _VideoPlayer(item: widget.item, controller: _controller);
  }
}

/// Shown for a [MediaItem] with neither a video nor an audio source —
/// defensive only; every real item in the library carries one or the other.
class _NoPlayableSource extends StatelessWidget {
  const _NoPlayableSource({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.deepNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.white.withValues(alpha: 0.5),
                size: 40,
              ),
              const SizedBox(height: 14),
              Text(
                "This message doesn't have a playable source yet.",
                textAlign: TextAlign.center,
                style: TpmText.body(14, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              TpmOutlineButton(
                label: 'Go back',
                icon: Icons.arrow_back_rounded,
                foreground: Colors.white,
                background: Colors.white.withValues(alpha: 0.1),
                borderColor: Colors.white.withValues(alpha: 0.25),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Real streamed audio — the ministry's messages published free to
/// Anchor/Spotify for Podcasters (see `PodcastApi`). Genuinely downloadable,
/// unlike the YouTube path: it's just an mp3 URL.
class _AudioPlayer extends StatefulWidget {
  const _AudioPlayer({required this.item});

  final MediaItem item;

  @override
  State<_AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<_AudioPlayer> {
  static const _downloader = AudioDownloader();
  static const _speeds = [1.0, 1.25, 1.5, 1.75, 2.0, 0.5, 0.75];

  final AudioPlayer _player = AudioPlayer();
  _DownloadState _downloadState = _DownloadState.idle;
  double _downloadProgress = 0;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _player.setUrl(widget.item.audioUrl!);
    _player.play();
    _checkDownloaded();
  }

  Future<void> _checkDownloaded() async {
    final downloaded = await _downloader.isDownloaded(widget.item.audioUrl!);
    if (mounted && downloaded) {
      setState(() => _downloadState = _DownloadState.done);
    }
  }

  Future<void> _download() async {
    if (_downloadState != _DownloadState.idle) return;
    setState(() {
      _downloadState = _DownloadState.downloading;
      _downloadProgress = 0;
    });
    try {
      await for (final progress in _downloader.download(
        widget.item.audioUrl!,
      )) {
        if (!mounted) return;
        setState(() => _downloadProgress = progress);
      }
      if (mounted) setState(() => _downloadState = _DownloadState.done);
    } catch (_) {
      if (!mounted) return;
      setState(() => _downloadState = _DownloadState.idle);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't download this message. Try again."),
        ),
      );
    }
  }

  Future<void> _share() {
    return SharePlus.instance.share(
      ShareParams(
        text: '${widget.item.title}\n${widget.item.audioUrl}',
        subject: widget.item.title,
      ),
    );
  }

  void _cycleSpeed() {
    final next = _speeds[(_speeds.indexOf(_speed) + 1) % _speeds.length];
    setState(() => _speed = next);
    _player.setSpeed(next);
  }

  Future<void> _skip(int seconds) async {
    final duration = widget.item.duration ?? _player.duration;
    if (duration == null) return;
    var target = _player.position + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (target > duration) target = duration;
    await _player.seek(target);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            stops: [0, 0.6, 1],
            colors: [TpmColors.deepNavy, TpmColors.navy, TpmColors.blueDeep],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _GlassButton(
                      icon: Icons.expand_more_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'NOW PLAYING',
                      style: TpmText.eyebrow(
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 10,
                        tracking: 1.6,
                      ),
                    ),
                    _GlassButton(icon: Icons.ios_share_rounded, onTap: _share),
                  ],
                ),
                const Spacer(flex: 2),
                ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: SizedBox(
                    width: 230,
                    height: 230,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        BrandedPhoto(
                          asset: widget.item.image,
                          networkUrl: widget.item.thumbnailUrl,
                          scrimOpacity: 0,
                          goldOpacity: 0,
                        ),
                        StreamBuilder<bool>(
                          stream: _player.playingStream,
                          initialData: false,
                          builder: (context, snapshot) => Center(
                            child: Icon(
                              (snapshot.data ?? false)
                                  ? Icons.pause_rounded
                                  : widget.item.kind.icon,
                              size: 54,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  widget.item.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TpmText.display(24, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.item.meta,
                  style: TpmText.body(
                    13.5,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 28),
                _Scrubber(player: _player, knownDuration: widget.item.duration),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: _SpeedPill(speed: _speed, onTap: _cycleSpeed),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TransportButton(
                      icon: Icons.replay_10_rounded,
                      onTap: () => _skip(-10),
                    ),
                    const SizedBox(width: 26),
                    StreamBuilder<bool>(
                      stream: _player.playingStream,
                      initialData: _player.playing,
                      builder: (context, snapshot) {
                        final playing = snapshot.data ?? false;
                        return GestureDetector(
                          onTap: () =>
                              playing ? _player.pause() : _player.play(),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 34,
                              color: TpmColors.navy,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 26),
                    _TransportButton(
                      icon: Icons.forward_10_rounded,
                      onTap: () => _skip(10),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: TpmOutlineButton(
                        label: switch (_downloadState) {
                          _DownloadState.idle => 'Download',
                          _DownloadState.downloading =>
                            '${(_downloadProgress * 100).round()}%',
                          _DownloadState.done => 'Downloaded',
                        },
                        icon: switch (_downloadState) {
                          _DownloadState.idle => Icons.download_rounded,
                          _DownloadState.downloading =>
                            Icons.downloading_rounded,
                          _DownloadState.done => Icons.check_circle_rounded,
                        },
                        foreground: Colors.white,
                        background: Colors.white.withValues(alpha: 0.1),
                        borderColor: Colors.white.withValues(alpha: 0.25),
                        height: 48,
                        onPressed: _downloadState == _DownloadState.idle
                            ? _download
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TpmOutlineButton(
                        label: 'Share',
                        icon: Icons.ios_share_rounded,
                        foreground: Colors.white,
                        background: Colors.white.withValues(alpha: 0.1),
                        borderColor: Colors.white.withValues(alpha: 0.25),
                        height: 48,
                        onPressed: _share,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The real-video path — an embedded YouTube iframe player rather than the
/// fake scrubber/skip controls above, which only ever made sense for the
/// prototype's audio-only items. YouTube's own player owns transport
/// controls here, so there's no download action: their terms don't allow
/// saving the stream, in this player or any other.
///
/// Some of the channel's videos have embedding switched off — YouTube plays
/// them fine in its own app, but refuses any third-party embed, ours
/// included, and reports it as a player error rather than a network one.
/// [_error] tracks that state so this falls back to "watch on YouTube"
/// instead of leaving the iframe's own bare error page on screen.
class _VideoPlayer extends StatefulWidget {
  const _VideoPlayer({required this.item, required this.controller});

  final MediaItem item;
  final YoutubePlayerController controller;

  @override
  State<_VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<_VideoPlayer> {
  late YoutubeError _error = widget.controller.value.error;
  StreamSubscription<YoutubePlayerValue>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.controller.stream.listen((value) {
      if (value.error != _error) setState(() => _error = value.error);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _watchOnYoutube() async {
    final uri = Uri.parse('https://youtu.be/${widget.item.youtubeId}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final blocked = _error != YoutubeError.none;

    return Scaffold(
      backgroundColor: TpmColors.deepNavy,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
              child: Row(
                children: [
                  _GlassButton(
                    icon: Icons.expand_more_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Text(
                    'WATCHING',
                    style: TpmText.eyebrow(
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 10,
                      tracking: 1.6,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 38),
                ],
              ),
            ),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: blocked
                  ? _UnplayableVideo(
                      item: widget.item,
                      onWatchOnYoutube: _watchOnYoutube,
                    )
                  : YoutubePlayer(controller: widget.controller),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: TpmText.display(21, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.item.meta,
                      style: TpmText.body(
                        13.5,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: Colors.white38,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            blocked
                                ? "This video isn't available for in-app playback — watch it on YouTube instead."
                                : 'Streamed from our YouTube channel — playback stays in the app.',
                            style: TpmText.body(11.5, color: Colors.white38),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (blocked)
                      TpmButton(
                        label: 'Watch on YouTube',
                        icon: Icons.open_in_new_rounded,
                        gradient: TpmColors.goldGradient,
                        foreground: TpmColors.night,
                        onPressed: _watchOnYoutube,
                      )
                    else
                      TpmOutlineButton(
                        label: 'Share',
                        icon: Icons.ios_share_rounded,
                        foreground: Colors.white,
                        background: Colors.white.withValues(alpha: 0.1),
                        borderColor: Colors.white.withValues(alpha: 0.25),
                        height: 48,
                        onPressed: () {},
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The fallback shown in place of the iframe once YouTube reports the video
/// as unplayable here — the thumbnail stays recognisable rather than
/// collapsing to a bare error page, with one clear way forward.
class _UnplayableVideo extends StatelessWidget {
  const _UnplayableVideo({required this.item, required this.onWatchOnYoutube});

  final MediaItem item;
  final VoidCallback onWatchOnYoutube;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onWatchOnYoutube,
      child: Stack(
        fit: StackFit.expand,
        children: [
          BrandedPhoto(asset: item.image, scrimOpacity: 0.55),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.open_in_new_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Can't play in the app",
                  style: TpmText.body(
                    12.5,
                    color: Colors.white,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tap to watch on YouTube',
                  style: TpmText.body(
                    11,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Real position/duration from the player, with tap-to-seek — no dragging,
/// since a `Stack` scrubber doesn't track a finger past its own bounds, but
/// a tap anywhere on the bar seeks there directly.
class _Scrubber extends StatelessWidget {
  const _Scrubber({required this.player, this.knownDuration});

  final AudioPlayer player;

  /// The feed's own `itunes:duration`, used over the player's reading when
  /// present — some episodes' mp3s make ExoPlayer under-report by up to an
  /// hour (see [MediaItem.duration]).
  final Duration? knownDuration;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.positionStream,
      initialData: Duration.zero,
      builder: (context, positionSnapshot) {
        final position = positionSnapshot.data ?? Duration.zero;
        final duration = knownDuration ?? player.duration ?? Duration.zero;
        final progress = duration.inMilliseconds == 0
            ? 0.0
            : (position.inMilliseconds / duration.inMilliseconds).clamp(
                0.0,
                1.0,
              );

        return Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    if (duration == Duration.zero) return;
                    final ratio = (details.localPosition.dx / width).clamp(
                      0.0,
                      1.0,
                    );
                    player.seek(duration * ratio);
                  },
                  child: SizedBox(
                    height: 20,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        Container(
                          height: 4,
                          width: width * progress,
                          decoration: BoxDecoration(
                            color: TpmColors.gold,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        Positioned(
                          left: width * progress - 6,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _format(position),
                  style: TpmText.body(
                    11.5,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  _format(duration),
                  style: TpmText.body(
                    11.5,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _format(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
  }
}

/// A tappable "1.0x" pill that cycles through playback speeds.
class _SpeedPill extends StatelessWidget {
  const _SpeedPill({required this.speed, required this.onTap});

  final double speed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = speed == speed.roundToDouble()
        ? '${speed.toStringAsFixed(0)}x'
        : '${speed}x';
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(99),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TpmText.body(
              12.5,
              color: Colors.white,
              weight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// The 10-second skip-back/skip-forward buttons flanking the play button.
class _TransportButton extends StatelessWidget {
  const _TransportButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
