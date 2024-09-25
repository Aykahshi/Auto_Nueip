import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:gl_nueip/bloc/user/user_cubit.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CurrentInfoDialog extends StatelessWidget {
  const CurrentInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final ShadThemeData theme = ShadTheme.of(context);

    return BlocBuilder<UserCubit, UserState>(
      builder: (_, state) {
        return Padding(
          padding: const EdgeInsets.all(30),
          child: ShadDialog(
            title: Text('current_info.title', style: theme.textTheme.h3).tr(),
            alignment: Alignment.center,
            titleTextAlign: TextAlign.center,
            child: Column(
              children: [
                const Text('current_info.company')
                    .tr(namedArgs: {'company': state.user.company}),
                const Gap(5),
                const Text('current_info.id')
                    .tr(namedArgs: {'id': state.user.id}),
                const Gap(5),
                const Text('current_info.password')
                    .tr(namedArgs: {'password': state.user.password}),
              ],
            ),
          ),
        );
      },
    );
  }
}
