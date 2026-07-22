import '/components/app_image.dart';
import '/auth/auth_manager.dart';
import '/backend/backend.dart';
import '/business/cycle_engine.dart';
import '/business/video_library.dart';
import '/business/wellness_content_catalog.dart';
import '/components/category_chip/category_chip_widget.dart';
import '/components/wellness_card/wellness_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wellness_tab_model.dart';
export 'wellness_tab_model.dart';

class WellnessTabWidget extends StatefulWidget {
  const WellnessTabWidget({super.key});

  static String routeName = 'WellnessTab';
  static String routePath = '/wellnessTab';

  @override
  State<WellnessTabWidget> createState() => _WellnessTabWidgetState();
}

class _WellnessTabWidgetState extends State<WellnessTabWidget> {
  late WellnessTabModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  StreamSubscription<List<CyclesRecord>>? _cyclesSub;
  CycleStatus _status = CycleEngine.compute(const []);

  /// Selected wellness category: 0 All, 1 Yoga, 2 Mind, 3 Guides, 4 Meditation.
  int _activeCategory = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WellnessTabModel());

    final uid = AuthManager.instance.currentUid;
    if (uid != null) {
      _cyclesSub = streamCycles(uid).listen((cycles) {
        if (mounted) {
          safeSetState(() => _status = CycleEngine.compute(cycles));
        }
      });
    }
  }

  @override
  void dispose() {
    _cyclesSub?.cancel();
    _model.dispose();

    super.dispose();
  }

  void _openLogSymptoms() =>
      context.pushNamed(LogSymptomsModalWidget.routeName);

  void _selectCategory(int index) {
    if (_activeCategory == index) return;
    safeSetState(() => _activeCategory = index);
  }

  /// A featured practice tailored to the user's current cycle phase.
  ({String title, String subtitle, String duration, String img, String type})
      get _recommendation {
    switch (_status.phase) {
      case CyclePhase.menstrual:
        return (
          title: 'Restorative Yin Yoga',
          subtitle:
              'Gentle poses to ease cramps and restore energy during your menstrual phase.',
          duration: '12 mins',
          img:
              AppImages.yogaRestorativeCalm,
          type: 'video',
        );
      case CyclePhase.follicular:
        return (
          title: 'Follicular Flow Yoga',
          subtitle:
              'Boost energy and flexibility during your follicular phase.',
          duration: '15 mins',
          img:
              AppImages.yogaSunlitRoom,
          type: 'video',
        );
      case CyclePhase.ovulation:
        return (
          title: 'Energising HIIT Flow',
          subtitle:
              'Channel your peak energy with a dynamic session during ovulation.',
          duration: '20 mins',
          img:
              AppImages.workoutBrightStudio,
          type: 'video',
        );
      case CyclePhase.luteal:
        return (
          title: 'Calming Wind-Down',
          subtitle:
              'Soothe PMS tension and unwind gently during your luteal phase.',
          duration: '10 mins',
          img:
              AppImages.stretchingEveningLight,
          type: 'video',
        );
    }
  }

  // ── Dynamic category content ───────────────────────────────────────────

  Widget _buildCategoryContent() {
    final theme = FlutterFlowTheme.of(context);
    switch (_activeCategory) {
      case 1: return _buildYogaGrid(theme);
      case 2: return _buildMindSection(theme);
      case 3: return _buildArticlesList(theme);
      case 4: return _buildMeditationGrid(theme);
      default: return _buildAllContent(theme);
    }
  }

  Widget _buildAllContent(FlutterFlowTheme theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(theme, 'Recommended for You'),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => context.pushNamed(YogaDetailWidget.routeName, extra: {'contentId': null}),
          child: wrapWithModel(
            model: _model.wellnessCardModel1,
            updateCallback: () => safeSetState(() {}),
            child: WellnessCardWidget(
              duration: _recommendation.duration,
              img_desc: _recommendation.img,
              subtitle: _recommendation.subtitle,
              title: _recommendation.title,
              type: _recommendation.type,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _sectionTitle(theme, 'Mental Well-being'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _quickTile(theme, Icons.favorite_rounded, 'Mood Journal', Color(0xFFF3E5F5), Color(0xFF7B1FA2), () => context.pushNamed(MoodJournalWidget.routeName))),
            const SizedBox(width: 16),
            Expanded(child: _quickTile(theme, Icons.air_rounded, 'Breathwork', Color(0xFFE1F5FE), Color(0xFF0288D1), () => context.pushNamed(BreathworkGuideWidget.routeName))),
          ],
        ),
        const SizedBox(height: 24),
        _sectionTitle(theme, 'Video Library'),
        const SizedBox(height: 12),
        _videoLibraryBanner(theme),
        const SizedBox(height: 24),
        _sectionTitle(theme, 'Guided Meditations'),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: WellnessContentCatalog.meditationContents.map((m) => _meditationCard(theme, m)).toList(),
          ),
        ),
        const SizedBox(height: 24),
        _sectionTitle(theme, 'Educational Articles'),
        const SizedBox(height: 12),
        ...WellnessContentCatalog.articles.take(4).map((a) => _articleTile(theme, a)),
      ],
    );
  }

  /// Entry point to the curated real-video library. Uses a live YouTube
  /// thumbnail as the backdrop rather than a generated placeholder image.
  Widget _videoLibraryBanner(FlutterFlowTheme theme) {
    final featured = VideoLibrary.videos.first;
    return InkWell(
      onTap: () => context.pushNamed(VideoLibraryWidget.routeName),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.alternate),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: featured.thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: theme.primary.withValues(alpha: 0.2)),
              errorWidget: (_, __, ___) => Container(color: theme.primary.withValues(alpha: 0.2)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.72),
                    Colors.black.withValues(alpha: 0.25),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      Text('${VideoLibrary.videos.length} guided videos',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Yoga, meditation and breathwork from real teachers',
                      maxLines: 2,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.white.withValues(alpha: 0.9))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYogaGrid(FlutterFlowTheme theme) {
    final yogas = WellnessContentCatalog.yogaContents;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(theme, 'Yoga Flows \u{2022} ${yogas.length} practices'),
        const SizedBox(height: 12),
        ...yogas.map((y) => _contentTile(
          theme,
          icon: Icons.spa_rounded,
          title: y.title,
          subtitle: '${y.durationMins} min \u{2022} ${y.difficulty}',
          description: y.description,
          gradientColors: const [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          onTap: () => context.pushNamed(YogaDetailWidget.routeName, extra: {'contentId': y.id}),
        )),
      ],
    );
  }

  Widget _buildMindSection(FlutterFlowTheme theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(theme, 'Mindfulness & Well-being'),
        const SizedBox(height: 12),
        _contentTile(theme, icon: Icons.favorite_rounded, title: 'Mood Journal',
            subtitle: '5 min \u{2022} Daily Practice',
            description: 'Track your mood and discover patterns across your cycle.',
            gradientColors: const [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
            onTap: () => context.pushNamed(MoodJournalWidget.routeName)),
        _contentTile(theme, icon: Icons.air_rounded, title: '4-7-8 Breathing',
            subtitle: '3-5 min \u{2022} Anxiety Relief',
            description: 'Clinically proven breathing technique to calm your nervous system.',
            gradientColors: const [Color(0xFFE1F5FE), Color(0xFFB3E5FC)],
            onTap: () => context.pushNamed(BreathworkGuideWidget.routeName)),
        _contentTile(theme, icon: Icons.spa_rounded, title: 'Body Scan Meditation',
            subtitle: '10 min \u{2022} Relaxation',
            description: 'Release tension and connect with your body through guided awareness.',
            gradientColors: const [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
            onTap: () => context.pushNamed(MeditationGuideWidget.routeName, extra: {'contentId': 'meditation_pmr'})),
      ],
    );
  }

  Widget _buildArticlesList(FlutterFlowTheme theme) {
    final articles = WellnessContentCatalog.articles;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(theme, 'Articles \u{2022} ${articles.length} reads'),
        const SizedBox(height: 12),
        ...articles.map((a) => _articleTile(theme, a)),
      ],
    );
  }

  Widget _buildMeditationGrid(FlutterFlowTheme theme) {
    final meditations = WellnessContentCatalog.meditationContents;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(theme, 'Guided Meditations \u{2022} ${meditations.length} sessions'),
        const SizedBox(height: 12),
        ...meditations.map((m) => _contentTile(
          theme,
          icon: m.icon,
          title: m.title,
          subtitle: '${m.durationMins} min \u{2022} ${m.poses.length} steps',
          description: m.description,
          gradientColors: const [Color(0xFF1A1A2E), Color(0xFF16213E)],
          textLight: true,
          onTap: () => context.pushNamed(MeditationGuideWidget.routeName, extra: {'contentId': m.id}),
        )),
      ],
    );
  }

  // ── Reusable building blocks ───────────────────────────────────────────

  Widget _sectionTitle(FlutterFlowTheme theme, String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: theme.primaryText),
    );
  }

  Widget _quickTile(FlutterFlowTheme theme, IconData icon, String label, Color bg, Color textColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(28)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: theme.onSurface, size: 28),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
          ],
        ),
      ),
    );
  }

  Widget _meditationCard(FlutterFlowTheme theme, WellnessContent m) {
    return GestureDetector(
      onTap: () => context.pushNamed(MeditationGuideWidget.routeName, extra: {'contentId': m.id}),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(m.icon, color: Colors.white70, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                Text('${m.durationMins} min', style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _contentTile(FlutterFlowTheme theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    bool textLight = false,
  }) {
    final textColor = textLight ? Colors.white : theme.primaryText;
    final subColor = textLight ? Colors.white70 : theme.secondaryText;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: (textLight ? Colors.white : theme.onSurface).withAlpha(textLight ? 30 : 15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: textLight ? Colors.white : theme.onSurface),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                    Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: subColor)),
                    const SizedBox(height: 4),
                    Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 12, color: subColor)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: subColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _articleTile(FlutterFlowTheme theme, WellnessArticle a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.pushNamed(ArticleDetailWidget.routeName, extra: {'articleId': a.id}),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.alternate, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: theme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.article_rounded, size: 22, color: theme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: theme.primaryText)),
                    Text('${a.readMins} min read \u{2022} ${a.category}', style: GoogleFonts.inter(fontSize: 11, color: theme.secondaryText)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.secondaryText, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Stack(
          alignment: AlignmentDirectional(-1.0, -1.0),
          children: [
            SingleChildScrollView(
              primary: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          24.0, 24.0, 24.0, 16.0),
                      child: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wellness Library',
                              style: FlutterFlowTheme.of(context)
                                  .headlineMedium
                                  .override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .headlineMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .headlineMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .headlineMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .headlineMedium
                                        .fontStyle,
                                    lineHeight: 1.25,
                                  ),
                            ),
                            Text(
                              'Holistic tools for your cycle harmony',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                    lineHeight: 1.5,
                                  ),
                            ),
                          ].divide(SizedBox(height: 4.0)),
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              24.0, 0.0, 24.0, 16.0),
                          child: Container(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () => _selectCategory(0),
                                  child: wrapWithModel(
                                  model: _model.categoryChipModel1,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CategoryChipWidget(
                                    icon: Icon(
                                      Icons.grid_view_rounded,
                                      color: _activeCategory == 0
                                          ? FlutterFlowTheme.of(context)
                                              .onPrimary
                                          : FlutterFlowTheme.of(context)
                                              .secondaryText,
                                      size: 18.0,
                                    ),
                                    label: 'All',
                                    selected: _activeCategory == 0,
                                  ),
                                ),
                                ),
                                InkWell(
                                  onTap: () => _selectCategory(1),
                                  child: wrapWithModel(
                                  model: _model.categoryChipModel2,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CategoryChipWidget(
                                    icon: Icon(
                                      Icons.spa_rounded,
                                      color: _activeCategory == 1
                                          ? FlutterFlowTheme.of(context)
                                              .onPrimary
                                          : FlutterFlowTheme.of(context)
                                              .secondaryText,
                                      size: 18.0,
                                    ),
                                    label: 'Yoga',
                                    selected: _activeCategory == 1,
                                  ),
                                ),
                                ),
                                InkWell(
                                  onTap: () => _selectCategory(2),
                                  child: wrapWithModel(
                                  model: _model.categoryChipModel3,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CategoryChipWidget(
                                    icon: Icon(
                                      Icons.psychology_rounded,
                                      color: _activeCategory == 2
                                          ? FlutterFlowTheme.of(context)
                                              .onPrimary
                                          : FlutterFlowTheme.of(context)
                                              .secondaryText,
                                      size: 18.0,
                                    ),
                                    label: 'Mind',
                                    selected: _activeCategory == 2,
                                  ),
                                ),
                                ),
                                InkWell(
                                  onTap: () => _selectCategory(3),
                                  child: wrapWithModel(
                                  model: _model.categoryChipModel4,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CategoryChipWidget(
                                    icon: Icon(
                                      Icons.auto_stories_rounded,
                                      color: _activeCategory == 3
                                          ? FlutterFlowTheme.of(context)
                                              .onPrimary
                                          : FlutterFlowTheme.of(context)
                                              .secondaryText,
                                      size: 18.0,
                                    ),
                                    label: 'Guides',
                                    selected: _activeCategory == 3,
                                  ),
                                ),
                                ),
                                InkWell(
                                  onTap: () => _selectCategory(4),
                                  child: wrapWithModel(
                                  model: _model.categoryChipModel5,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CategoryChipWidget(
                                    icon: Icon(
                                      Icons.self_improvement_rounded,
                                      color: _activeCategory == 4
                                          ? FlutterFlowTheme.of(context)
                                              .onPrimary
                                          : FlutterFlowTheme.of(context)
                                              .secondaryText,
                                      size: 18.0,
                                    ),
                                    label: 'Meditation',
                                    selected: _activeCategory == 4,
                                  ),
                                ),
                                ),
                              ].divide(SizedBox(width: 16.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                    child: _buildCategoryContent(),
                  ),
                  Container(
                    height: 100.0,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Container(
                alignment: AlignmentDirectional(1.0, 1.0),
                child: FloatingActionButton.extended(
                  onPressed: _openLogSymptoms,
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  icon: Icon(
                    Icons.add_rounded,
                    color: FlutterFlowTheme.of(context).onPrimary,
                    size: 24.0,
                  ),
                  elevation: 0.0,
                  label: Text(
                    'Log Symptoms',
                    style: FlutterFlowTheme.of(context).labelLarge.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FlutterFlowTheme.of(context)
                                .labelLarge
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .labelLarge
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).onPrimary,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .labelLarge
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).labelLarge.fontStyle,
                          lineHeight: 1.3,
                        ),
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
