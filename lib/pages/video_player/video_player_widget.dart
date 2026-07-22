import '/business/video_library.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'video_player_model.dart';
export 'video_player_model.dart';

/// Plays a library video inline via YouTube's iframe player.
///
/// Playback stays inside the app so the session is not interrupted, but the
/// creator is credited and a "watch on YouTube" link is always offered —
/// embedding someone's work without attribution or a route back to their
/// channel would not be a fair use of it.
class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({super.key, this.videoId});

  /// Library id (e.g. `vid_cramps_adriene`), not the YouTube id.
  final String? videoId;

  static String routeName = 'VideoPlayer';
  static String routePath = '/video-player';

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  YoutubePlayerController? _controller;
  WellnessVideo? _video;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VideoPlayerModel());

    final video = VideoLibrary.byId(widget.videoId ?? '');
    _video = video;
    if (video != null) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: video.youtubeId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
          showControls: true,
          strictRelatedVideos: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.close();
    _model.dispose();
    super.dispose();
  }

  Future<void> _openOnYouTube() async {
    final video = _video;
    if (video == null) return;
    final url = Uri.parse(video.watchUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open YouTube.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final video = _video;
    final controller = _controller;

    if (video == null || controller == null) {
      return Scaffold(
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          backgroundColor: theme.primaryBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.safePop(),
          ),
        ),
        body: Center(
          child: Text('This video is no longer available.',
              style: GoogleFonts.inter(
                  fontSize: 14, color: theme.secondaryText)),
        ),
      );
    }

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20),
                    onPressed: () => context.safePop(),
                  ),
                  Expanded(
                    child: Text(video.category.toUpperCase(),
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                            color: video.accent)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: YoutubePlayer(
                controller: controller,
                aspectRatio: 16 / 9,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  Text(video.title,
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryText)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded,
                          size: 15, color: theme.secondaryText),
                      const SizedBox(width: 4),
                      Text(video.channel,
                          style: GoogleFonts.inter(
                              fontSize: 13, color: theme.secondaryText)),
                      const SizedBox(width: 14),
                      Icon(Icons.schedule_rounded,
                          size: 15, color: theme.secondaryText),
                      const SizedBox(width: 4),
                      Text('${video.durationMins} min',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: theme.secondaryText)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(video.description,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.6,
                          color: theme.primaryText)),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _openOnYouTube,
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: Text('Watch on YouTube',
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.primaryText,
                        side: BorderSide(color: theme.alternate),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 18, color: theme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This is general wellness content, not medical '
                            'advice. Stop if anything hurts, and talk to your '
                            'doctor before starting a new routine.',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                height: 1.5,
                                color: theme.secondaryText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
