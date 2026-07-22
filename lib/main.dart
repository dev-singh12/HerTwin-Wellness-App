import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import '/auth/auth_manager.dart';
import '/auth/role_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'firebase_options.dart';

/// Firebase options, with the web `authDomain` pinned to the current origin
/// during local development.
///
/// The generated `authDomain` is `hertwin-wellness.firebaseapp.com`. Served
/// from localhost that is a *different* origin, so every cookie Firebase's
/// sign-in flow sets is a third-party cookie — which Chrome blocks by
/// default. The popup then closes itself and Firebase surfaces
/// `popup-closed-by-user`, i.e. the browser's doing, reported as the user's.
///
/// `tool/serve_web.py` reverse-proxies `/__/auth/*` to the real Firebase host,
/// so pointing authDomain at our own origin makes the whole exchange
/// first-party and the block disappears.
///
/// Gated on **https** deliberately. Firebase's auth handler forces a secure
/// context, so pointing authDomain at a plain-http origin sends the browser
/// to `https://localhost:<port>` — which an http dev server cannot answer,
/// giving a blank page. That is worse than the cookie problem it solves.
/// Over http we leave the stock authDomain alone and let the popup→redirect
/// fallback in AuthManager deal with blocked popups.
///
/// Production is untouched either way.
FirebaseOptions _firebaseOptions() {
  final options = DefaultFirebaseOptions.currentPlatform;
  if (!kIsWeb) return options;

  // Origins that serve Firebase's `/__/auth/*` handler on the SAME origin as
  // the app: our Hosting domains (which serve it natively) and a local dev
  // server running tool/serve_web.py, which reverse-proxies it.
  const hostingDomains = {
    'hertwin-wellness.web.app',
    'hertwin-wellness.firebaseapp.com',
  };

  final host = Uri.base.host;
  final isLocalHost = host == 'localhost' || host == '127.0.0.1';
  final servesAuthHandler = isLocalHost || hostingDomains.contains(host);
  final isSecure = Uri.base.scheme == 'https';

  if (!servesAuthHandler || !isSecure) return options;

  return options.copyWith(authDomain: Uri.base.authority);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await Firebase.initializeApp(options: _firebaseOptions());

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await FlutterFlowTheme.initialize();

  // If Google sign-in fell back to a full-page redirect, the browser has just
  // navigated back here — finish provisioning before the first frame so the
  // router does not briefly see a signed-in user with no profile document.
  await AuthManager.instance.completePendingRedirect();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  late StreamSubscription<User?> _authSubscription;

  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.path;
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);

    // Auth state listener: resolve the account's role BEFORE refreshing the
    // router, so route guards evaluate against a known role instead of
    // briefly assuming "patient".
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) async {
      await RoleManager.instance.refreshFor(user?.uid);
      if (mounted) _appStateNotifier.update();
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'HerTwin Wellness',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
