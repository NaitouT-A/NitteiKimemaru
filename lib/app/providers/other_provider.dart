import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez2gether/app/models/schedule_model.dart';

final scheduleProvider =
    StateNotifierProvider<ScheduleController, ScheduleState>((ref) {
  return ScheduleController();
});
