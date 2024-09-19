import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'daily_log_state.dart';

typedef WorkLog = ({String time, String status});

class DailyLogCubit extends Cubit<DailyLogState> {
  DailyLogCubit() : super(DailyLogInitial());

  void isLoading() {
    emit(DailyLogLoading());
  }

  void hasNoLogs() {
    emit(DailyLogEmpty());
  }

  void hasWorked({required List<WorkLog> workLogs}) {
    emit(DailyLogWorked(workLogs: workLogs));
  }

  void hasTimeOff({required String timeOffType}) {
    final String timeOffName;

    switch (timeOffType) {
      case '事假':
        timeOffName = 'time_off.pl'.tr();
      case '病假':
        timeOffName = 'time_off.sl'.tr();
      case '婚假':
        timeOffName = 'time_off.ml1'.tr();
      case '產假':
        timeOffName = 'time_off.ml2'.tr();
      case '喪假':
        timeOffName = 'time_off.bl'.tr();
      case '特休':
        timeOffName = 'time_off.al'.tr();
      default:
        timeOffName = 'time_off.other'.tr();
    }

    emit(DailyLogTimeOff(timeOffType: timeOffName));
  }
}
