import 'dart:async';

import '/auth/auth_manager.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'mood_journal_model.dart';
export 'mood_journal_model.dart';

class MoodJournalWidget extends StatefulWidget {
  const MoodJournalWidget({super.key});
  static String routeName = 'MoodJournal';
  static String routePath = '/journal';
  @override
  State<MoodJournalWidget> createState() => _MoodJournalWidgetState();
}

class _MoodJournalWidgetState extends State<MoodJournalWidget> with SingleTickerProviderStateMixin {
  late MoodJournalModel _model;
  late TabController _tabController;
  int _moodRating = 3;
  bool _saving = false;
  StreamSubscription<List<JournalsRecord>>? _journalsSub;
  List<JournalsRecord> _pastEntries = [];
  String _dailyPrompt = "What's on your mind today?";
  String? get _uid => AuthManager.instance.currentUid;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MoodJournalModel());
    _model.contentTextController ??= TextEditingController();
    _model.contentFocusNode ??= FocusNode();
    _tabController = TabController(length: 2, vsync: this);
    final uid = _uid;
    if (uid != null) {
      _journalsSub = streamJournals(uid).listen((e) { if (mounted) safeSetState(() => _pastEntries = e); });
      streamUser(uid).first.then((user) {
        if (mounted) safeSetState(() => _dailyPrompt = _promptFor(user.conditionType));
      });
    }
  }

  String _promptFor(String c) {
    final m = <String, List<String>>{
      'pcos': ['How did your energy feel today?', 'Did you notice any skin changes?', 'What was your stress level today?', 'How was your sleep?', 'One thing you did for your health today.'],
      'pcod': ['How was your appetite today?', 'Did you get movement in today?', 'How is your skin this week?', 'What made you smile?', 'Your energy patterns today.'],
      'pms': ['How are your emotions today?', 'Any physical discomfort?', 'What helped you feel calmer?', 'How was your sleep?', 'What are you grateful for?'],
      'pmdd': ['Rate your emotional intensity today.', 'Were you able to do daily tasks?', 'Did mindfulness help today?', 'Best coping strategy today?', 'Write a compassionate note to yourself.'],
      'irregular': ['Any signs of your period?', 'Stress level today?', 'Food that made you feel good?', 'Hormonal symptoms?', 'How are you caring for yourself?'],
    };
    final list = m[c] ?? ["What's on your mind today?", 'How is your body feeling?', 'Something that made you happy.', 'Looking forward to tomorrow?', 'Describe today in three words.'];
    return list[DateTime.now().difference(DateTime(DateTime.now().year)).inDays % list.length];
  }

  @override
  void dispose() { _tabController.dispose(); _journalsSub?.cancel(); _model.dispose(); super.dispose(); }

  Future<void> _saveEntry() async {
    final uid = _uid;
    if (uid == null) return;
    final content = _model.contentTextController?.text.trim() ?? '';
    if (content.isEmpty) return;
    safeSetState(() => _saving = true);
    try {
      final now = DateTime.now();
      await createJournal(uid, JournalsRecord(id: newJournalId(uid), date: now, title: 'Journal Entry', content: content, mood: _moodLabels[_moodRating - 1], tags: const [], createdAt: now, updatedAt: now));
      _model.contentTextController?.clear();
      safeSetState(() => _moodRating = 3);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved!', style: GoogleFonts.inter(color: Colors.white)), backgroundColor: FlutterFlowTheme.of(context).success));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save'), backgroundColor: FlutterFlowTheme.of(context).error));
    } finally { if (mounted) safeSetState(() => _saving = false); }
  }

  static const _moodEmojis = ['\u{1F614}', '\u{1F615}', '\u{1F642}', '\u{1F60A}', '\u{1F929}'];
  static const _moodLabels = ['Sad', 'Low', 'Okay', 'Good', 'Great'];

  static const _blogs = <_Blog>[
    _Blog('Understanding PCOS: Symptoms & Management', 'Healthline', 'https://www.healthline.com/health/polycystic-ovary-disease', '\u{1F33F}', Color(0xFFE8F5E9)),
    _Blog('PMS vs PMDD: Know the Difference', 'Cleveland Clinic', 'https://my.clevelandclinic.org/health/articles/9536-premenstrual-dysphoric-disorder-pmdd', '\u{1F4D6}', Color(0xFFF3E5F5)),
    _Blog('Best Foods for Hormonal Balance', 'Medical News Today', 'https://www.medicalnewstoday.com/articles/324839', '\u{1F957}', Color(0xFFFFF3E0)),
    _Blog('Yoga Poses for Menstrual Cramps', 'Yoga Journal', 'https://www.yogajournal.com/poses/yoga-for-menstrual-cramps/', '\u{1F9D8}', Color(0xFFE1F5FE)),
    _Blog('How Stress Affects Your Period', 'Flo Health', 'https://flo.health/menstrual-cycle/health/period/can-stress-delay-your-period', '\u{1F9E0}', Color(0xFFFCE4EC)),
    _Blog('Inositol for PCOS: The Science', 'Verywell Health', 'https://www.verywellhealth.com/inositol-for-pcos-info-2616286', '\u{1F48A}', Color(0xFFE8EAF6)),
    _Blog('Seed Cycling: Does It Work?', 'Healthline', 'https://www.healthline.com/nutrition/seed-cycling', '\u{1F331}', Color(0xFFE8F5E9)),
    _Blog('Managing PMDD: A Complete Guide', 'IAPMD', 'https://iapmd.org/about-pmdd', '\u{1FA7A}', Color(0xFFF3E5F5)),
    _Blog('Iron-Rich Foods for Heavy Periods', 'BBC Good Food', 'https://www.bbcgoodfood.com/howto/guide/best-iron-rich-foods', '\u{1F4AA}', Color(0xFFFFF3E0)),
    _Blog('Meditation for Anxiety & Hormones', 'Headspace', 'https://www.headspace.com/meditation/anxiety', '\u{1F54A}\uFE0F', Color(0xFFE1F5FE)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                InkWell(onTap: () => context.safePop(), child: Icon(Icons.arrow_back_ios_rounded, color: theme.primaryText, size: 22)),
                const SizedBox(width: 12),
                Text('Journal & Blogs', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: theme.primaryText)),
              ]),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: theme.alternate, borderRadius: BorderRadius.circular(12)),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(color: theme.primary, borderRadius: BorderRadius.circular(12)),
                labelColor: Colors.white, unselectedLabelColor: theme.secondaryText,
                labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 14),
                indicatorSize: TabBarIndicatorSize.tab, dividerColor: Colors.transparent,
                tabs: const [Tab(text: 'Mood Journal'), Tab(text: 'Blogs')],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: TabBarView(controller: _tabController, children: [_journalTab(theme), _blogsTab(theme)])),
          ]),
        ),
      ),
    );
  }

  Widget _journalTab(FlutterFlowTheme theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('How are you feeling?', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: theme.primaryText)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(5, (i) {
          final sel = _moodRating == i + 1;
          return InkWell(
            onTap: () => safeSetState(() => _moodRating = i + 1),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200), padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: sel ? theme.primary.withAlpha(30) : Colors.transparent, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? theme.primary : theme.alternate, width: sel ? 2 : 1)),
              child: Column(children: [
                Text(_moodEmojis[i], style: TextStyle(fontSize: sel ? 30 : 24)),
                const SizedBox(height: 4),
                Text(_moodLabels[i], style: GoogleFonts.inter(fontSize: 11, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? theme.primary : theme.secondaryText)),
              ]),
            ),
          );
        })),
        const SizedBox(height: 24),
        Text(_dailyPrompt, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: theme.primaryText)),
        const SizedBox(height: 8),
        TextField(controller: _model.contentTextController, focusNode: _model.contentFocusNode, maxLines: 6, style: GoogleFonts.inter(fontSize: 14, color: theme.primaryText), decoration: InputDecoration(hintText: 'Write about your day, feelings, symptoms...', hintStyle: GoogleFonts.inter(fontSize: 14, color: theme.secondaryText), filled: true, fillColor: theme.secondaryBackground, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(16))),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: InkWell(
          onTap: _saving ? null : _saveEntry, borderRadius: BorderRadius.circular(28),
          child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFEFA6B3), Color(0xFF9FA8DA)]), borderRadius: BorderRadius.circular(28)), alignment: Alignment.center,
            child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Save Entry', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white))),
        )),
        const SizedBox(height: 32),
        Text('Past Entries', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: theme.primaryText)),
        const SizedBox(height: 12),
        if (_pastEntries.isEmpty) Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Text('No entries yet. Start writing!', style: GoogleFonts.inter(fontSize: 14, color: theme.secondaryText))))
        else ..._pastEntries.take(20).map((entry) {
          final dateStr = entry.date != null ? DateFormat('MMM d, y').format(entry.date!) : '';
          final mi = _moodLabels.indexOf(entry.mood);
          final emoji = mi >= 0 ? _moodEmojis[mi] : '';
          return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: theme.secondaryBackground, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [if (emoji.isNotEmpty) Text(emoji, style: const TextStyle(fontSize: 18)), if (emoji.isNotEmpty) const SizedBox(width: 8), Text(entry.mood, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: theme.primaryText)), const Spacer(), Text(dateStr, style: GoogleFonts.inter(fontSize: 12, color: theme.secondaryText))]),
              const SizedBox(height: 6),
              Text(entry.content, maxLines: 3, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 13, color: theme.primaryText, height: 1.4)),
            ]),
          );
        }),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _blogsTab(FlutterFlowTheme theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _blogs.length,
      itemBuilder: (context, i) {
        final b = _blogs[i];
        return Padding(padding: const EdgeInsets.only(bottom: 12), child: InkWell(
          onTap: () async { final uri = Uri.parse(b.url); if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); },
          borderRadius: BorderRadius.circular(16),
          child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: b.color, borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Text(b.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b.title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: theme.primaryText), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(b.source, style: GoogleFonts.inter(fontSize: 12, color: theme.secondaryText)),
              ])),
              Icon(Icons.open_in_new_rounded, size: 18, color: theme.secondaryText),
            ]),
          ),
        ));
      },
    );
  }
}

class _Blog {
  const _Blog(this.title, this.source, this.url, this.emoji, this.color);
  final String title, source, url, emoji;
  final Color color;
}
