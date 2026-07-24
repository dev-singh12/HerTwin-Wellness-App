import '/components/app_image.dart';
import '/auth/auth_manager.dart';
import '/backend/backend.dart';
import '/components/social_auth_button/social_auth_button_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_screen_model.dart';
import 'email_auth_sheet.dart';
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
      final uid = AuthManager.instance.currentUid;
      var onboardingComplete = false;
      if (uid != null) {
        final record = await getUser(uid);
        onboardingComplete = record?.onboardingComplete ?? false;
      }
      if (!mounted) return;
      context.goNamed(
        onboardingComplete
            ? HomeDashboardWidget.routeName
            : OnboardingStepFormWidget.routeName,
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
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
                      final logoW = (MediaQuery.sizeOf(context).width * 0.6)
                          .clamp(200.0, 300.0);
                      return AppImage(
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
                                  begin: const AlignmentDirectional(1.0, -1.0),
                                  end: const AlignmentDirectional(-1.0, 1.0),
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
                      );
                    }),
                    const SizedBox(height: 16.0),
                    Text(
                      'Your body, understood.',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.2,
                            lineHeight: 1.5,
                          ),
                    ),
                    const SizedBox(height: 40.0),
                    // Google — bordered white button (unchanged behaviour).
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
                    const SizedBox(height: 14.0),
                    // Email — filled primary button, same 56px pill as Google
                    // so the two read as a matched pair instead of a strong
                    // button beside a weak text link.
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28.0),
                        onTap: () => showEmailAuthSheet(context),
                        child: Container(
                          height: 56.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primary,
                            borderRadius: BorderRadius.circular(28.0),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.mail_outline_rounded,
                                  color: FlutterFlowTheme.of(context).onPrimary,
                                  size: 20.0),
                              const SizedBox(width: 12.0),
                              Text(
                                'Continue with Email',
                                style: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.w600),
                                      color: FlutterFlowTheme.of(context)
                                          .onPrimary,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32.0),
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
