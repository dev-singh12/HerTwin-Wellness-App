import '/auth/auth_manager.dart';
import '/backend/backend.dart';
import '/backend/community_groups.dart';
import '/components/community_tab_item/community_tab_item_widget.dart';
import '/components/interest_group/interest_group_widget.dart';
import '/components/story_card/story_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'community_feed_model.dart';
export 'community_feed_model.dart';

class CommunityFeedWidget extends StatefulWidget {
  const CommunityFeedWidget({super.key});

  static String routeName = 'CommunityFeed';
  static String routePath = '/communityFeed';

  @override
  State<CommunityFeedWidget> createState() => _CommunityFeedWidgetState();
}

class _CommunityFeedWidgetState extends State<CommunityFeedWidget> {
  late CommunityFeedModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  int _activeTab = 0;

  String _authorName = 'You';
  String _authorPhotoUrl = '';

  static const List<Color> _avatarPalette = [
    Color(0xFFF3E5F5),
    Color(0xFFE1F5FE),
    Color(0xFFE8F5E9),
    Color(0xFFFCE4EC),
    Color(0xFFFFF3E0),
    Color(0xFFE8EAF6),
  ];

  static const List<String> _categories = [
    'General',
    'PCOS',
    'PMS',
    'Wellness',
    'Success Story',
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CommunityFeedModel());
    _loadAuthor();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadAuthor() async {
    final uid = AuthManager.instance.currentUid;
    final fallback = AuthManager.instance.currentUser?.displayName ?? 'You';
    if (uid == null) return;
    try {
      final record = await getUser(uid);
      if (!mounted) return;
      safeSetState(() {
        _authorName =
            (record?.displayName.isNotEmpty ?? false) ? record!.displayName : fallback;
        _authorPhotoUrl = record?.photoUrl ?? '';
      });
    } catch (_) {
      if (mounted) safeSetState(() => _authorName = fallback);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Color _avatarColor(String seed) =>
      _avatarPalette[seed.hashCode.abs() % _avatarPalette.length];

  String _relativeTime(DateTime? time) {
    if (time == null) return 'just now';
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
    final weeks = (diff.inDays / 7).floor();
    return '$weeks week${weeks == 1 ? '' : 's'} ago';
  }

  // --- Actions -------------------------------------------------------------

  Future<void> _toggleLike(PostsRecord post) async {
    final uid = AuthManager.instance.currentUid;
    if (uid == null) return;
    try {
      await togglePostLike(post.id, uid);
    } catch (_) {
      _showMessage('Could not update like. Please try again.');
    }
  }

  void _sharePost(PostsRecord post) {
    Clipboard.setData(ClipboardData(
      text: '"${post.content}"\n— ${post.authorName} on HerTwin Community',
    ));
    _showMessage('Story copied to clipboard.');
  }

  Future<void> _confirmDeletePost(PostsRecord post) async {
    final uid = AuthManager.instance.currentUid;
    if (uid == null || post.authorUid != uid) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete story?'),
        content: const Text('This will remove your story for everyone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Delete',
              style: TextStyle(color: FlutterFlowTheme.of(context).error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await deletePost(post.id);
      if (mounted) _showMessage('Story deleted.');
    } catch (_) {
      if (mounted) _showMessage('Could not delete story. Please try again.');
    }
  }

  Future<void> _toggleGroup(CommunityGroup group) async {
    final uid = AuthManager.instance.currentUid;
    if (uid == null) return;
    try {
      final joined = await toggleGroupMembership(group.id, uid);
      if (mounted) {
        _showMessage(joined
            ? 'Joined ${group.title}.'
            : 'Left ${group.title}.');
      }
    } catch (_) {
      if (mounted) _showMessage('Could not update membership. Please try again.');
    }
  }

  // --- Composer ------------------------------------------------------------

  Future<void> _openComposer() async {
    final uid = AuthManager.instance.currentUid;
    if (uid == null) {
      _showMessage('Please sign in to share your story.');
      return;
    }
    final controller = TextEditingController();
    String category = _categories.first;
    bool posting = false;

    try {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
        return StatefulBuilder(
          builder: (_, setSheet) {
            Future<void> submit() async {
              final text = controller.text.trim();
              if (text.isEmpty) {
                _showMessage('Please write something to share.');
                return;
              }
              setSheet(() => posting = true);
              try {
                final id = newPostId();
                await createPost(PostsRecord(
                  id: id,
                  authorUid: uid,
                  authorName: _authorName,
                  authorInitials: _initials(_authorName),
                  authorPhotoUrl: _authorPhotoUrl,
                  avatarBgValue: _avatarColor(_authorName).toARGB32(),
                  category: category,
                  content: text,
                  likeCount: 0,
                  commentCount: 0,
                  createdAt: DateTime.now(),
                ));
                if (sheetContext.mounted) Navigator.pop(sheetContext);
                if (mounted) _showMessage('Your story has been shared.');
              } catch (_) {
                setSheet(() => posting = false);
                _showMessage('Could not share your story. Please try again.');
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28.0)),
                ),
                padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40.0,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).alternate,
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Share your story',
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600),
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 12.0),
                    Wrap(
                      spacing: 8.0,
                      children: _categories.map((c) {
                        final selected = c == category;
                        return ChoiceChip(
                          label: Text(c),
                          selected: selected,
                          onSelected: (_) => setSheet(() => category = c),
                          showCheckmark: false,
                          backgroundColor:
                              FlutterFlowTheme.of(context).primaryBackground,
                          selectedColor: FlutterFlowTheme.of(context).primary,
                          labelStyle: TextStyle(
                            color: selected
                                ? FlutterFlowTheme.of(context).onPrimary
                                : FlutterFlowTheme.of(context).secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: controller,
                      maxLines: 5,
                      minLines: 3,
                      maxLength: 600,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText:
                            'Your experience could be the light someone else needs today…',
                        filled: true,
                        fillColor:
                            FlutterFlowTheme.of(context).primaryBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).alternate),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).alternate),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      height: 52.0,
                      child: ElevatedButton(
                        onPressed: posting ? null : submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FlutterFlowTheme.of(context).primary,
                          foregroundColor:
                              FlutterFlowTheme.of(context).onPrimary,
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26.0),
                          ),
                        ),
                        child: posting
                            ? const SizedBox(
                                width: 22.0,
                                height: 22.0,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white),
                              )
                            : Text(
                                'Post story',
                                style: FlutterFlowTheme.of(context)
                                    .labelLarge
                                    .override(
                                      font: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w600),
                                      color: FlutterFlowTheme.of(context)
                                          .onPrimary,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    } finally {
      controller.dispose();
    }
  }

