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

  String get _todayStr => DateFormat('yyyy-MM-dd').format(DateTime.now());

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

  // ── Helpers ──────────────────────────────────────────────────────────────

  IconData _iconForType(String type) {
    switch (type) {
      case 'vitamin': return Icons.eco;
      case 'syrup': return Icons.local_drink;
      case 'injection': return Icons.vaccines;
      default: return Icons.medication;
    }
  }

  String _formatTime(String time24) {
    final parts = time24.split(':');
    if (parts.length != 2) return time24;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts[1];
    final ampm = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:$m $ampm';
  }

  // ── Build ────────────────────────────────────────────────────────────────

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
            onPressed: uid == null ? null : () => _showReminderSheet(context, uid, null),
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

                  final active = reminders.where((r) => r.isActive).toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Today's Medicines ──────────────────────────
                        if (active.isNotEmpty) ...[
                          _sectionHeader(theme, "Today's Medicines", '${DateFormat('EEEE, MMM d').format(DateTime.now())}'),
                          const SizedBox(height: 8),
                          StreamBuilder<List<ReminderLogRecord>>(
                            stream: streamReminderLogs(uid, _todayStr),
                            builder: (context, logSnap) {
                              final logs = logSnap.data ?? [];
                              return Column(
                                children: active.map((r) => _buildTodayCard(uid, r, logs, theme)).toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],

                        // ── All Reminders ──────────────────────────────
                        _sectionHeader(theme, 'All Reminders', '${reminders.length} total'),
                        const SizedBox(height: 8),
                        ...reminders.map((r) => _buildReminderCard(uid, r, theme)),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  // ── Section header ───────────────────────────────────────────────────────

  Widget _sectionHeader(FlutterFlowTheme theme, String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: theme.primaryText)),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: theme.secondaryText)),
      ],
    );
  }

  // ── Today card (per-time checkboxes) ─────────────────────────────────────

  Widget _buildTodayCard(String uid, MedicineReminderRecord r,
      List<ReminderLogRecord> logs, FlutterFlowTheme theme) {
    final log = logs.where((l) => l.reminderId == r.id).firstOrNull;
    final iconColor = Color(r.iconColorValue);
    final checkedCount = r.reminderTimes.where((t) => log?.timesChecked[t] == true).length;
    final allDone = checkedCount == r.reminderTimes.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: allDone ? theme.success.withAlpha(15) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: allDone ? theme.success.withAlpha(80) : theme.alternate, width: 1),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: iconColor.withAlpha(30), borderRadius: BorderRadius.circular(10)),
                child: Icon(_iconForType(r.iconType), size: 22, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.medicineName, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600,
                      decoration: allDone ? TextDecoration.lineThrough : null,
                      color: allDone ? theme.secondaryText : theme.primaryText)),
                    Text('${r.dosage} \u{2022} $checkedCount/${r.reminderTimes.length} done',
                        style: GoogleFonts.inter(fontSize: 12, color: theme.secondaryText)),
                  ],
                ),
              ),
              if (allDone)
                Icon(Icons.check_circle_rounded, color: theme.success, size: 24),
            ],
          ),
          if (r.reminderTimes.length > 1 || !allDone) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: r.reminderTimes.map((t) {
                final checked = log?.timesChecked[t] == true;
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => updateReminderLog(uid, r.id, _todayStr, t, !checked),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: checked ? theme.success.withAlpha(30) : theme.alternate,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: checked ? theme.success : Colors.transparent, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          checked ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                          size: 16,
                          color: checked ? theme.success : theme.secondaryText,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatTime(t),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: checked ? theme.success : theme.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ── Reminder management card ─────────────────────────────────────────────

  Widget _buildReminderCard(String uid, MedicineReminderRecord r, FlutterFlowTheme theme) {
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
      child: GestureDetector(
        onTap: () => _showReminderSheet(context, uid, r),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
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
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Wrap(
                          spacing: 6,
                          children: r.reminderTimes.map((t) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(_formatTime(t), style: GoogleFonts.inter(fontSize: 11, color: theme.primaryText)),
                          )).toList(),
                        ),
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
      ),
    );
  }

  // ── Add / Edit bottom sheet ──────────────────────────────────────────────

  void _showReminderSheet(BuildContext context, String uid, MedicineReminderRecord? existing) {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.medicineName ?? '');
    final dosageCtrl = TextEditingController(text: existing?.dosage ?? '');
    String iconType = existing?.iconType ?? 'pill';
    String frequency = existing?.frequency ?? 'daily';
    List<String> times = existing?.reminderTimes.toList() ?? ['09:00'];
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
                Text(isEdit ? 'Edit Reminder' : 'Add Reminder', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
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
                      if (!isEdit) {
                        times = f == 'twice_daily' ? ['09:00', '21:00'] : ['09:00'];
                      }
                    }),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Times', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    if (frequency != 'daily')
                      IconButton(
                        icon: Icon(Icons.add_circle_outline, size: 20, color: FlutterFlowTheme.of(context).primary),
                        onPressed: () => setSheetState(() => times.add('12:00')),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: times.asMap().entries.map((e) => ActionChip(
                    label: Text(_formatTime(e.value)),
                    avatar: Icon(Icons.access_time, size: 16, color: FlutterFlowTheme.of(context).primary),
                    backgroundColor: FlutterFlowTheme.of(context).primary.withAlpha(20),
                    onPressed: () async {
                      final picked = await showTimePicker(context: ctx, initialTime: TimeOfDay(hour: int.parse(e.value.split(':')[0]), minute: int.parse(e.value.split(':')[1])));
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
                        if (isEdit) {
                          await updateReminder(uid, existing.id, {
                            'medicineName': nameCtrl.text.trim(),
                            'dosage': dosageCtrl.text.trim(),
                            'frequency': frequency,
                            'reminderTimes': times,
                            'iconType': iconType,
                          });
                        } else {
                          final id = newReminderId(uid);
                          await createReminder(uid, MedicineReminderRecord(
                            id: id, uid: uid,
                            medicineName: nameCtrl.text.trim(),
                            dosage: dosageCtrl.text.trim(),
                            frequency: frequency,
                            reminderTimes: times,
                            iconType: iconType,
                            iconColorValue: _colorForType(iconType),
                            createdAt: DateTime.now(),
                          ));
                        }
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
                        : Text(isEdit ? 'Update Reminder' : 'Save Reminder',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _colorForType(String type) {
    switch (type) {
      case 'vitamin': return 0xFF66BB6A;
      case 'syrup': return 0xFF42A5F5;
      case 'injection': return 0xFFAB47BC;
      default: return 0xFFEFA6B3;
    }
  }
}
