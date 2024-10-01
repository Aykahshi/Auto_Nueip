import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:gl_nueip/bloc/daily_log/daily_log_cubit.dart';
import 'package:gl_nueip/core/services/nueip_service.dart';
import 'package:gl_nueip/core/utils/injection_container.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DayLog extends StatelessWidget {
  final String selectedDate;

  const DayLog({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(60),
      child: ShadDialog(
        title: const Text('log.title', style: TextStyle(fontSize: 24)).tr(),
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
              child: FutureBuilder(
                future: locator<NueipService>().getDailyLogs(selectedDate),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                              color: Colors.lightBlueAccent),
                        ),
                        const Gap(20),
                        const Text('log.loading',
                                style: TextStyle(fontSize: 18))
                            .tr(),
                      ],
                    );
                  }
                  return const DayLogContent();
                },
              ),
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
          case DailyLogTimeOff():
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.work_off_outlined,
                  size: 80,
                  color: Colors.white70,
                ),
                const Gap(20),
                const Text('time_off.title')
                    .tr(namedArgs: {'type': state.timeOffType}),
              ],
            );
          case DailyLogHoliday():
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.code_off_outlined,
                  size: 80,
                  color: Colors.white70,
                ),
                const Gap(20),
                const Text('holiday').tr(),
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
                    child: const Text('log.time', textAlign: TextAlign.center)
                        .tr(),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: const Text('log.status', textAlign: TextAlign.center)
                        .tr(),
                  ),
                )
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
                const Text('log.no_logs').tr(),
              ],
            );
          case DailyLogError():
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.running_with_errors_outlined,
                  size: 80,
                  color: Colors.white70,
                ),
                const Gap(20),
                const Text('log.error').tr(),
              ],
            );
          default:
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    color: Colors.lightBlueAccent,
                  ),
                ),
                const Gap(20),
                const Text('log.loading', style: TextStyle(fontSize: 18)).tr(),
              ],
            );
        }
      },
    );
  }
}
