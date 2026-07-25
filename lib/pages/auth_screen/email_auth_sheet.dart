import 'package:flutter/material.dart';

import '/auth/auth_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'post_auth.dart';

/// Bottom sheet that hosts the email/password sign-in & sign-up form.
///
/// Added on top of the FlutterFlow [AuthScreenWidget], which ships only social
/// buttons and no text fields. Wired to [AuthManager]. On success it pops with
/// the mode used ('signup' | 'signin'); the opener then runs the shared
/// [completeAuthNavigation] so member/doctor routing lives in one place.
class EmailAuthSheet extends StatefulWidget {
  const EmailAuthSheet({
    super.key,
    this.asDoctor = false,
    this.startSignUp = false,
  });

  /// Whether the user chose the Doctor role on the auth screen. Passed through
  /// only so the header reads correctly; the gating happens post-pop.
  final bool asDoctor;

  /// Open straight into sign-up (from the "Sign up" button) vs sign-in.
  final bool startSignUp;

  @override
  State<EmailAuthSheet> createState() => _EmailAuthSheetState();
}

class _EmailAuthSheetState extends State<EmailAuthSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late bool _isSignUp = widget.startSignUp;
  bool _obscurePassword = true;
  bool _isLoading = false;

  static final _emailRegex =
      RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (!_isSignUp) return null;
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Please enter your email.';
    if (!_emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Please enter a password.';
    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
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

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        await AuthManager.instance.signUpWithEmail(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
        );
      } else {
        await AuthManager.instance.signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
      }
      // Hand the mode back to the opener, which runs the shared role-aware
      // routing (member → onboarding/home, doctor → dashboard or pending).
      if (mounted) Navigator.of(context).pop(_isSignUp ? 'signup' : 'signin');
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (_emailRegex.hasMatch(email) == false) {
      _showError('Enter your email above first, then tap reset.');
      return;
    }
    try {
      await AuthManager.instance.resetPassword(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Password reset email sent.')),
        );
    } catch (e) {
      _showError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 24.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: theme.alternate,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              _isSignUp ? 'Create your account' : 'Welcome back',
              style: theme.headlineSmall,
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                Icon(
                  widget.asDoctor
                      ? Icons.medical_services_outlined
                      : Icons.person_outline_rounded,
                  size: 15.0,
                  color: theme.secondaryText,
                ),
                const SizedBox(width: 6.0),
                Text(
                  widget.asDoctor ? 'Doctor account' : 'Member account',
                  style: theme.labelMedium.override(
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            if (_isSignUp) ...[
              TextFormField(
                controller: _nameController,
                enabled: !_isLoading,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: _validateName,
              ),
              const SizedBox(height: 16.0),
            ],
            TextFormField(
              controller: _emailController,
              enabled: !_isLoading,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: _validateEmail,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              enabled: !_isLoading,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: _validatePassword,
            ),
            if (!_isSignUp)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: _isLoading ? null : _forgotPassword,
                  child: const Text('Forgot password?'),
                ),
              ),
            const SizedBox(height: 8.0),
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: theme.primary,
                minimumSize: const Size.fromHeight(52.0),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22.0,
                      height: 22.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
            ),
            const SizedBox(height: 8.0),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () => setState(() => _isSignUp = !_isSignUp),
              child: Text(
                _isSignUp
                    ? 'Already have an account? Sign in'
                    : "Don't have an account? Sign up",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens the email auth form as a modal bottom sheet, then runs the shared
/// role-aware routing once it closes on success.
Future<void> showEmailAuthSheet(
  BuildContext context, {
  bool asDoctor = false,
  bool startSignUp = false,
}) async {
  final mode = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
    ),
    builder: (_) =>
        EmailAuthSheet(asDoctor: asDoctor, startSignUp: startSignUp),
  );
  if (mode != null && context.mounted) {
    await completeAuthNavigation(
      context,
      asDoctor: asDoctor,
      wasSignUp: mode == 'signup',
    );
  }
}
