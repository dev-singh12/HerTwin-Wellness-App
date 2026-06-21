import '/flutter_flow/flutter_flow_util.dart';
import 'doctor_selection_widget.dart' show DoctorSelectionWidget;
import 'package:flutter/material.dart';

class DoctorSelectionModel extends FlutterFlowModel<DoctorSelectionWidget> {
  String selectedSpecialty = 'All';
  String? selectedDoctorId;
  String? selectedDate;
  String? selectedTimeSlot;
  String? selectedConsultationType;
  TextEditingController notesController = TextEditingController();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    notesController.dispose();
  }
}
