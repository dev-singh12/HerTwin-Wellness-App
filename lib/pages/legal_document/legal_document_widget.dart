import '/business/legal_content.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'legal_document_model.dart';
export 'legal_document_model.dart';

/// Renders the privacy policy or terms of service.
///
/// The text is bundled rather than fetched: a user must be able to read what
/// they are agreeing to before they have an account, and before the app has
/// made a single network call.
class LegalDocumentWidget extends StatefulWidget {
  const LegalDocumentWidget({super.key, this.docType});

  /// 'privacy' or 'terms'.
  final String? docType;

  static String routeName = 'LegalDocument';
  static String routePath = '/legal';

  @override
  State<LegalDocumentWidget> createState() => _LegalDocumentWidgetState();
}

class _LegalDocumentWidgetState extends State<LegalDocumentWidget> {
  late LegalDocumentModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LegalDocumentModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  bool get _isTerms => widget.docType == 'terms';

  String get _title => _isTerms ? 'Terms of Service' : 'Privacy Policy';

  String get _body =>
      _isTerms ? LegalContent.termsOfService : LegalContent.privacyPolicy;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20),
                    onPressed: () => context.safePop(),
                  ),
                  Expanded(
                    child: Text(
                      _title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                children: [
                  _DraftNotice(text: LegalContent.draftBanner),
                  const SizedBox(height: 20),
                  ..._renderBlocks(context, _body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Minimal renderer for the subset of Markdown the documents use:
  /// `## ` headings, `**bold**` lead-ins, `- ` bullets, and paragraphs.
  /// A full Markdown dependency would be overkill for two static documents.
  List<Widget> _renderBlocks(BuildContext context, String source) {
    final theme = FlutterFlowTheme.of(context);
    final widgets = <Widget>[];

    for (final rawBlock in source.trim().split(RegExp(r'\n\s*\n'))) {
      final block = rawBlock.trim();
      if (block.isEmpty) continue;

      if (block.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8),
          child: Text(
            block.substring(3).trim(),
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: theme.primaryText,
            ),
          ),
        ));
        continue;
      }

      if (block.startsWith('- ')) {
        // A bullet may wrap across several source lines. Continuation lines
        // must be folded into the preceding item — an earlier version skipped
        // any line not starting with "- ", which silently truncated every
        // wrapped bullet mid-sentence.
        final items = <String>[];
        for (final line in block.split('\n')) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) continue;
          if (trimmed.startsWith('- ')) {
            items.add(trimmed.substring(2).trim());
          } else if (items.isNotEmpty) {
            items[items.length - 1] = '${items.last} $trimmed';
          }
        }

        for (final item in items) {
          widgets.add(Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7, right: 10),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(child: _richParagraph(context, item)),
              ],
            ),
          ));
        }
        continue;
      }

      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _richParagraph(context, block.replaceAll('\n', ' ')),
      ));
    }

    return widgets;
  }

  /// Renders `**bold**` and `*italic*` inline without pulling in a Markdown
  /// package. Bold is matched first so `**x**` is not mistaken for italics.
  Widget _richParagraph(BuildContext context, String text) {
    final theme = FlutterFlowTheme.of(context);
    final base = GoogleFonts.inter(
      fontSize: 14,
      height: 1.65,
      color: theme.primaryText,
    );

    final spans = <TextSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');
    var cursor = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      final bold = match.group(1);
      spans.add(TextSpan(
        text: bold ?? match.group(2),
        style: bold != null
            ? const TextStyle(fontWeight: FontWeight.w700)
            : const TextStyle(fontStyle: FontStyle.italic),
      ));
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return RichText(
      text: TextSpan(style: base, children: spans),
    );
  }
}

class _DraftNotice extends StatelessWidget {
  const _DraftNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.warning.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.warning.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: theme.primaryText),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
                height: 1.5,
                color: theme.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
