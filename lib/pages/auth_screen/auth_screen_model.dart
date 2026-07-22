import '/components/button/button_widget.dart';
import '/components/social_auth_button/social_auth_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'auth_screen_widget.dart' show AuthScreenWidget;
import 'package:flutter/material.dart';

class AuthScreenModel extends FlutterFlowModel<AuthScreenWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for the Google SocialAuthButton. There was a second one for Apple;
  // it was removed along with the button, which raised an error when tapped.
  late SocialAuthButtonModel socialAuthButtonModel1;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    socialAuthButtonModel1 =
        createModel(context, () => SocialAuthButtonModel());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    socialAuthButtonModel1.dispose();
    buttonModel.dispose();
  }
}
