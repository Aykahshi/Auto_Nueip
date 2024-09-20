import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gl_nueip/bloc/lang/lang_cubit.dart';
import 'package:gl_nueip/core/utils/enum.dart';
import 'package:gl_nueip/screens/dialogs/log_of_day_dialog.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:table_calendar/table_calendar.dart';

class WorklogCalendar extends StatefulWidget {
  const WorklogCalendar({super.key});

  @override
  State<WorklogCalendar> createState() => _WorklogCalendarState();
}

class _WorklogCalendarState extends State<WorklogCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LangCubit, LangState>(
      builder: (_, lang) {
        return TableCalendar(
          locale: lang.language == Language.enUS ? 'en_US' : 'zh_TW',
          firstDay: DateTime(2024, 1, 1),
          lastDay: DateTime(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.month,
          headerStyle: const HeaderStyle(
              formatButtonVisible: false, titleCentered: true),
          calendarStyle: CalendarStyle(
            defaultTextStyle: const TextStyle(color: Colors.white),
            weekendTextStyle: const TextStyle(color: Colors.redAccent),
            todayDecoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
          ),
          rowHeight: 50,
          daysOfWeekHeight: 30,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) async {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            final String dayForWorklog =
                _selectedDay.toString().split(' ').first;
            showShadDialog(
              context: context,
              builder: (_) => DayLog(selectedDate: dayForWorklog),
            );
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        );
      },
    );
  }
}
