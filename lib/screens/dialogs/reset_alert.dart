import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gl_nueip/bloc/user/user_cubit.dart';
import 'package:gl_nueip/core/utils/show_toast.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ResetAlert extends StatelessWidget {
  const ResetAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (_, state) {
        return Padding(
          padding: const EdgeInsets.all(30),
          child: ShadDialog.alert(
            title: const Text('reset_action.title').tr(),
            description: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: const Text('reset_action.alert').tr(),
            ),
            actions: [
              ShadButton.outline(
                width: 200,
                child: const Text('button.cancel').tr(),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ShadButton.destructive(
                width: 200,
                child: const Text('button.reset').tr(),
                onPressed: () {
                  context.read<UserCubit>().reset();
                  showToast(
                      'reset_action.success'.tr(), Colors.red.withOpacity(0.8));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
