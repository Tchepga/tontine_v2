import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/event.dart';
import '../../providers/tontine_provider.dart';
import '../../widgets/menu_widget.dart';
import 'package:intl/intl.dart';

class EventView extends StatefulWidget {
  static const routeName = '/event';
  const EventView({super.key});

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      final tontineProvider = Provider.of<TontineProvider>(context, listen: false);
      if (tontineProvider.currentTontine != null) {
        final events = await tontineProvider.getEventsForTontine(
          tontineProvider.currentTontine!.id,
        );
        _groupEventsByDay(events);
      }
    });
  }

  void _groupEventsByDay(List<Event> events) {
    _events = {};
    for (var event in events) {
      final date = DateTime(
        event.startDate.year,
        event.startDate.month,
        event.startDate.day,
      );
      if (_events[date] == null) _events[date] = [];
      _events[date]!.add(event);
    }
    setState(() {});
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Événements'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
            ),
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
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text('Sélectionnez une date'))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: _getEventsForDay(_selectedDay!)
                        .map((event) => _buildEventCard(event))
                        .toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateEventDialog(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const MenuWidget(),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(event.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.description),
            const SizedBox(height: 4),
            Text(
              'Date: ${DateFormat('dd/MM/yyyy').format(event.startDate)}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            Text(
              'Type: ${event.type.toString().split('.').last}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 100,
          child: Text(
            '${event.participants.length} participants',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  void _showCreateEventDialog(BuildContext context) {
    // Implémentez ici la logique pour créer un nouvel événement
  }
} 