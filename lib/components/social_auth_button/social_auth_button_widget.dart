import '/components/app_image.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'social_auth_button_model.dart';
export 'social_auth_button_model.dart';

class SocialAuthButtonWidget extends StatefulWidget {
  const SocialAuthButtonWidget({
    super.key,
    String? provider_icon,
    String? provider_name,
    this.enabled = true,
    this.trailingLabel,
  })  : this.provider_icon = provider_icon ?? AppImages.googleLogo,
        this.provider_name = provider_name ?? 'Google';

  /// Bundled asset path. Icons used to be pulled from cdn.simpleicons.org at
  /// runtime, which meant the sign-in buttons rendered blank when offline or
  /// if that CDN was down — and it sent a request to a third party before the
  /// user had agreed to anything.
  final String provider_icon;
  final String provider_name;

  /// When false the button renders muted and non-interactive. A control that
  /// looks live but is not is worse than no control at all.
  final bool enabled;

  /// Optional badge, e.g. "Coming soon".
  final String? trailingLabel;

  @override
  State<SocialAuthButtonWidget> createState() => _SocialAuthButtonWidgetState();
}

class _SocialAuthButtonWidgetState extends State<SocialAuthButtonWidget> {
  late SocialAuthButtonModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SocialAuthButtonModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final enabled = widget.enabled;

    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Continue with ${widget.provider_name}',
      child: Opacity(
        opacity: enabled ? 1.0 : 0.45,
        child: Container(
          height: 56.0,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(28.0),
            shape: BoxShape.rectangle,
            border: Border.all(
              color: theme.alternate,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  widget.provider_icon,
                  width: 22.0,
                  height: 22.0,
                  fit: BoxFit.contain,
                ),
                Flexible(
                  child: Text(
                    'Continue with ${widget.provider_name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.titleSmall.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.w500,
                        fontStyle: theme.titleSmall.fontStyle,
                      ),
                      color: theme.primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      fontStyle: theme.titleSmall.fontStyle,
                    ),
                  ),
                ),
                if (widget.trailingLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: theme.alternate,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      widget.trailingLabel!,
                      style: GoogleFonts.inter(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w600,
                        color: theme.secondaryText,
                      ),
                    ),
                  ),
              ].divide(SizedBox(width: 12.0)),
            ),
          ),
        ),
      ),
    );
  }
}
