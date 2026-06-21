import '/auth/auth_manager.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'reminder_management_model.dart';
export 'reminder_management_model.dart';

class ReminderManagementWidget extends StatefulWidget {
  const ReminderManagementWidget({super.key});

  static String routeName = 'ReminderManagement';
  static String routePath = '/reminder-management';

  @override
  State<ReminderManagementWidget> createState() => _ReminderManagementWidgetState();
}

class _ReminderManagementWidgetState extends State<ReminderManagementWidget> {
  late ReminderManagementModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReminderManagementModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthManager.instance.currentUid;
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: theme.primaryText),
          onPressed: () => context.safePop(),
        ),
        title: Text('My Reminders', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryText)),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.add, size: 18, color: theme.primary),
            label: Text('Add', style: GoogleFonts.inter(color: theme.primary, fontWeight: FontWeight.w600)),
            onPressed: uid == null ? null : () => _showAddReminderSheet(context, uid),
          ),
        ],
      ),
      body: SafeArea(
        child: uid == null
            ? const Center(child: Text('Please sign in.'))
            : StreamBuilder<List<MedicineReminderRecord>>(
                stream: streamReminders(uid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Couldn't load reminders.", style: GoogleFonts.inter(color: theme.secondaryText)));
                  }
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator(color: theme.primary));
                  }
                  final reminders = snapshot.data!;
                  if (reminders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_none, size: 56, color: theme.secondaryText.withAlpha(100)),
                          const SizedBox(height: 12),
                          Text('No reminders yet', style: GoogleFonts.inter(fontSize: 16, color: theme.secondaryText)),
                          const SizedBox(height: 8),
                          Text('Tap + Add to create your first reminder', style: GoogleFonts.inter(fontSize: 13, color: theme.secondaryText)),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: reminders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final r = reminders[i];
                      final iconData = _iconForType(r.iconType);
                      final iconColor = Color(r.iconColorValue);
                      return Dismissible(
                        key: ValueKey(r.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(color: theme.error, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => deleteReminder(uid, r.id),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(color: iconColor.withAlpha(30), borderRadius: BorderRadius.circular(12)),
                                child: Icon(iconData, size: 24, color: iconColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r.medicineName, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                                    Text('${r.dosage} \u{2022} ${r.frequency.replaceAll('_', ' ')}',
                                        style: GoogleFonts.inter(fontSize: 12, color: theme.secondaryText)),
                                    if (r.reminderTimes.isNotEmpty)
                                      Wrap(
                                        spacing: 6,
                                        children: r.reminderTimes.map((t) => Chip(
                                          label: Text(t, style: GoogleFonts.inter(fontSize: 11)),
                                          padding: EdgeInsets.zero,
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          backgroundColor: theme.primary.withAlpha(20),
                                        )).toList(),
                                      ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: r.isActive,
                                activeTrackColor: theme.primary.withAlpha(100),
                                activeThumbColor: theme.primary,
                                onChanged: (v) => updateReminder(uid, r.id, {'isActive': v}),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'vitamin': return Icons.eco;
      case 'syrup': return Icons.local_drink;
      case 'injection': return Icons.vaccines;
      default: return Icons.medication;
    }
  }

  void _showAddReminderSheet(BuildContext context, String uid) {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    String iconType = 'pill';
    int iconColorValue = 0xFFEFA6B3;
    String frequency = 'daily';
    List<String> times = ['09:00'];
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Text('Add Reminder', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Medicine Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: dosageCtrl,
                  decoration: InputDecoration(
                    labelText: 'Dosage (e.g. 500mg)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Type', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['pill', 'vitamin', 'syrup', 'injection'].map((t) => ChoiceChip(
                    label: Text(t),
                    selected: iconType == t,
                    selectedColor: FlutterFlowTheme.of(context).primary.withAlpha(30),
                    onSelected: (_) => setSheetState(() => iconType = t),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                Text('Frequency', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['daily', 'twice_daily', 'alternate_days'].map((f) => ChoiceChip(
                    label: Text(f.replaceAll('_', ' ')),
                    selected: frequency == f,
                    selectedColor: FlutterFlowTheme.of(context).primary.withAlpha(30),
                    onSelected: (_) => setSheetState(() {
                      frequency = f;
                      times = f == 'twice_daily' ? ['09:00', '21:00'] : ['09:00'];
                    }),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                Text('Times', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: times.asMap().entries.map((e) => ActionChip(
                    label: Text(e.value),
                    backgroundColor: FlutterFlowTheme.of(context).primary.withAlpha(20),
                    onPressed: () async {
                      final picked = await showTimePicker(context: ctx, initialTime: TimeOfDay(hour: int.parse(e.value.split(':')[0]), minute: 0));
                      if (picked != null) {
                        setSheetState(() => times[e.key] = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
                      }
                    },
                  )).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: saving || nameCtrl.text.trim().isEmpty ? null : () async {
                      setSheetState(() => saving = true);
                      try {
                        final id = newReminderId(uid);
                        await createReminder(uid, MedicineReminderRecord(
                          id: id, uid: uid,
                          medicineName: nameCtrl.text.trim(),
                          dosage: dosageCtrl.text.trim(),
                          frequency: frequency,
                          reminderTimes: times,
                          iconType: iconType,
                          iconColorValue: iconColorValue,
                          createdAt: DateTime.now(),
                        ));
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      } catch (_) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not save reminder.')));
                      }
                      if (ctx.mounted) setSheetState(() => saving = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FlutterFlowTheme.of(context).primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Save Reminder', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
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
