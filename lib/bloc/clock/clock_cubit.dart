import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gl_nueip/core/utils/enum.dart';

part 'clock_state.dart';

typedef ClockedTime = (String? clockInTime, String? clockOutTime);

class ClockCubit extends Cubit<ClockState> {
  ClockCubit() : super(const ClockState.initial());

  void loading() => emit(state.copyWith(status: ClockAction.loading));

  void clockInClick() =>
      emit(state.copyWith(button: ClickButton.clockInButton));

  void clockOutClick() =>
      emit(state.copyWith(button: ClickButton.clockOutButton));

  void clockIn(String time) {
    emit(
      state.copyWith(
        status: ClockAction.success,
        button: ClickButton.none,
        clockInTime: time,
        clockOutTime: state.clockOutTime,
        isClockedIn: true,
      ),
    );
  }

  void clockOut(String time) {
    emit(
      state.copyWith(
        status: ClockAction.success,
        button: ClickButton.none,
        clockInTime: state.clockInTime,
        clockOutTime: time,
        isClockedOut: true,
      ),
    );
  }

  void failed() {
    emit(
      state.copyWith(
        status: ClockAction.failed,
        button: ClickButton.none,
      ),
    );
  }

  void initStatus(ClockedTime? logTime) async {
    emit(state.copyWith(status: ClockAction.idle));

    final ClockedTime? workTime = logTime;
    final String? clockInTime = workTime?.$1;
    final String? clockOutTime = workTime?.$2;

    final bool isClockedIn = clockInTime != null;
    final bool isClockedOut = clockOutTime != null;

    emit(state.copyWith(
      status: ClockAction.initial,
      isClockedIn: isClockedIn,
      isClockedOut: isClockedOut,
      clockInTime: clockInTime ?? state.clockInTime,
      clockOutTime: clockOutTime ?? state.clockOutTime,
    ));
  }
}