  // --- Comments ------------------------------------------------------------

  Future<void> _openComments(PostsRecord post) async {
    final uid = AuthManager.instance.currentUid;
    final controller = TextEditingController();
    bool sending = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            Future<void> send() async {
              final text = controller.text.trim();
              if (text.isEmpty || uid == null) return;
              setSheet(() => sending = true);
              try {
                await addComment(
                  post.id,
                  CommentsRecord(
                    authorUid: uid,
                    authorName: _authorName,
                    authorInitials: _initials(_authorName),
                    content: text,
                    createdAt: DateTime.now(),
                  ),
                );
                controller.clear();
              } catch (_) {
                _showMessage('Could not post comment. Please try again.');
              } finally {
                setSheet(() => sending = false);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28.0)),
                ),
                padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40.0,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).alternate,
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Comments',
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600),
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: StreamBuilder<List<CommentsRecord>>(
                        stream: streamComments(post.id),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final comments = snapshot.data!;
                          if (comments.isEmpty) {
                            return Center(
                              child: Text(
                                'Be the first to comment.',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            );
                          }
                          return ListView.separated(
                            itemCount: comments.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16.0),
                            itemBuilder: (context, i) =>
                                _buildCommentTile(comments[i]),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1.0),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            minLines: 1,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Add a supportive comment…',
                              filled: true,
                              fillColor: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24.0),
                                borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context)
                                        .alternate),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24.0),
                                borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context)
                                        .alternate),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24.0),
                                borderSide: BorderSide(
                                    color:
                                        FlutterFlowTheme.of(context).primary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        IconButton(
                          onPressed: sending ? null : send,
                          icon: Icon(
                            Icons.send_rounded,
                            color: FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    controller.dispose();
  }

  Widget _buildCommentTile(CommentsRecord comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36.0,
          height: 36.0,
          decoration: BoxDecoration(
            color: _avatarColor(comment.authorName),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            comment.authorInitials.isNotEmpty
                ? comment.authorInitials
                : _initials(comment.authorName),
            style: FlutterFlowTheme.of(context).labelSmall.override(
                  font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600),
                  color: FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                ),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.authorName.isNotEmpty
                        ? comment.authorName
                        : 'Member',
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.interTight(
                              fontWeight: FontWeight.w600),
                          color: FlutterFlowTheme.of(context).primaryText,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    _relativeTime(comment.createdAt),
                    style: FlutterFlowTheme.of(context).labelSmall.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 2.0),
              Text(
                comment.content,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      lineHeight: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Build ---------------------------------------------------------------

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
          alignment: const AlignmentDirectional(-1.0, -1.0),
          children: [
            SingleChildScrollView(
              primary: false,
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 100.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    _buildTabs(),
                    const SizedBox(height: 24.0),
                    if (_activeTab == 0) ...[
                      _buildGroupsRow(),
                      const SizedBox(height: 24.0),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            24.0, 0.0, 24.0, 0.0),
                        child: _buildSharePrompt(),
                      ),
                      const SizedBox(height: 16.0),
                      _buildStoriesSection('Recent Stories', onlyLiked: false),
                    ] else if (_activeTab == 1) ...[
                      _buildGroupsList(),
                    ] else ...[
                      _buildStoriesSection('Saved Stories', onlyLiked: true),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                alignment: const AlignmentDirectional(1.0, 1.0),
                child: FloatingActionButton.extended(
                  onPressed: _openComposer,
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  icon: Icon(
                    Icons.add_rounded,
                    color: FlutterFlowTheme.of(context).onPrimary,
                    size: 24.0,
                  ),
                  elevation: 0.0,
                  label: Text(
                    'Share Story',
                    style: FlutterFlowTheme.of(context).labelLarge.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: FlutterFlowTheme.of(context).onPrimary,
                          letterSpacing: 0.0,
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                  color: FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'You are not alone in this journey.',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(),
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding:
              const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
          child: Row(
            children: [
              InkWell(
                onTap: () => safeSetState(() => _activeTab = 0),
                child: wrapWithModel(
                  model: _model.communityTabItemModel1,
                  updateCallback: () => safeSetState(() {}),
                  child: CommunityTabItemWidget(
                    label: 'Feed',
                    active: _activeTab == 0,
                  ),
                ),
              ),
              const SizedBox(width: 24.0),
              InkWell(
                onTap: () => safeSetState(() => _activeTab = 1),
                child: wrapWithModel(
                  model: _model.communityTabItemModel2,
                  updateCallback: () => safeSetState(() {}),
                  child: CommunityTabItemWidget(
                    label: 'Groups',
                    active: _activeTab == 1,
                  ),
                ),
              ),
              const SizedBox(width: 24.0),
              InkWell(
                onTap: () => safeSetState(() => _activeTab = 2),
                child: wrapWithModel(
                  model: _model.communityTabItemModel3,
                  updateCallback: () => safeSetState(() {}),
                  child: CommunityTabItemWidget(
                    label: 'Saved',
                    active: _activeTab == 2,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 1.0,
          color: FlutterFlowTheme.of(context).alternate,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {bool showFilter = false}) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600),
                  color: FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                ),
          ),
          if (showFilter)
            Icon(
              Icons.tune_rounded,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 20.0,
            ),
        ],
      ),
    );
  }

  Widget _buildGroupsRow() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('Circles of Support'),
        const SizedBox(height: 16.0),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 8.0, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children:
                kCommunityGroups.map((g) => _buildGroupCard(g)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupsList() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader('Circles of Support'),
          const SizedBox(height: 16.0),
          Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: kCommunityGroups.map((g) => _buildGroupCard(g)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(CommunityGroup group) {
    final uid = AuthManager.instance.currentUid;
    return InkWell(
      onTap: () => _toggleGroup(group),
      child: StreamBuilder<int>(
        stream: streamGroupMemberCount(group.id),
        builder: (context, countSnap) {
          final live = countSnap.data ?? 0;
          final members = formatMemberCount(group.baseMembers + live);
          return StreamBuilder<bool>(
            stream:
                uid == null ? null : streamGroupJoined(group.id, uid),
            builder: (context, joinedSnap) {
              return InterestGroupWidget(
                bg: group.bg,
                icon: Icon(group.icon, color: group.iconColor, size: 24.0),
                icon_color: group.iconColor,
                members: members,
                title: group.title,
                joined: joinedSnap.data ?? false,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSharePrompt() {
    return InkWell(
      onTap: _openComposer,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              FlutterFlowTheme.of(context).primary,
              FlutterFlowTheme.of(context).secondary,
            ],
            stops: const [0.0, 1.0],
            begin: const AlignmentDirectional(-1.0, 0.0),
            end: const AlignmentDirectional(1.0, 0.0),
          ),
          borderRadius: BorderRadius.circular(28.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share your story',
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600),
                            color: FlutterFlowTheme.of(context).onSurface,
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Your experience could be the light someone else needs today.',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.inter(),
                            color: FlutterFlowTheme.of(context).onSurface90,
                            letterSpacing: 0.0,
                            lineHeight: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).onPrimary20,
                  borderRadius: BorderRadius.circular(9999.0),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.edit_note_rounded,
                  color: FlutterFlowTheme.of(context).onSurface,
                  size: 24.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoriesSection(String title, {required bool onlyLiked}) {
    final uid = AuthManager.instance.currentUid;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                    ),
              ),
              Icon(
                Icons.tune_rounded,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 20.0,
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          StreamBuilder<List<PostsRecord>>(
            stream: streamPosts(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              var posts = snapshot.data!;
              if (onlyLiked) {
                return StreamBuilder<Set<String>>(
                  stream: uid == null
                      ? Stream<Set<String>>.empty()
                      : streamLikedPostIds(uid),
                  builder: (context, likedSnap) {
                    final likedIds = likedSnap.data ?? <String>{};
                    final saved = posts
                        .where((p) => likedIds.contains(p.id))
                        .toList();
                    if (saved.isEmpty) {
                      return _emptyState(
                          'Stories you like will be saved here.');
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children:
                          saved.map((p) => _buildPostCard(p, uid)).toList(),
                    );
                  },
                );
              }
              if (posts.isEmpty) {
                return _emptyState(
                    'No stories yet. Be the first to share yours.');
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: posts.map((p) => _buildPostCard(p, uid)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        children: [
          Icon(
            Icons.forum_outlined,
            size: 48.0,
            color: FlutterFlowTheme.of(context).alternate,
          ),
          const SizedBox(height: 12.0),
          Text(
            message,
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(),
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(PostsRecord post, String? uid) {
    final avatarBg = post.avatarBgValue != null
        ? Color(post.avatarBgValue!)
        : _avatarColor(post.authorName);
    return StreamBuilder<bool>(
      stream: uid == null ? null : streamPostLiked(post.id, uid),
      builder: (context, likedSnap) {
        return StoryCardWidget(
          avatar_bg: avatarBg,
          category: post.category.isNotEmpty ? post.category : 'General',
          comments: '${post.commentCount}',
          content: post.content,
          initials: post.authorInitials.isNotEmpty
              ? post.authorInitials
              : _initials(post.authorName),
          likes: '${post.likeCount}',
          name: post.authorName.isNotEmpty ? post.authorName : 'Member',
          time: _relativeTime(post.createdAt),
          liked: likedSnap.data ?? false,
          onLike: () => _toggleLike(post),
          onComment: () => _openComments(post),
          onShare: () => _sharePost(post),
          onMore: post.authorUid == uid
              ? () => _confirmDeletePost(post)
              : null,
        );
      },
    );
  }
}
