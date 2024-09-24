import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:gl_nueip/bloc/lang/lang_cubit.dart';
import 'package:gl_nueip/bloc/remind/remind_cubit.dart';
import 'package:gl_nueip/bloc/user/user_cubit.dart';
import 'package:gl_nueip/core/services/nueip_service.dart';
import 'package:gl_nueip/core/utils/injection_container.dart';
import 'package:gl_nueip/generated/assets.dart';
import 'package:gl_nueip/screens/dialogs/current_info_dialog.dart';
import 'package:gl_nueip/screens/dialogs/reset_alert.dart';
import 'package:gl_nueip/screens/dialogs/user_info_dialog.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ShadThemeData theme = ShadTheme.of(context);
    final NueipService service = locator<NueipService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'settings.title'.tr(),
          style: theme.textTheme.h3.copyWith(fontWeight: FontWeight.w200),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => service.checkStatus(),
            icon: const Icon(Icons.restart_alt_outlined, size: 30),
          ),
          const SizedBox(width: 20)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    showShadDialog(
                      context: context,
                      builder: (_) => const CurrentInfoDialog(),
                    );
                  },
                  child: ShadCard(
                    width: MediaQuery.of(context).size.width * 0.9,
                    backgroundColor: Colors.grey[700]!.withOpacity(0.2),
                    border: ShadBorder.none,
                    padding: const EdgeInsets.all(16),
                    child: FittedBox(
                      child: Row(
                        children: [
                          const Gap(10),
                          const ClipOval(
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.black87, BlendMode.color),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage(Assets.icon),
                              ),
                            ),
                          ),
                          const Gap(30),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BlocBuilder<UserCubit, UserState>(
                                builder: (_, info) {
                                  return Text(
                                    'welcome'.tr(
                                        namedArgs: {'name': info.user.name}),
                                    style: theme.textTheme.h3,
                                  );
                                },
                              ),
                              Text(
                                'settings.click_to_check'.tr(),
                                style: theme.textTheme.p.copyWith(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const Gap(16),
                BlocBuilder<RemindCubit, RemindState>(
                  builder: (_, reminder) {
                    return SettingsGroup(
                      settingsGroupTitle: 'settings.subtitle'.tr(),
                      backgroundColor: Colors.grey[800]!.withOpacity(0.15),
                      items: [
                        SettingsItem(
                          onTap: () {
                            showShadDialog(
                              context: context,
                              builder: (_) => const UserInfoDialog(),
                            );
                          },
                          icons: Icons.person_outline_outlined,
                          title: 'settings.change_title'.tr(),
                          subtitle: 'settings.change_desc'.tr(),
                        ),
                        SettingsItem(
                          onTap: () =>
                              context.read<LangCubit>().langToggle(context),
                          icons: Icons.language_outlined,
                          title: 'settings.lang_title'.tr(),
                          subtitle: 'settings.lang_desc'.tr(),
                          trailing: const Icon(Icons.translate_rounded),
                        ),
                        SettingsItem(
                          onTap: () async {
                            await context.read<RemindCubit>().toggleRemind();
                          },
                          icons: Icons.add_alert_rounded,
                          title: 'settings.remind_title'.tr(),
                          subtitle: 'settings.remind_desc'.tr(),
                          trailing: ShadSwitch(
                            value: reminder.isEnabled,
                            onChanged: (_) async {
                              await context.read<RemindCubit>().toggleRemind();
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SettingsGroup(
                  backgroundColor: Colors.red[700]!.withOpacity(0.7),
                  items: [
                    SettingsItem(
                      onTap: () {
                        showShadDialog(
                          context: context,
                          builder: (_) => const ResetAlert(),
                        );
                      },
                      icons: Icons.delete_forever,
                      title: 'settings.reset_title'.tr(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
