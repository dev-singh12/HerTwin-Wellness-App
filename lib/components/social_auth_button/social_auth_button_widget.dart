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
  })  : this.provider_icon =
            provider_icon ?? 'https://cdn.simpleicons.org/google/3d3d3d.svg',
        this.provider_name = provider_name ?? 'Google';

  final String provider_icon;
  final String provider_name;

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
    return Container(
      height: 56.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(28.0),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
        child: Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.network(
                valueOrDefault<String>(
                  widget.provider_icon,
                  'https://cdn.simpleicons.org/google/3d3d3d.svg',
                ),
                width: 22.0,
                height: 22.0,
                fit: BoxFit.contain,
              ),
              Text(
                'Continue with ${widget.provider_name}',
                style: FlutterFlowTheme.of(context).titleSmall.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).titleSmall.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(context).titleSmall.fontStyle,
                    ),
              ),
            ].divide(SizedBox(width: 16.0)),
          ),
        ),
      ),
    );
  }
}
