part of 'clock_cubit.dart';

class ClockState extends Equatable {
  final ClockAction status;
  final ClickButton button;
  final String? clockInTime;
  final String? clockOutTime;
  final bool isClockedIn;
  final bool isClockedOut;

  const ClockState({
    required this.status,
    this.clockInTime,
    this.clockOutTime,
    this.isClockedIn = false,
    this.isClockedOut = false,
    required this.button,
  });

  const ClockState.initial()
      : this(
          status: ClockAction.initial,
          button: ClickButton.none,
          isClockedIn: false,
          isClockedOut: false,
        );

  ClockState copyWith({
    ClockAction? status,
    String? clockInTime,
    String? clockOutTime,
    ClickButton? button,
    bool? isClockedIn,
    bool? isClockedOut,
  }) {
    return ClockState(
      status: status ?? this.status,
      clockInTime: clockInTime ?? this.clockInTime,
      clockOutTime: clockOutTime ?? this.clockOutTime,
      button: button ?? this.button,
      isClockedIn: isClockedIn ?? this.isClockedIn,
      isClockedOut: isClockedOut ?? this.isClockedOut,
    );
  }

  @override
  List<Object?> get props => [
        status,
        clockInTime,
        clockOutTime,
        button,
        isClockedIn,
        isClockedOut,
      ];
}
