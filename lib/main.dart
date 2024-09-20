import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:flutter/foundation.dart';
import 'package:gl_nueip/bloc/cubit.dart';
import 'package:gl_nueip/core/services/nueip_service.dart';
import 'package:preferences_local_storage_inspector/preferences_local_storage_inspector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:gl_nueip/core/services/notification_service.dart';
import 'package:gl_nueip/screens/pages/home_page.dart';
import 'package:gl_nueip/core/utils/injection_container.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storage_inspector/storage_inspector.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  await EasyLocalization.ensureInitialized();
  await NotificationService.init();
  await locator<NotificationService>().checkNotificationsEnabled();
  await locator<NotificationService>().checkClockedOrNot();
  if (locator<UserCubit>().isNotDefault()) {
    await locator<NueipService>().checkStatus();
  }

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
      fallbackLocale: const Locale('zh', 'TW'),
      path: 'assets/translations',
      assetLoader: const JsonAssetLoader(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => locator<AuthCubit>()),
        BlocProvider(create: (_) => locator<RemindCubit>()),
        BlocProvider(create: (_) => locator<UserCubit>()),
        BlocProvider(create: (_) => locator<ClockCubit>()),
        BlocProvider(create: (_) => locator<DailyLogCubit>()),
        BlocProvider(create: (_) => locator<LangCubit>()),
      ],
      child: KeyboardDismissOnTap(
        dismissOnCapturedTaps: true,
        child: ShadApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
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
