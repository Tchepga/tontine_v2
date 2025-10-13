import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';
import '../../providers/models/enum/event_type.dart';
import '../../providers/models/event.dart';
import '../../providers/tontine_provider.dart';
import '../../widgets/menu_widget.dart';
import 'package:intl/intl.dart';
import '../services/dto/event_dto.dart';
import '../../providers/event_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/local_notification_service.dart';

class EventView extends StatefulWidget {
  static const routeName = '/event';
  const EventView({super.key});

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  DateTime selectedDate = DateTime.now();
  final localNotificationService = LocalNotificationService();
  final _logger = Logger('EventView');

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final tontineProvider =
          Provider.of<TontineProvider>(context, listen: false);
      if (tontineProvider.currentTontine != null) {
        eventProvider.loadEvents(tontineProvider.currentTontine!.id);
        _logger.info('eventProvider.events: ${eventProvider.events}');
      }
    });
  }

  List<Event> _getEventsForSelectedDate(List<Event> events) {
    return events.where((event) {
      return DateUtils.isSameDay(event.startDate, selectedDate);
    }).toList();
  }

  Color _getChipColor(EventType type) {
    switch (type) {
      case EventType.MEETING:
        return Colors.blueAccent;
      case EventType.PARTY:
        return Colors.purple;
      case EventType.WEDDING:
        return Colors.orange;
      case EventType.OTHER:
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Map<DateTime, List<Event>> _groupEventsByDay(List<Event> events) {
    return {
      for (var event in events)
        DateTime(
          event.startDate.year,
          event.startDate.month,
          event.startDate.day,
        ): events
            .where((e) => DateUtils.isSameDay(e.startDate, event.startDate))
            .toList()
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TontineProvider, EventProvider>(
      builder: (context, tontineProvider, eventProvider, child) {
        final eventsForTontine =
            _getEventsForSelectedDate(eventProvider.events);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Événements'),
          ),
          body: Column(
            children: [
              // Date Picker
              TableCalendar(
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, date, events) {
                    final hasEvent =
                        isAnyEventThisDay(date, eventProvider.events);
                    return Container(
                      margin: const EdgeInsets.all(3),
                      alignment: Alignment.center,
                      decoration: hasEvent
                          ? BoxDecoration(
                              color: Colors.orange[100],
                              shape: BoxShape.circle,
                            )
                          : null,
                      child: Text(date.day.toString()),
                    );
                  },
                ),
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: selectedDate,
                selectedDayPredicate: (day) => isSameDay(day, selectedDate),
                eventLoader: (day) {
                  return _groupEventsByDay(eventsForTontine)[day] ?? [];
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    selectedDate = selectedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  markerDecoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                  markerSize: 8,
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  markerMargin: const EdgeInsets.only(top: 1),
                ),
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),

              // Liste des événements
              Expanded(
                child: eventsForTontine.isEmpty
                    ? Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.event_busy,
                                size: 48,
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun événement le ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: () => _showCreateEventDialog(
                                    context, tontineProvider, eventProvider),
                                icon: const Icon(Icons.add),
                                label: const Text('Ajouter un événement'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: eventsForTontine.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final event = eventsForTontine[index];
                          return Card(
                            child: ListTile(
                              onTap: () => _showEventDetails(context, event,
                                  tontineProvider, eventProvider),
                              title: Text(event.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(event.description),
                                  const SizedBox(height: 4),
                                  Chip(
                                    label: Text(
                                      event.type.displayName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    backgroundColor: _getChipColor(event.type),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ],
                              ),
                              trailing: Text(
                                '${event.participants?.length ?? 0} participants',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'event_fab',
            onPressed: () =>
                _showCreateEventDialog(context, tontineProvider, eventProvider),
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: const MenuWidget(),
        );
      },
    );
  }

  bool isAnyEventThisDay(DateTime date, List<Event> events) {
    return events.any((event) => DateUtils.isSameDay(event.startDate, date));
  }

  void _showCreateEventDialog(BuildContext context,
      TontineProvider tontineProvider, EventProvider eventProvider) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime? endDate;
    EventType selectedType = EventType.MEETING;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nouvel événement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Titre'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<EventType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: EventType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedType = value!;
                  },
                ),
                ListTile(
                  title: const Text('Date de début'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(startDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (date != null) {
                      startDate = date;
                    }
                  },
                ),
                ListTile(
                  title: const Text('Date de fin (optionnel)'),
                  subtitle: Text(endDate != null
                      ? DateFormat('dd/MM/yyyy').format(endDate!)
                      : 'Non définie'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? startDate,
                      firstDate: startDate,
                      lastDate: DateTime(2101),
                    );
                    if (date != null) {
                      endDate = date;
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        if (titleController.text.isEmpty ||
                            descriptionController.text.isEmpty) {
                          return;
                        }

                        final eventDto = CreateEventDto(
                          tontineId: tontineProvider.currentTontine!.id,
                          title: titleController.text,
                          type: selectedType,
                          description: descriptionController.text,
                          startDate: startDate,
                          endDate: endDate,
                        );

                        try {
                          Navigator.pop(context);
                          await eventProvider.createEvent(eventDto);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Événement créé avec succès'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text('Créer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEventDetails(BuildContext context, Event event,
      TontineProvider tontineProvider, EventProvider eventProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                _buildDetailRow('Type', event.type.displayName),
                _buildDetailRow('Date de début',
                    DateFormat('dd/MM/yyyy').format(event.startDate)),
                if (event.endDate != null)
                  _buildDetailRow('Date de fin',
                      DateFormat('dd/MM/yyyy').format(event.endDate!)),
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(event.description),
                const SizedBox(height: 16),
                const Text(
                  'Participants',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (event.participants?.isNotEmpty ?? false)
                  ...event.participants!.map(
                    (participant) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                          '• ${participant.firstname} ${participant.lastname}'),
                    ),
                  )
                else
                  const Text('Aucun participant'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditEventDialog(
                            context, event, tontineProvider, eventProvider);
                      },
                      child: const Text('Modifier'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _showDeleteConfirmation(
                          context, event, tontineProvider, eventProvider),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Supprimer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showEditEventDialog(BuildContext context, Event event,
      TontineProvider tontineProvider, EventProvider eventProvider) {
    final titleController = TextEditingController(text: event.title);
    final descriptionController =
        TextEditingController(text: event.description);
    DateTime startDate = event.startDate;
    DateTime? endDate = event.endDate;
    EventType selectedType = event.type;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Modifier l\'événement',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Titre'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<EventType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: EventType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedType = value!;
                  },
                ),
                ListTile(
                  title: const Text('Date de début'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(startDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (date != null) {
                      startDate = date;
                    }
                  },
                ),
                ListTile(
                  title: const Text('Date de fin (optionnel)'),
                  subtitle: Text(endDate != null
                      ? DateFormat('dd/MM/yyyy').format(endDate!)
                      : 'Non définie'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? startDate,
                      firstDate: startDate,
                      lastDate: DateTime(2101),
                    );
                    if (date != null) {
                      endDate = date;
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        if (titleController.text.isEmpty ||
                            descriptionController.text.isEmpty) {
                          return;
                        }

                        final eventDto = CreateEventDto(
                          tontineId: tontineProvider.currentTontine!.id,
                          title: titleController.text,
                          type: selectedType,
                          description: descriptionController.text,
                          startDate: startDate,
                          endDate: endDate,
                        );

                        try {
                          Navigator.pop(context);
                          await eventProvider.updateEvent(event.id, eventDto);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Événement modifié avec succès')),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Erreur lors de la modification de l\'événement'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text('Modifier'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Event event,
      TontineProvider tontineProvider, EventProvider eventProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text(
              'Voulez-vous vraiment supprimer l\'événement "${event.title}" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  Navigator.pop(
                      context); // Fermer la boîte de dialogue de confirmation
                  Navigator.pop(
                      context); // Fermer la boîte de dialogue des détails
                  await eventProvider.deleteEvent(
                      tontineProvider.currentTontine!.id, event.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Événement supprimé avec succès')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Erreur lors de la suppression de l\'événement'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
