part of 'daily_log_cubit.dart';

sealed class DailyLogState extends Equatable {
  const DailyLogState();
}

final class DailyLogInitial extends DailyLogState {
  @override
  List<Object> get props => [];
}

final class DailyLogEmpty extends DailyLogState {
  @override
  List<Object> get props => [];
}

final class DailyLogError extends DailyLogState {
  @override
  List<Object> get props => [];
}

final class DailyLogTimeOff extends DailyLogState {
  final String timeOffType;

  const DailyLogTimeOff({required this.timeOffType});

  @override
  List<Object> get props => [timeOffType];
}

final class DailyLogWorked extends DailyLogState {
  final List<WorkLog> workLogs;

  const DailyLogWorked({required this.workLogs});

  @override
  List<Object> get props => [workLogs];
}

final class DailyLogHoliday extends DailyLogState {
  const DailyLogHoliday();

  @override
  List<Object> get props => [];
}
