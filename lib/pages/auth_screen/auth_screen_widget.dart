import '/components/app_image.dart';
import '/auth/auth_manager.dart';
import '/backend/backend.dart';
import '/components/button/button_widget.dart';
import '/components/social_auth_button/social_auth_button_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
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
        body: SingleChildScrollView(
          primary: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(32.0, 24.0, 32.0, 24.0),
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 60.0,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  FlutterFlowTheme.of(context).primary,
                                  FlutterFlowTheme.of(context).secondary
                                ],
                                stops: [0.0, 1.0],
                                begin: AlignmentDirectional(1.0, -1.0),
                                end: AlignmentDirectional(-1.0, 1.0),
                              ),
                              borderRadius: BorderRadius.circular(32.0),
                              shape: BoxShape.rectangle,
                            ),
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              color: FlutterFlowTheme.of(context).onSurface,
                              size: 48.0,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'HerTwin',
                                style: FlutterFlowTheme.of(context)
                                    .headlineLarge
                                    .override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineLarge
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .headlineLarge
                                          .fontStyle,
                                      lineHeight: 1.2,
                                    ),
                              ),
                              Text(
                                'Your AI-powered hormone companion',
                                textAlign: TextAlign.center,
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
                        ].divide(SizedBox(height: 16.0)),
                      ),
                      // Artwork scales with the viewport instead of being
                      // pinned at 240px, which was cramped on an iPhone SE
                      // and sparse on a Pro Max.
                      Builder(builder: (context) {
                        final shortestSide =
                            MediaQuery.sizeOf(context).shortestSide;
                        final art = (shortestSide * 0.52).clamp(140.0, 260.0);
                        final gap =
                            (MediaQuery.sizeOf(context).height * 0.04)
                                .clamp(16.0, 56.0);
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: gap),
                            SizedBox(
                              height: art,
                              // Bundled, not fetched: the sign-in screen must
                              // render even with no network, and it is the
                              // first thing a new user ever sees.
                              child: Lottie.asset(
                                AppImages.lottieBloomingFlower,
                                width: art,
                                height: art,
                                fit: BoxFit.contain,
                                animate: true,
                              ),
                            ),
                            SizedBox(height: gap),
                          ],
                        );
                      }),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(28.0),
                                onTap: _googleLoading
                                    ? null
                                    : _handleGoogleSignIn,
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
                          // Sign in with Apple was removed rather than left as
                          // a button that looked live and raised an error.
                          // It needs a paid Apple Developer account plus a
                          // Service ID and signing key; add it back alongside
                          // the real integration, not before.
                          InkWell(
                            onTap: () => showEmailAuthSheet(context),
                            child: wrapWithModel(
                              model: _model.buttonModel,
                              updateCallback: () => safeSetState(() {}),
                              child: ButtonWidget(
                                content: 'Sign in with Email',
                                icon: Icon(
                                  Icons.mail_outline_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 16.0,
                                ),
                                icon_present: true,
                                icon_end_present: false,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                variant: 'ghost',
                                size: 'medium',
                                full_width: false,
                                loading: false,
                                disabled: false,
                              ),
                            ),
                          ),
                        ].divide(SizedBox(height: 16.0)),
                      ),
                      Container(
                        height: 40.0,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'By continuing, you agree to our',
                            style: FlutterFlowTheme.of(context)
                                .labelSmall
                                .override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).onSurface,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .fontStyle,
                                  lineHeight: 1.2,
                                ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(8.0),
                                onTap: () => _openLegal('terms'),
                                child: Padding(
                                  // Text links were labelSmall with no
                                  // padding — far under the 48dp minimum
                                  // touch target.
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 12.0),
                                  child: Text(
                                'Terms of Service',
                                style: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontStyle,
                                      decoration: TextDecoration.underline,
                                      lineHeight: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                '•',
                                style: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .onSurface,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontStyle,
                                      lineHeight: 1.2,
                                    ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(8.0),
                                onTap: () => _openLegal('privacy'),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 12.0),
                                  child: Text(
                                'Privacy Policy',
                                style: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontStyle,
                                      decoration: TextDecoration.underline,
                                      lineHeight: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 4.0)),
                          ),
                        ].divide(SizedBox(height: 4.0)),
                      ),
                      Container(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
