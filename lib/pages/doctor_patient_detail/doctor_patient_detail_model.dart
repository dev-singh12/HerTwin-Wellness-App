import '/flutter_flow/flutter_flow_util.dart';
import 'doctor_patient_detail_widget.dart' show DoctorPatientDetailWidget;
import 'package:flutter/material.dart';

class DoctorPatientDetailModel
    extends FlutterFlowModel<DoctorPatientDetailWidget> {
  TextEditingController? notesController;
  TextEditingController? prescriptionController;

  /// Set once the appointment loads, so reopening the sheet does not clobber
  /// text the clinician is part-way through typing.
  bool seededFromRecord = false;
  bool saving = false;

  @override
  void initState(BuildContext context) {
    notesController = TextEditingController();
    prescriptionController = TextEditingController();
  }

  @override
  void dispose() {
    notesController?.dispose();
    prescriptionController?.dispose();
  }
}
