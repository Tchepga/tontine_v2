import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/tontine_provider.dart';
import '../../providers/models/part.dart';

class PartCalendarView extends StatefulWidget {
  static const routeName = '/part-calendar';
  const PartCalendarView({super.key});

  @override
  State<PartCalendarView> createState() => _PartCalendarViewState();
}

class _PartCalendarViewState extends State<PartCalendarView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Part>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadParts();
  }

  Future<void> _loadParts() async {
    if (!mounted) return;
    final tontineProvider = Provider.of<TontineProvider>(context, listen: false);
    if (tontineProvider.currentTontine != null) {
      await tontineProvider.loadParts(tontineProvider.currentTontine!.id);
      _updateEvents(tontineProvider.parts);
    }
  }

  void _updateEvents(List<Part> parts) {
    _events = {};
    for (var part in parts) {
      if (part.passageDate != null) {
        final date = DateTime(
          part.passageDate!.year,
          part.passageDate!.month,
          part.passageDate!.day,
        );
        if (_events[date] == null) _events[date] = [];
        _events[date]!.add(part);
      }
    }
    setState(() {});
  }

  List<Part> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TontineProvider>(
      builder: (context, tontineProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Calendrier des parts'),
          ),
          body: Column(
            children: [
              TableCalendar<Part>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: _getEventsForDay,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedDay == null
                      ? 0
                      : _getEventsForDay(_selectedDay!).length,
                  itemBuilder: (context, index) {
                    final part = _getEventsForDay(_selectedDay!)[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        title: Text('Part ${part.order}'),
                        subtitle: Text(part.memberName),
                        trailing: part.isPassed
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 