import '/auth/auth_manager.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'doctor_selection_model.dart';
export 'doctor_selection_model.dart';

class DoctorSelectionWidget extends StatefulWidget {
  const DoctorSelectionWidget({super.key, this.appointmentType});
  final String? appointmentType;

  static String routeName = 'DoctorSelection';
  static String routePath = '/doctor-selection';

  @override
  State<DoctorSelectionWidget> createState() => _DoctorSelectionWidgetState();
}

class _DoctorSelectionWidgetState extends State<DoctorSelectionWidget> {
  late DoctorSelectionModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DoctorSelectionModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  final _specialties = ['All', 'Gynaecologist', 'Endocrinologist', 'Psychologist', 'Nutritionist & Dietician'];

  @override
  Widget build(BuildContext context) {
    final uid = AuthManager.instance.currentUid;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      onPressed: () => context.safePop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Choose Your Specialist',
                              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: FlutterFlowTheme.of(context).primaryText)),
                          Text('Matched to your health profile',
                              style: GoogleFonts.inter(fontSize: 13, color: FlutterFlowTheme.of(context).secondaryText)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Filter chips
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _specialties.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final s = _specialties[i];
                    final active = _model.selectedSpecialty == s;
                    return GestureDetector(
                      onTap: () => safeSetState(() => _model.selectedSpecialty = s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? FlutterFlowTheme.of(context).primary : Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: active ? FlutterFlowTheme.of(context).primary : const Color(0xFFE0E0E0)),
                        ),
                        child: Text(s, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500,
                            color: active ? Colors.white : FlutterFlowTheme.of(context).secondaryText)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Doctor list
              Expanded(
                child: StreamBuilder<List<DoctorRecord>>(
                  stream: streamAvailableDoctors(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Couldn't load doctors. Try again.",
                          style: GoogleFonts.inter(color: FlutterFlowTheme.of(context).secondaryText)));
                    }
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator(color: FlutterFlowTheme.of(context).primary));
                    }
                    var doctors = snapshot.data!;
                    if (_model.selectedSpecialty != 'All') {
                      doctors = doctors.where((d) => d.specialty == _model.selectedSpecialty).toList();
                    }
                    if (doctors.isEmpty) {
                      return Center(child: Text('No specialists available for this filter.',
                          style: GoogleFonts.inter(color: FlutterFlowTheme.of(context).secondaryText)));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: doctors.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _DoctorCard(
                        doctor: doctors[i],
                        onBook: () => _showBookingSheet(context, doctors[i], uid),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingSheet(BuildContext context, DoctorRecord doctor, String? uid) {
    if (uid == null) return;
    final isFree = widget.appointmentType != 'paid';
    String? selectedType = isFree ? 'free_first' : null;
    String? selectedDate;
    String? selectedSlot;
    final notesCtrl = TextEditingController();
    final dates = List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
    bool booking = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.75,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            expand: false,
            builder: (_, scrollController) => SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),
                  // Doctor mini card
                  Row(children: [
                    _buildAvatar(doctor, 48),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(doctor.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(doctor.specialty, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
                    ]),
                  ]),
                  const SizedBox(height: 20),
                  // Consultation type
                  Text('Select Consultation Type', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (isFree)
                    _ConsultTypeCard(icon: Icons.chat_bubble_outline, label: 'Free Chat Consultation', subtitle: '15-30 min', price: 'FREE', selected: true, onTap: () {})
                  else ...[
                    _ConsultTypeCard(icon: Icons.chat_bubble_outline, label: 'Chat Consultation', subtitle: '15-30 min real-time chat', price: '\u{20B9}300', selected: selectedType == 'chat', onTap: () => setSheetState(() => selectedType = 'chat')),
                    const SizedBox(height: 8),
                    _ConsultTypeCard(icon: Icons.videocam_outlined, label: 'Video Call', subtitle: '30 min video consultation', price: '\u{20B9}500', selected: selectedType == 'video', onTap: () => setSheetState(() => selectedType = 'video')),
                  ],
                  const SizedBox(height: 20),
                  // Date selection
                  Text('Select Date', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: dates.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final d = dates[i];
                        final key = DateFormat('yyyy-MM-dd').format(d);
                        final active = selectedDate == key;
                        return GestureDetector(
                          onTap: () => setSheetState(() => selectedDate = key),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: active ? FlutterFlowTheme.of(context).primary : Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: active ? FlutterFlowTheme.of(context).primary : const Color(0xFFE0E0E0)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(DateFormat('EEE').format(d), style: GoogleFonts.inter(fontSize: 11, color: active ? Colors.white : Colors.grey)),
                                Text('${d.day}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: active ? Colors.white : FlutterFlowTheme.of(context).primaryText)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Time slots
                  Text('Select Time Slot', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  FutureBuilder<List<String>>(
                    future: selectedDate != null ? getDoctorSlots(doctor.id, selectedDate!) : Future.value([]),
                    builder: (_, snap) {
                      final slots = snap.data ?? [];
                      if (slots.isEmpty) return Text('Select a date first', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey));
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: slots.map((s) {
                          final active = selectedSlot == s;
                          return GestureDetector(
                            onTap: () => setSheetState(() => selectedSlot = s),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: active ? FlutterFlowTheme.of(context).primary : Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: active ? FlutterFlowTheme.of(context).primary : const Color(0xFFE0E0E0)),
                              ),
                              child: Text(s, style: GoogleFonts.inter(fontSize: 13, color: active ? Colors.white : FlutterFlowTheme.of(context).primaryText)),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Notes
                  Text('Add Notes (Optional)', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: notesCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Any specific concerns for your doctor...',
                      hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // CTA
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (selectedDate == null || selectedSlot == null || (selectedType == null && !isFree) || booking) ? null : () async {
                        setSheetState(() => booking = true);
                        try {
                          final appointmentId = newAppointmentId();
                          // Prices must match the tiers shown above (₹300 chat /
                          // ₹500 video). Pilot runs in demo mode: no gateway,
                          // no money moves, and paymentStatus is not something
                          // the client could assert as 'paid' anyway — the
                          // security rules only accept 'demo' or 'unpaid'.
                          final price = isFree
                              ? 0
                              : (selectedType == 'chat' ? 300 : 500);
                          final scheduledAt = DateFormat('yyyy-MM-dd').parse(selectedDate!).add(Duration(
                            hours: int.parse(selectedSlot!.split(':')[0]),
                            minutes: int.parse(selectedSlot!.split(':')[1]),
                          ));
                          // Denormalize the clinical context onto the booking so
                          // the doctor's queue renders without a read per row.
                          final patient = await getUser(uid);
                          final type = isFree ? 'free_first' : (selectedType ?? 'chat');
                          await bookAppointment(AppointmentRecord(
                            id: appointmentId,
                            patientUid: uid,
                            patientName: patient?.displayName ?? '',
                            patientPhotoUrl: patient?.photoUrl ?? '',
                            patientAge: patient?.effectiveAge ?? 0,
                            patientCondition: patient?.conditionType ?? '',
                            patientSeverity: patient?.latestSeverityLabel ?? '',
                            patientScore: patient?.healthVitalityScore ?? 0,
                            doctorUid: doctor.id,
                            doctorName: doctor.name,
                            doctorPhotoUrl: doctor.photoUrl,
                            doctorSpecialty: doctor.specialty,
                            consultationType: type,
                            priceRs: price,
                            paymentStatus: 'demo',
                            status: 'booked',
                            scheduledAt: scheduledAt,
                            meetingLink: type == 'video'
                                ? jitsiRoomUrl(appointmentId, generateRoomSecret())
                                : null,
                            reasonForVisit: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                            createdAt: DateTime.now(),
                          ));
                          if (isFree) {
                            await updateUser(uid, {'hasUsedFreeConsultation': true, 'primaryDoctorId': doctor.id, 'primaryDoctorName': doctor.name});
                          }
                          if (!ctx.mounted) return;
                          Navigator.of(ctx).pop();
                          context.pushNamed(AppointmentConfirmationWidget.routeName,
                              extra: {'appointmentId': appointmentId, 'doctorName': doctor.name, 'scheduledAt': scheduledAt.toIso8601String()});
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking failed. Please try again.'), backgroundColor: FlutterFlowTheme.of(context).error));
                        } finally {
                          if (ctx.mounted) setSheetState(() => booking = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: booking
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(isFree ? 'Confirm Free Booking' : 'Pay & Book',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                  if (!isFree) ...[
                    const SizedBox(height: 8),
                    Center(child: Text('Demo booking \u{2014} no payment is taken', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey))),
                    // TODO: Razorpay integration — see https://razorpay.com/docs/payments/payment-gateway/flutter-integration/
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(DoctorRecord doctor, double size) {
    if (doctor.photoUrl.isNotEmpty) {
      return ClipOval(child: CachedNetworkImage(imageUrl: doctor.photoUrl, width: size, height: size, fit: BoxFit.cover));
    }
    final hash = doctor.name.hashCode;
    final colors = [const Color(0xFFEFA6B3), const Color(0xFF9FA8DA), const Color(0xFFA5D6A7), const Color(0xFF80CBC4), const Color(0xFFF9CF58)];
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: colors[hash.abs() % colors.length],
      child: Text(doctor.initials, style: GoogleFonts.poppins(fontSize: size * 0.35, fontWeight: FontWeight.w600, color: Colors.white)),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor, required this.onBook});
  final DoctorRecord doctor;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final hash = doctor.name.hashCode;
    final colors = [const Color(0xFFEFA6B3), const Color(0xFF9FA8DA), const Color(0xFFA5D6A7), const Color(0xFF80CBC4), const Color(0xFFF9CF58)];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: colors[hash.abs() % colors.length],
            child: doctor.photoUrl.isNotEmpty
                ? ClipOval(child: CachedNetworkImage(imageUrl: doctor.photoUrl, width: 60, height: 60, fit: BoxFit.cover))
                : Text(doctor.initials, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                Text(doctor.specialty, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star, size: 14, color: Color(0xFFF9CF58)),
                  const SizedBox(width: 4),
                  Text('${doctor.rating}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(' \u{2022} ${doctor.reviewCount} reviews', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                ]),
                Text('${doctor.qualifications} \u{2022} ${doctor.yearsExperience} yrs exp', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: doctor.conditionsTreated.take(3).map((c) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF9FA8DA).withAlpha(30), borderRadius: BorderRadius.circular(50)),
                    child: Text(c.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF9FA8DA))),
                  )).toList(),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: doctor.isAvailable ? const Color(0xFFA5D6A7).withAlpha(40) : Colors.grey.withAlpha(30),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(doctor.isAvailable ? 'Available' : 'Busy',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: doctor.isAvailable ? const Color(0xFF4CAF50) : Colors.grey)),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onBook,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: FlutterFlowTheme.of(context).primary),
                  ),
                  child: Text('Book Now', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: FlutterFlowTheme.of(context).primary)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConsultTypeCard extends StatelessWidget {
  const _ConsultTypeCard({required this.icon, required this.label, required this.subtitle, required this.price, required this.selected, required this.onTap});
  final IconData icon;
  final String label;
  final String subtitle;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? FlutterFlowTheme.of(context).primary.withAlpha(20) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? FlutterFlowTheme.of(context).primary : const Color(0xFFE0E0E0)),
        ),
        child: Row(children: [
          Icon(icon, size: 24, color: selected ? FlutterFlowTheme.of(context).primary : Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
          ])),
          Text(price, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: price == 'FREE' ? const Color(0xFF4CAF50) : FlutterFlowTheme.of(context).primaryText)),
          if (selected) ...[const SizedBox(width: 8), Icon(Icons.check_circle, size: 20, color: FlutterFlowTheme.of(context).primary)],
        ]),
      ),
    );
  }
}
