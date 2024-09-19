import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:gl_nueip/bloc/daill_log/daily_log_cubit.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DayLog extends StatelessWidget {
  const DayLog({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(60),
      child: ShadDialog(
        title: Text('log.title'.tr(), style: const TextStyle(fontSize: 24)),
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[400]!,
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              width: 300,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              height: 180,
              child: const DayLogContent(),
            ),
          ),
        ),
      ),
    );
  }
}

class DayLogContent extends StatelessWidget {
  const DayLogContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DailyLogCubit, DailyLogState>(
      builder: (_, state) {
        switch (state) {
          case DailyLogLoading():
            return Column(
              children: [
                const SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(strokeWidth: 10),
                ),
                const Gap(20),
                Text('log.loading'.tr(), style: const TextStyle(fontSize: 18)),
              ],
            );
          case DailyLogTimeOff():
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.code_off_outlined,
                  size: 80,
                  color: Colors.white70,
                ),
                const Gap(20),
                Text('time_off.title'
                    .tr(namedArgs: {'type': state.timeOffType})),
              ],
            );
          case DailyLogWorked():
            return DataTable(
              border: const TableBorder(
                verticalInside: BorderSide(color: Colors.white10, width: 1),
              ),
              headingRowColor:
                  WidgetStateProperty.all(Colors.blueGrey.withOpacity(0.2)),
              dataRowColor:
                  WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
              columnSpacing: 30,
              horizontalMargin: 14,
              columns: [
                DataColumn(
                    label: Expanded(
                        child: Text('log.time'.tr(),
                            textAlign: TextAlign.center))),
                DataColumn(
                    label: Expanded(
                        child: Text('log.status'.tr(),
                            textAlign: TextAlign.center)))
              ],
              rows: state.workLogs.map((w) {
                return DataRow(cells: [
                  DataCell(Center(child: Text(w.time))),
                  DataCell(Center(child: Text(w.status))),
                ]);
              }).toList(),
            );
          case DailyLogEmpty():
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.not_interested_outlined,
                  size: 80,
                  color: Colors.white70,
                ),
                const Gap(20),
                Text('log.no_logs'.tr()),
              ],
            );
          default:
            return Text('error.common'.tr());
        }
      },
    );
  }
}
