import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gl_nueip/core/utils/enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LangState {
  final Language language;

  LangState(this.language);
}

class LangCubit extends Cubit<LangState> {
  final String _langKey = 'locale';
  final SharedPreferences _prefs;

  LangCubit(this._prefs) : super(LangState(Language.enUS)) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final String locale = _prefs.getString(_langKey) ?? 'en_US';
    final Language lang = locale == 'zh_TW' ? Language.zhTW : Language.enUS;
    emit(LangState(lang));
  }

  Future<void> langToggle(BuildContext context) async {
    final Language lang =
        state.language == Language.enUS ? Language.zhTW : Language.enUS;
    emit(LangState(lang));
    if (context.mounted) {
      context.setLocale(currentLocale);
    }
  }

  Locale get currentLocale {
    switch (state.language) {
      case Language.enUS:
        return const Locale('en', 'US');
      case Language.zhTW:
        return const Locale('zh', 'TW');
    }
  }
}
