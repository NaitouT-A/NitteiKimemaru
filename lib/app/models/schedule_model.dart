import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_model.freezed.dart';
part 'schedule_model.g.dart';

class ScheduleController extends StateNotifier<ScheduleState> {
  ScheduleController()
      : super(
            const ScheduleState(startDate: null, endDate: null, dueDate: null));

  void updateStartDate(DateTime date) {
    state = state.copyWith(startDate: date);
  }

  void updateEndDate(DateTime date) {
    state = state.copyWith(endDate: date);
  }

  void updateDueDate(DateTime date) {
    state = state.copyWith(dueDate: date);
  }
}

@freezed
class ScheduleState with _$ScheduleState {
  const factory ScheduleState({
    required DateTime? startDate,
    required DateTime? endDate,
    required DateTime? dueDate,
  }) = _ScheduleState;

  factory ScheduleState.fromJson(Map<String, dynamic> json) =>
      _$ScheduleStateFromJson(json);
}
