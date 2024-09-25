import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gl_nueip/screens/widgets/info_form_widget.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class UserInfoDialog extends StatelessWidget {
  const UserInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final ShadThemeData theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ShadDialog(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        gap: 10,
        title: Text('change_action.title', style: theme.textTheme.h3).tr(),
        alignment: Alignment.center,
        titleTextAlign: TextAlign.center,
        child: const InfoForm(),
      ),
    );
  }
}
