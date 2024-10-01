import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

class TimeCubit extends Cubit<DateTime> {
  Timer? _timer;

  TimeCubit() : super(DateTime.now()) {
    _startTimer();
  }
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      emit(DateTime.now());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
