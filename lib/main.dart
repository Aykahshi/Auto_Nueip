import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:geofence_foreground_service/constants/geofence_event_type.dart';
import 'package:geofence_foreground_service/geofence_foreground_service.dart';
import 'package:gl_nueip/bloc/cubit.dart';
import 'package:gl_nueip/core/services/geofence_service.dart';
import 'package:gl_nueip/core/services/notification_service.dart';
import 'package:gl_nueip/core/services/nueip_service.dart';
import 'package:gl_nueip/core/utils/injection_container.dart';
import 'package:gl_nueip/screens/pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:preferences_local_storage_inspector/preferences_local_storage_inspector.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storage_inspector/storage_inspector.dart';

@pragma('vm:entry-point')
void callbackDispatcher() async {
  WidgetsFlutterBinding.ensureInitialized();
  GeofenceForegroundService().handleTrigger(
    backgroundTriggerHandler: (zoneID, triggerType) async {
      DateTime dateTime = DateTime.now();
      if (triggerType == GeofenceEventType.enter) {
        log('進入公司');

        if (isWithinWorkTimeRange(dateTime)) {
          await NueipService().clockIn();
        }
      } else if (triggerType == GeofenceEventType.exit) {
        log('離開公司');

        if (isWithinLeaveTimeRange(dateTime)) {
          await NueipService().clockOut();
        }
      } else if (triggerType == GeofenceEventType.dwell) {
        log('dwell', name: 'triggerType');
      } else {
        log('unknown', name: 'triggerType');
      }
      return Future.value(true);
    },
  );
}

bool isWithinWorkTimeRange(DateTime time) {
  final start = DateTime(time.year, time.month, time.day, 8, 0);
  final end = DateTime(time.year, time.month, time.day, 10, 0);
  return time.isAfter(start) && time.isBefore(end);
}

bool isWithinLeaveTimeRange(DateTime time) {
  final start = DateTime(time.year, time.month, time.day, 17, 0);
  final end = DateTime(time.year, time.month, time.day, 19, 0);
  return time.isAfter(start) && time.isBefore(end);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  await EasyLocalization.ensureInitialized();
  await NotificationService.init();
  await locator<NotificationService>().checkNotificationsEnabled();
  await locator<NotificationService>().checkClockedOrNot();
  GeofenceService();

  if (kDebugMode) {
    final driver = StorageServerDriver(
      bundleId: 'com.glsoft.glnueip',
      port: 0,
    );
    final prefServer =
        PreferencesKeyValueServer(locator<SharedPreferences>(), 'Preferences');
    driver.addKeyValueServer(prefServer);
    await driver.start(paused: false);
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('zh', 'TW'),
      ],
      startLocale: locator<LangCubit>().currentLocale,
      fallbackLocale: const Locale('en', 'US'),
      path: 'assets/translations',
      assetLoader: const JsonAssetLoader(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final bool isLoggedIn = locator<AuthCubit>().isLoggedIn;

  void checkAuth() async {
    if (isLoggedIn) {
      await locator<NueipService>().checkStatus();
    }
  }

  @override
  void initState() {
    checkAuth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => locator<AuthCubit>()),
        BlocProvider(create: (_) => locator<RemindCubit>()),
        BlocProvider(create: (_) => locator<LocationCubit>()),
        BlocProvider(create: (_) => locator<UserCubit>()),
        BlocProvider(create: (_) => locator<ClockCubit>()),
        BlocProvider(create: (_) => locator<DailyLogCubit>()),
        BlocProvider(create: (_) => locator<LangCubit>()),
      ],
      child: KeyboardDismissOnTap(
        dismissOnCapturedTaps: true,
        child: ShadApp.material(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          theme: ShadThemeData(
            colorScheme: const ShadSlateColorScheme.dark(),
            brightness: Brightness.dark,
            textTheme: ShadTextTheme.fromGoogleFont(
              GoogleFonts.robotoMono,
            ),
          ),
          debugShowCheckedModeBanner: false,
          title: 'Auto Nueip',
          home: const HomePage(),
        ),
      ),
    );
  }
}
