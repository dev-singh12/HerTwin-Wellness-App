import '/components/button/button_widget.dart';
import '/components/calendar_pill/calendar_pill_widget.dart';
import '/components/status_card/status_card_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'home_dashboard_widget.dart' show HomeDashboardWidget;
import 'package:flutter/material.dart';

class HomeDashboardModel extends FlutterFlowModel<HomeDashboardWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for CalendarPill.
  late CalendarPillModel calendarPillModel1;
  // Model for CalendarPill.
  late CalendarPillModel calendarPillModel2;
  // Model for CalendarPill.
  late CalendarPillModel calendarPillModel3;
  // Model for CalendarPill.
  late CalendarPillModel calendarPillModel4;
  // Model for CalendarPill.
  late CalendarPillModel calendarPillModel5;
  // Model for CalendarPill.
  late CalendarPillModel calendarPillModel6;
  // Model for CalendarPill.
  late CalendarPillModel calendarPillModel7;
  // Model for StatusCard.
  late StatusCardModel statusCardModel1;
  // Model for StatusCard.
  late StatusCardModel statusCardModel2;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    calendarPillModel1 = createModel(context, () => CalendarPillModel());
    calendarPillModel2 = createModel(context, () => CalendarPillModel());
    calendarPillModel3 = createModel(context, () => CalendarPillModel());
    calendarPillModel4 = createModel(context, () => CalendarPillModel());
    calendarPillModel5 = createModel(context, () => CalendarPillModel());
    calendarPillModel6 = createModel(context, () => CalendarPillModel());
    calendarPillModel7 = createModel(context, () => CalendarPillModel());
    statusCardModel1 = createModel(context, () => StatusCardModel());
    statusCardModel2 = createModel(context, () => StatusCardModel());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    calendarPillModel1.dispose();
    calendarPillModel2.dispose();
    calendarPillModel3.dispose();
    calendarPillModel4.dispose();
    calendarPillModel5.dispose();
    calendarPillModel6.dispose();
    calendarPillModel7.dispose();
    statusCardModel1.dispose();
    statusCardModel2.dispose();
    buttonModel.dispose();
  }
}
