import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:gl_nueip/bloc/cubit.dart';
import 'package:gl_nueip/core/utils/injection_container.dart';
import 'package:gl_nueip/screens/dialogs/user_info_dialog.dart';
import 'package:gl_nueip/screens/widgets/calendar_widget.dart';
import 'package:gl_nueip/screens/widgets/clock_button_widget.dart';
import 'package:gl_nueip/screens/widgets/scaffold_with_action_widget.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ShadThemeData theme = ShadTheme.of(context);
    final AuthCubit authCubit = context.read<AuthCubit>();

    return ScaffoldWithAction(
      body: BlocBuilder<UserCubit, UserState>(
        builder: (_, info) {
          return Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                ShadCard(
                  width: MediaQuery.of(context).size.width * 0.9,
                  backgroundColor: Colors.grey[800]!.withOpacity(0.15),
                  // ignore: sort_child_properties_last
                  child: Center(
                    child: Column(
                      children: [
                        Text('welcome', style: theme.textTheme.h3)
                            .tr(namedArgs: {'name': info.user.name}),
                        const Gap(20),
                        const TimeClock(),
                        const Gap(20),
                      ],
                    ),
                  ),
                  footer: authCubit.isLoggedIn
                      ? const ClockButton()
                      : Align(
                          child: InkWell(
                            onTap: () {
                              showShadDialog(
                                context: context,
                                builder: (_) => const UserInfoDialog(),
                              );
                            },
                            child: ShadCard(
                              backgroundColor: Colors.red.withOpacity(0.7),
                              child: FittedBox(
                                child: Text(
                                  'set_info_first',
                                  style: theme.textTheme.p
                                      .copyWith(fontWeight: FontWeight.bold),
                                ).tr(),
                              ),
                            ),
                          ),
                        ),
                ),
                const Gap(10),
                ShadCard(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    backgroundColor: Colors.grey[800]!.withOpacity(0.15),
                    child: const WorklogCalendar())
              ],
            ),
          );
        },
      ),
    );
  }
}

class TimeClock extends StatelessWidget {
  const TimeClock({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<TimeCubit>(),
      child: BlocBuilder<TimeCubit, DateTime>(
        builder: (_, currentTime) {
          return FittedBox(
            child: const Text(
              'time_now',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ).tr(
              namedArgs: {
                'time': DateFormat('yyyy-MM-dd HH:mm:ss').format(currentTime)
              },
            ),
          );
        },
      ),
    );
  }
}
