import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Renders an image from either a bundled asset path or a remote URL.
///
/// Decorative artwork is bundled under `assets/images/` so the app does not
/// depend on a third-party image host being up. User-supplied content (profile
/// photos, doctor portraits from Storage) is still fetched and cached over the
/// network — those genuinely are remote.
///
/// Anything that is not an `assets/` path is treated as a URL, and a failed
/// load degrades to [fallback] rather than a broken-image box.
class AppImage extends StatelessWidget {
  const AppImage(
    this.path, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fallback,
  });

  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? fallback;

  bool get _isAsset => path.startsWith('assets/');
  bool get _isDataUri => path.startsWith('data:');

  @override
  Widget build(BuildContext context) {
    final placeholder = fallback ??
        Container(color: Theme.of(context).dividerColor.withValues(alpha: 0.2));

    if (path.isEmpty) return SizedBox(width: width, height: height, child: placeholder);

    // Base64 image stored inline in Firestore (the free-tier stand-in for
    // Cloud Storage). Decode once and render from memory.
    if (_isDataUri) {
      final comma = path.indexOf(',');
      if (comma < 0) return placeholder;
      try {
        final bytes = base64Decode(path.substring(comma + 1));
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => placeholder,
        );
      } catch (_) {
        return placeholder;
      }
    }

    if (_isAsset) {
      return Image.asset(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    return CachedNetworkImage(
      imageUrl: path,
      fit: fit,
      width: width,
      height: height,
      placeholder: (_, __) => placeholder,
      errorWidget: (_, __, ___) => placeholder,
    );
  }
}

/// Bundled artwork paths, so the strings live in one place instead of being
/// repeated across pages.
class AppImages {
  AppImages._();

  static const yogaSunlitRoom = 'assets/images/yoga_sunlit_room.jpg';
  static const yogaRestorativeCalm = 'assets/images/yoga_restorative_calm.jpg';
  static const workoutBrightStudio = 'assets/images/workout_bright_studio.jpg';
  static const stretchingEveningLight =
      'assets/images/stretching_evening_light.jpg';
  static const womanPortraitSoft = 'assets/images/woman_portrait_soft.jpg';
  static const doctorPortrait = 'assets/images/doctor_portrait.jpg';

  static const lottieSuccessCheckmark = 'assets/jsons/success_checkmark.json';
  static const lottieBloomingFlower = 'assets/jsons/blooming_flower.json';

  /// Google's official four-colour "G". Their branding guidelines require the
  /// real mark on a "Continue with Google" button, not a monochrome glyph.
  static const googleLogo = 'assets/images/google_logo.svg';

  /// Full HerTwin brand wordmark (butterfly + "HERTWIN — Your Body.
  /// Understood."). Drop the brand PNG at this path; until it exists the auth
  /// screen degrades to a text wordmark via AppImage's fallback.
  static const logoWordmark = 'assets/branding/logo_wordmark.png';
}
