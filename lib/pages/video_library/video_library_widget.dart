import '/auth/auth_manager.dart';
import '/backend/backend.dart';
import '/business/video_library.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'video_library_model.dart';
export 'video_library_model.dart';

/// Browsable library of real, verified YouTube wellness videos.
///
/// Ordering is personalised: videos tagged for the signed-in user's condition
/// float to the top, so someone with PCOS does not have to scroll past PMS
/// content to find theirs.
class VideoLibraryWidget extends StatefulWidget {
  const VideoLibraryWidget({super.key});

  static String routeName = 'VideoLibrary';
  static String routePath = '/video-library';

  @override
  State<VideoLibraryWidget> createState() => _VideoLibraryWidgetState();
}

class _VideoLibraryWidgetState extends State<VideoLibraryWidget> {
  late VideoLibraryModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String? _condition;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VideoLibraryModel());

    final uid = AuthManager.instance.currentUid;
    if (uid != null) {
      getUser(uid).then((u) {
        if (mounted && u != null && u.conditionType.isNotEmpty) {
          safeSetState(() => _condition = u.conditionType);
        }
      }).catchError((_) {
        // Personalisation is a nicety; the library still works without it.
      });
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  List<WellnessVideo> get _visible {
    final ordered = VideoLibrary.forCondition(_condition);
    if (_model.selectedCategory == 'all') return ordered;
    return ordered
        .where((v) => v.category == _model.selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final videos = _visible;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20),
                    onPressed: () => context.safePop(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Video Library',
                            style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryText)),
                        Text(
                            _condition == null
                                ? '${VideoLibrary.videos.length} guided sessions'
                                : 'Picked for ${_condition!.toUpperCase()}',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: theme.secondaryText)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final c in const [
                    ['all', 'All'],
                    ['yoga', 'Yoga'],
                    ['meditation', 'Meditation'],
                    ['breathwork', 'Breathwork'],
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CategoryChip(
                        label: c[1],
                        active: _model.selectedCategory == c[0],
                        onTap: () => safeSetState(
                            () => _model.selectedCategory = c[0]),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: videos.isEmpty
                  ? Center(
                      child: Text('Nothing in this category yet.',
                          style: GoogleFonts.inter(
                              fontSize: 14, color: theme.secondaryText)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: videos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) => _VideoCard(
                        video: videos[i],
                        onTap: () => context.pushNamed(
                          VideoPlayerWidget.routeName,
                          extra: {'videoId': videos[i].id},
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? theme.primary : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(50),
          border:
              Border.all(color: active ? theme.primary : theme.alternate),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : theme.secondaryText)),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video, required this.onTap});

  final WellnessVideo video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.alternate),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                        color: video.accent.withValues(alpha: 0.18)),
                    errorWidget: (_, __, ___) => Container(
                      color: video.accent.withValues(alpha: 0.18),
                      child: Icon(Icons.play_circle_outline,
                          size: 40, color: video.accent),
                    ),
                  ),
                ),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 32),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('${video.durationMins} min',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryText)),
                  const SizedBox(height: 4),
                  Text(video.channel,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: theme.secondaryText)),
                  const SizedBox(height: 8),
                  Text(video.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          height: 1.4,
                          color: theme.secondaryText)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
