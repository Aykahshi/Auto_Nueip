import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:gl_nueip/bloc/clock/clock_cubit.dart';
import 'package:gl_nueip/core/services/nueip_service.dart';
import 'package:gl_nueip/core/utils/enum.dart';
import 'package:gl_nueip/core/utils/injection_container.dart';
import 'package:gl_nueip/core/utils/show_toast.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ClockButton extends StatelessWidget {
  const ClockButton({super.key});

  @override
  Widget build(BuildContext context) {
    final NueipService service = locator<NueipService>();

    return BlocConsumer<ClockCubit, ClockState>(
      listener: (context, state) {
        if (state.status == ClockAction.success) {
          if (state.isClockedIn && !state.isClockedOut) {
            showToast('clock.in_success'.tr(), Colors.green[600]!);
          } else if (state.isClockedOut) {
            showToast('clock.out_success'.tr(), Colors.green[600]!);
          }
        } else if (state.status == ClockAction.failed) {
          showToast('clock.fail'.tr(), Colors.red[700]!);
        }
      },
      builder: (_, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ShadButton(
              width: 150,
              height: 80,
              onPressed: () => service.clockIn(),
              child: _buildButtonChild(
                context: context,
                method: 'in',
                state: state,
                isClocked: state.isClockedIn,
                buttonType: ClickButton.clockInButton,
              ),
            ),
            ShadButton(
              width: 150,
              height: 80,
              onPressed: () => service.clockOut(),
              child: _buildButtonChild(
                context: context,
                method: 'out',
                state: state,
                isClocked: state.isClockedOut,
                buttonType: ClickButton.clockOutButton,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildButtonChild({
    required BuildContext context,
    required String method,
    required ClockState state,
    required ClickButton buttonType,
    required bool isClocked,
  }) {
    final String? logTime =
        method == 'in' ? state.clockInTime : state.clockOutTime;

    if (state.status == ClockAction.loading && state.button == buttonType ||
        state.status == ClockAction.idle) {
      return const CircularProgressIndicator(color: Colors.lightBlueAccent);
    } else if (isClocked) {
      return FittedBox(
        child: Row(
          children: [
            const Icon(Icons.access_alarms_outlined, color: Colors.black),
            const Gap(5),
            Text(logTime ?? '', style: const TextStyle(fontSize: 17)),
          ],
        ),
      );
    }
    return Text(context.tr('clock.$method'),
        style: const TextStyle(fontSize: 18));
  }
}
