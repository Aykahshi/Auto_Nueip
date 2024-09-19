import 'package:get_it/get_it.dart';
import 'package:gl_nueip/bloc/auth/auth_cubit.dart';
import 'package:gl_nueip/bloc/clock/clock_cubit.dart';
import 'package:gl_nueip/bloc/daill_log/daily_log_cubit.dart';
import 'package:gl_nueip/bloc/lang/lang_cubit.dart';
import 'package:gl_nueip/bloc/remind/remind_cubit.dart';
import 'package:gl_nueip/bloc/timer/timer_cubit.dart';
import 'package:gl_nueip/bloc/user/user_cubit.dart';
import 'package:gl_nueip/core/services/notification_service.dart';
import 'package:gl_nueip/core/services/nueip_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

GetIt locator = GetIt.instance;

Future<void> setupDependencies() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  locator
    // Shared Preferences
    ..registerSingleton<SharedPreferences>(prefs)
    // Cubits
    ..registerSingleton<AuthCubit>(AuthCubit())
    ..registerSingleton<ClockCubit>(ClockCubit())
    ..registerSingleton<DailyLogCubit>(DailyLogCubit())
    ..registerSingleton<UserCubit>(UserCubit(prefs))
    ..registerSingleton<RemindCubit>(RemindCubit(prefs))
    ..registerSingleton<LangCubit>(LangCubit(prefs))
    ..registerLazySingleton<TimeCubit>(() => TimeCubit())
    // Services
    ..registerLazySingleton<NueipService>(() => NueipService())
    ..registerLazySingleton<NotificationService>(() => NotificationService());
}
