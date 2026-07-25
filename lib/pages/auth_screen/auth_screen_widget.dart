import '/components/app_image.dart';
import '/auth/auth_manager.dart';
import '/components/social_auth_button/social_auth_button_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_screen_model.dart';
import 'email_auth_sheet.dart';
import 'post_auth.dart';
export 'auth_screen_model.dart';

class AuthScreenWidget extends StatefulWidget {
  const AuthScreenWidget({super.key});

  static String routeName = 'AuthScreen';
  static String routePath = '/authScreen';

  @override
  State<AuthScreenWidget> createState() => _AuthScreenWidgetState();
}

class _AuthScreenWidgetState extends State<AuthScreenWidget> {
  late AuthScreenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _googleLoading = false;

  /// Which role the user is entering as. Purely a UI/routing hint — it grants
  /// no privilege (clinician access is approved server-side). See [post_auth].
  bool _asDoctor = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuthScreenModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
  }

  /// Opens the bundled privacy policy or terms. These are in-app pages rather
  /// than external links so they are readable offline and before sign-in —
  /// the user is being asked to agree to them right here.
  void _openLegal(String docType) => context.pushNamed(
        LegalDocumentWidget.routeName,
        extra: {'docType': docType},
      );

  Future<void> _handleGoogleSignIn() async {
    if (_googleLoading) return;
    setState(() => _googleLoading = true);
    try {
      await AuthManager.instance.signInWithGoogle();
      if (!mounted) return;
      // One shared path decides member vs approved-doctor vs pending-doctor.
      await completeAuthNavigation(context, asDoctor: _asDoctor);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  /// One segment of the User/Doctor selector.
  Widget _roleTab({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 44.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? theme.secondaryBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: Colors.black.withAlpha(18),
                        blurRadius: 6.0,
                        offset: const Offset(0, 2))
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 18.0,
                  color: selected ? theme.primary : theme.secondaryText),
              const SizedBox(width: 6.0),
              Text(label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: selected ? theme.primaryText : theme.secondaryText,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  /// A 56px auth action pill. [filled] = solid primary; otherwise outlined.
  Widget _pill({
    required IconData icon,
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28.0),
        onTap: onTap,
        child: Container(
          height: 56.0,
          decoration: BoxDecoration(
            color: filled ? theme.primary : theme.secondaryBackground,
            borderRadius: BorderRadius.circular(28.0),
            border:
                filled ? null : Border.all(color: theme.alternate, width: 1.0),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 20.0, color: filled ? theme.onPrimary : theme.primary),
              const SizedBox(width: 12.0),
              Text(label,
                  style: theme.titleSmall.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                    color: filled ? theme.onPrimary : theme.primaryText,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  )),
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
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              primary: false,
              padding:
                  const EdgeInsetsDirectional.fromSTEB(28.0, 32.0, 28.0, 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand wordmark. Loads the real PNG when it exists,
                    // otherwise degrades to a gradient badge + "HerTwin" so
                    // the very first screen a user sees is never empty.
                    Builder(builder: (context) {
                      final theme = FlutterFlowTheme.of(context);
                      final logoW = (MediaQuery.sizeOf(context).width * 0.66)
                          .clamp(240.0, 320.0);
                      // Rounded card so the wordmark's soft background reads as
                      // a deliberate logo tile rather than a floating rectangle
                      // on the near-white page.
                      return Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24.0),
                          child: AppImage(
                            AppImages.logoWordmark,
                            width: logoW,
                            fit: BoxFit.contain,
                            fallback: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 96.0,
                                  height: 96.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [theme.primary, theme.secondary],
                                      begin:
                                          const AlignmentDirectional(1.0, -1.0),
                                      end:
                                          const AlignmentDirectional(-1.0, 1.0),
                                    ),
                                    borderRadius: BorderRadius.circular(28.0),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.spa_rounded,
                                      color: Colors.white, size: 44.0),
                                ),
                                const SizedBox(height: 16.0),
                                Text(
                                  'HerTwin',
                                  style: theme.headlineLarge.override(
                                    font: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.bold),
                                    color: theme.primaryText,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 28.0),
                    // Role selector — the screen no longer hides whether you're
                    // a member or a clinician. Purely a routing/label hint; it
                    // grants nothing (clinician access is approved server-side).
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context)
                            .alternate
                            .withAlpha(140),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Row(
                        children: [
                          _roleTab(
                            label: "I'm a User",
                            icon: Icons.person_rounded,
                            selected: !_asDoctor,
                            onTap: () => safeSetState(() => _asDoctor = false),
                          ),
                          _roleTab(
                            label: "I'm a Doctor",
                            icon: Icons.medical_services_rounded,
                            selected: _asDoctor,
                            onTap: () => safeSetState(() => _asDoctor = true),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    // 1) Sign up (first time) — solid primary CTA.
                    _pill(
                      icon: Icons.person_add_alt_1_rounded,
                      label: 'Sign up — first time',
                      filled: true,
                      onTap: () => showEmailAuthSheet(context,
                          asDoctor: _asDoctor, startSignUp: true),
                    ),
                    const SizedBox(height: 12.0),
                    // 2) Continue with Google — bordered white (G mark).
                    Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(28.0),
                          onTap: _googleLoading ? null : _handleGoogleSignIn,
                          child: wrapWithModel(
                            model: _model.socialAuthButtonModel1,
                            updateCallback: () => safeSetState(() {}),
                            child: SocialAuthButtonWidget(
                              provider_icon: AppImages.googleLogo,
                              provider_name: 'Google',
                              enabled: !_googleLoading,
                            ),
                          ),
                        ),
                        if (_googleLoading)
                          SizedBox(
                            width: 22.0,
                            height: 22.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    // 3) Continue with Email — outlined pill (sign in).
                    _pill(
                      icon: Icons.mail_outline_rounded,
                      label: 'Continue with Email',
                      filled: false,
                      onTap: () => showEmailAuthSheet(context,
                          asDoctor: _asDoctor, startSignUp: false),
                    ),
                    const SizedBox(height: 28.0),
                    Text(
                      'By continuing, you agree to our',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                            font: GoogleFonts.plusJakartaSans(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(8.0),
                          onTap: () => _openLegal('terms'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 10.0),
                            child: Text(
                              'Terms of Service',
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    font: GoogleFonts.plusJakartaSans(),
                                    color:
                                        FlutterFlowTheme.of(context).primary,
                                    letterSpacing: 0.0,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ),
                        ),
                        Text('•',
                            style: FlutterFlowTheme.of(context)
                                .labelSmall
                                .override(
                                  font: GoogleFonts.plusJakartaSans(),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  letterSpacing: 0.0,
                                )),
                        InkWell(
                          borderRadius: BorderRadius.circular(8.0),
                          onTap: () => _openLegal('privacy'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 10.0),
                            child: Text(
                              'Privacy Policy',
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    font: GoogleFonts.plusJakartaSans(),
                                    color:
                                        FlutterFlowTheme.of(context).primary,
                                    letterSpacing: 0.0,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
