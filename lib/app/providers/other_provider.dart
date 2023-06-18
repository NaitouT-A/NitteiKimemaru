import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez2gether/app/models/schedule_model.dart';

final scheduleProvider =
    StateNotifierProvider<ScheduleController, ScheduleState>((ref) {
  return ScheduleController();
});
final dayStateProvider =
    StateNotifierProvider<DayStateController, DayState>((ref) {
  return DayStateController();
});

class DayStateController extends StateNotifier<DayState> {
  DayStateController() : super(DayState());

  void onDaySelected(DateTime day) {
    // implement what should happen when a day is selected
    state = DayState(dayStates: state.dayStates);
  }

  void onHeaderTapped(int weekday) {
    state.dayStates[weekday - 1] = !state.dayStates[weekday - 1];
    state = DayState(dayStates: state.dayStates);
  }
}

class DayState {
  List<bool> dayStates;

  DayState(
      {this.dayStates = const [
        false,
        false,
        false,
        false,
        false,
        false,
        false
      ]});
}
