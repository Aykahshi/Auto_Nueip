import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gl_nueip/bloc/lang/lang_cubit.dart';
import 'package:gl_nueip/core/models/holiday_model.dart';
import 'package:gl_nueip/core/services/holiday_service.dart';
import 'package:gl_nueip/core/utils/enum.dart';
import 'package:gl_nueip/core/utils/injection_container.dart';
import 'package:gl_nueip/core/utils/parse_datetime.dart';
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
  List<Holiday> _holidayList = [];

  final HolidayService _holidayService = locator<HolidayService>();

  @override
  void initState() {
    super.initState();
    _holidayService.getHolidays().then((holidays) {
      setState(() {
        _holidayList = holidays;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LangCubit, LangState>(
      builder: (_, lang) {
        final int year = DateTime.now().year;

        return TableCalendar(
          locale: lang.language == Language.enUS ? 'en_US' : 'zh_TW',
          firstDay: DateTime(year, 1, 1),
          lastDay: DateTime(year + 5, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.month,
          headerStyle: const HeaderStyle(
              formatButtonVisible: false, titleCentered: true),
          calendarStyle: CalendarStyle(
            defaultTextStyle: const TextStyle(color: Colors.white),
            holidayTextStyle: const TextStyle(color: Colors.redAccent),
            holidayDecoration: const BoxDecoration(
              border: Border(),
            ),
            todayDecoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
          ),
          holidayPredicate: (day) {
            return _holidayList
                .any((holiday) => isSameDay(parseDateTime(holiday.date), day));
          },
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
