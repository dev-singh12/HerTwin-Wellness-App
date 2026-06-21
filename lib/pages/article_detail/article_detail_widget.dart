import '/business/wellness_content_catalog.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'article_detail_model.dart';
export 'article_detail_model.dart';

class ArticleDetailWidget extends StatefulWidget {
  const ArticleDetailWidget({super.key, required this.articleId});

  final String articleId;

  static String routeName = 'ArticleDetail';
  static String routePath = '/article-detail';

  @override
  State<ArticleDetailWidget> createState() => _ArticleDetailWidgetState();
}

class _ArticleDetailWidgetState extends State<ArticleDetailWidget> {
  late ArticleDetailModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  WellnessArticle? _article;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ArticleDetailModel());

    _article = WellnessContentCatalog.articles
        .cast<WellnessArticle?>()
        .firstWhere((a) => a!.id == widget.articleId, orElse: () => null);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (_article == null) {
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          child: Center(
            child: Text('Article not found',
                style: GoogleFonts.poppins(color: theme.primaryText)),
          ),
        ),
      );
    }

    final article = _article!;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.safePop(),
                    child: Icon(Icons.arrow_back_ios_rounded,
                        color: theme.primaryText, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      article.title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Hero banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: article.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(article.category.toUpperCase(),
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 6),
                        Text(article.title,
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text('${article.readMins} min',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Article body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  article.fullText,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: theme.primaryText,
                    height: 1.7,
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
