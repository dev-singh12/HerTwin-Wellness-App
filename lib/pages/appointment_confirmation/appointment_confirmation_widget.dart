import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'appointment_confirmation_model.dart';
export 'appointment_confirmation_model.dart';

class AppointmentConfirmationWidget extends StatefulWidget {
  const AppointmentConfirmationWidget({super.key, this.appointmentId});
  final String? appointmentId;

  static String routeName = 'AppointmentConfirmation';
  static String routePath = '/appointment-confirmation';

  @override
  State<AppointmentConfirmationWidget> createState() => _AppointmentConfirmationWidgetState();
}

class _AppointmentConfirmationWidgetState extends State<AppointmentConfirmationWidget> with SingleTickerProviderStateMixin {
  late AppointmentConfirmationModel _model;
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AppointmentConfirmationModel());
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>? ?? {};
    final doctorName = extra['doctorName'] as String? ?? 'Your specialist';
    final scheduledStr = extra['scheduledAt'] as String?;
    final scheduledAt = scheduledStr != null ? DateTime.tryParse(scheduledStr) : null;

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(color: Color(0xFF4DB6AC), shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, size: 56, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Appointment Booked! \u{1F389}', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: FlutterFlowTheme.of(context).primaryText)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))]),
                  child: Column(children: [
                    Text(doctorName, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                    if (scheduledAt != null) ...[
                      const SizedBox(height: 4),
                      Text(DateFormat('EEEE, MMM d \u{2022} h:mm a').format(scheduledAt), style: GoogleFonts.inter(fontSize: 14, color: FlutterFlowTheme.of(context).secondaryText)),
                    ],
                  ]),
                ),
                const SizedBox(height: 12),
                Text('We\'ve notified $doctorName', style: GoogleFonts.inter(fontSize: 14, color: FlutterFlowTheme.of(context).secondaryText)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => context.pushNamed(ConsultationChatWidget.routeName),
                    style: ElevatedButton.styleFrom(backgroundColor: FlutterFlowTheme.of(context).primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: Text('Go to Chat \u{2192}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => context.goNamed(HomeDashboardWidget.routeName),
                    style: OutlinedButton.styleFrom(side: BorderSide(color: FlutterFlowTheme.of(context).primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: Text('Back to Dashboard', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: FlutterFlowTheme.of(context).primary)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
