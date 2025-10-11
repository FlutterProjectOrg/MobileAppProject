import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatelessWidget {
  final CalendarFormat initialFormat;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final Function(DateTime)? onDaySelected;
  final Function(DateTime, DateTime)? onRangeSelected;
  final bool showOutsideDays;

  const Calendar({
    Key? key,
    this.initialFormat = CalendarFormat.month,
    required this.focusedDay,
    this.selectedDay,
    this.rangeStart,
    this.rangeEnd,
    this.onDaySelected,
    this.onRangeSelected,
    this.showOutsideDays = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2000, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      rangeStartDay: rangeStart,
      rangeEndDay: rangeEnd,
      onDaySelected: (selected, focused) {
        if (onDaySelected != null) onDaySelected!(selected);
      },
      onRangeSelected: (start, end, focused) {
        if (onRangeSelected != null && start != null && end != null) {
          onRangeSelected!(start, end);
        }
      },
      calendarFormat: initialFormat,
      daysOfWeekVisible: true,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronIcon: Icon(Icons.chevron_left, size: 20, color: Colors.grey),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          size: 20,
          color: Colors.grey,
        ),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        rangeStartDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        rangeEndDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        rangeHighlightColor: Theme.of(
          context,
        ).colorScheme.primary.withOpacity(0.3),
        outsideDaysVisible: showOutsideDays,
        defaultTextStyle: TextStyle(fontSize: 12),
        weekendTextStyle: TextStyle(color: Colors.redAccent),
        disabledTextStyle: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w400,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        weekendStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.redAccent,
        ),
      ),
    );
  }
}
