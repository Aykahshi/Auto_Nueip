import 'package:get_it/get_it.dart';
import 'package:gl_nueip/bloc/cubit.dart';
import 'package:gl_nueip/core/services/holiday_service.dart';
import 'package:gl_nueip/core/services/location_service.dart';
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
    ..registerSingleton<ClockCubit>(ClockCubit())
    ..registerSingleton<DailyLogCubit>(DailyLogCubit())
    ..registerSingleton<UserCubit>(UserCubit(prefs))
    ..registerSingleton<RemindCubit>(RemindCubit(prefs))
    ..registerSingleton<LangCubit>(LangCubit(prefs))
    ..registerSingleton<AuthCubit>(AuthCubit(prefs))
    ..registerLazySingleton<LocationCubit>(() => LocationCubit(prefs))
    ..registerSingleton<TimeCubit>(TimeCubit())
    // Services
    ..registerLazySingleton<LocationService>(() => LocationService())
    ..registerLazySingleton<NueipService>(() => NueipService())
    ..registerLazySingleton<HolidayService>(() => HolidayService())
    ..registerLazySingleton<NotificationService>(() => NotificationService());
}
