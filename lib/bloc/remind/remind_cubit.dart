import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gl_nueip/core/services/notification_service.dart';
import 'package:gl_nueip/core/utils/injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'remind_state.dart';

class RemindCubit extends Cubit<RemindState> {
  final SharedPreferences _prefs;

  RemindCubit(this._prefs) : super(const RemindState.initial()) {
    _loadState();
  }

  static const String _remindKey = 'remind_state';

  Future<void> toggleRemind() async {
    bool hasPermission =
        await locator<NotificationService>().checkNotificationPermission();
    if (hasPermission) {
      emit(state.copyWith(isEnabled: !state.isEnabled));
      _saveState();
    }
  }

  void _loadState() async {
    final bool? isEnabled = _prefs.getBool(_remindKey);
    if (isEnabled != null) {
      emit(RemindState(isEnabled: isEnabled));
    }
  }

  Future<void> _saveState() async {
    _prefs.setBool(_remindKey, state.isEnabled);
  }
}
