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
import '../../theme/app_theme.dart';

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
  bool _isCreatingEvent = false;

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
        return AppColors.secondary;
      case EventType.BIRTHDAY:
        return Colors.pink;
      case EventType.PARTY:
        return AppColors.tertiary;
      case EventType.WEDDING:
        return AppColors.primary;
      case EventType.CONFERENCE:
        return Colors.blue;
      case EventType.WORKSHOP:
        return Colors.orange;
      case EventType.SEMINAR:
        return Colors.purple;
      case EventType.FUNERAL:
        return Colors.grey;
      case EventType.ILLNESS:
        return Colors.red;
      case EventType.NEWBORN:
        return Colors.green;
      case EventType.GRIEF:
        return Colors.brown;
      case EventType.OTHER:
        return AppColors.textSecondary;
    }
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.MEETING:
        return Icons.business_center;
      case EventType.BIRTHDAY:
        return Icons.cake;
      case EventType.PARTY:
        return Icons.celebration;
      case EventType.WEDDING:
        return Icons.favorite;
      case EventType.CONFERENCE:
        return Icons.school;
      case EventType.WORKSHOP:
        return Icons.build;
      case EventType.SEMINAR:
        return Icons.record_voice_over;
      case EventType.FUNERAL:
        return Icons.church;
      case EventType.ILLNESS:
        return Icons.medical_services;
      case EventType.NEWBORN:
        return Icons.child_care;
      case EventType.GRIEF:
        return Icons.psychology;
      case EventType.OTHER:
        return Icons.event;
    }
  }

  Map<DateTime, List<Event>> _groupEventsByDay(List<Event> events) {
    final Map<DateTime, List<Event>> groupedEvents = {};
    for (var event in events) {
      final day = DateTime(
        event.startDate.year,
        event.startDate.month,
        event.startDate.day,
      );
      if (groupedEvents.containsKey(day)) {
        groupedEvents[day]!.add(event);
      } else {
        groupedEvents[day] = [event];
      }
    }
    return groupedEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TontineProvider, EventProvider>(
      builder: (context, tontineProvider, eventProvider, child) {
        final eventsForTontine =
            _getEventsForSelectedDate(eventProvider.events);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Événements'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Column(
            children: [
              // Date Picker
              TableCalendar<Event>(
                calendarBuilders: CalendarBuilders<Event>(
                  defaultBuilder: (context, date, events) {
                    final hasEvent =
                        isAnyEventThisDay(date, eventProvider.events);
                    return Container(
                      margin: const EdgeInsets.all(3),
                      alignment: Alignment.center,
                      decoration: hasEvent
                          ? BoxDecoration(
                              color: AppColors.primary.withAlpha(30),
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
                  return _groupEventsByDay(eventProvider.events)[day] ?? [];
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    selectedDate = selectedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  markerDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                  markerSize: 8,
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(50),
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
                child: eventProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : eventsForTontine.isEmpty
                        ? Card(
                            margin: const EdgeInsets.all(16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.surface,
                                    AppColors.surface.withAlpha(50),
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withAlpha(20),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.event_busy,
                                        size: 48,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Aucun événement le ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    FilledButton.icon(
                                      onPressed: _isCreatingEvent
                                          ? null
                                          : () => _showCreateEventDialog(
                                              context,
                                              tontineProvider,
                                              eventProvider),
                                      icon: _isCreatingEvent
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.add),
                                      label: Text(_isCreatingEvent
                                          ? 'Création...'
                                          : 'Ajouter un événement'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: eventsForTontine.length,
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              final event = eventsForTontine[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.surface,
                                        AppColors.surface.withAlpha(30),
                                      ],
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    onTap: () => _showEventDetails(context,
                                        event, tontineProvider, eventProvider),
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _getChipColor(event.type)
                                            .withAlpha(20),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _getEventIcon(event.type),
                                        color: _getChipColor(event.type),
                                        size: 24,
                                      ),
                                    ),
                                    title: Text(
                                      event.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          event.description,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getChipColor(event.type)
                                                    .withAlpha(20),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color:
                                                      _getChipColor(event.type),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                event.type.displayName,
                                                style: TextStyle(
                                                  color:
                                                      _getChipColor(event.type),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.secondary
                                                    .withAlpha(20),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.people,
                                                    size: 14,
                                                    color: AppColors.secondary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${event.participants?.length ?? 0}',
                                                    style: TextStyle(
                                                      color:
                                                          AppColors.secondary,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
            backgroundColor: AppColors.primary,
            onPressed: _isCreatingEvent
                ? null
                : () => _showCreateEventDialog(
                    context, tontineProvider, eventProvider),
            child: _isCreatingEvent
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.add, color: Colors.white),
          ),
          bottomNavigationBar: const MenuWidget(),
        );
      },
    );
  }

  bool isAnyEventThisDay(DateTime date, List<Event> events) {
    return events.any((event) => DateUtils.isSameDay(event.startDate, date));
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildStyledDropdown<T>({
    required T value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.surface,
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date != null
                        ? DateFormat('dd/MM/yyyy').format(date)
                        : 'Non définie',
                    style: TextStyle(
                      color: date != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down,
                    color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsSelector({
    required List<int> selectedParticipants,
    required List<dynamic> members,
    required void Function(List<int>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participants (optionnel)',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sélectionnez les participants:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: members.map((member) {
                  final isSelected = selectedParticipants.contains(member.id);
                  return FilterChip(
                    label: Text('${member.firstname} ${member.lastname}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      final newParticipants =
                          List<int>.from(selectedParticipants);
                      if (selected) {
                        newParticipants.add(member.id);
                      } else {
                        newParticipants.remove(member.id);
                      }
                      onChanged(newParticipants);
                    },
                    selectedColor: AppColors.primary.withAlpha(30),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              if (selectedParticipants.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${selectedParticipants.length} participant(s) sélectionné(s)',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showCreateEventDialog(BuildContext context,
      TontineProvider tontineProvider, EventProvider eventProvider) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime? endDate;
    EventType selectedType = EventType.MEETING;
    List<int> selectedParticipants = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Nouvel événement',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Titre
                            _buildStyledTextField(
                              controller: titleController,
                              label: 'Titre de l\'événement',
                              hint: 'Ex: Réunion mensuelle',
                              icon: Icons.title,
                            ),
                            const SizedBox(height: 16),

                            // Description
                            _buildStyledTextField(
                              controller: descriptionController,
                              label: 'Description',
                              hint: 'Décrivez l\'événement...',
                              icon: Icons.description,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),

                            // Type d'événement
                            _buildStyledDropdown<EventType>(
                              value: selectedType,
                              label: 'Type d\'événement',
                              icon: Icons.category,
                              items: EventType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getEventIcon(type),
                                        color: _getChipColor(type),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(type.displayName),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedType = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // Date de début
                            _buildDateSelector(
                              label: 'Date de début',
                              date: startDate,
                              icon: Icons.calendar_today,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: startDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2101),
                                );
                                if (date != null) {
                                  setState(() {
                                    startDate = date;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            // Date de fin (optionnel)
                            _buildDateSelector(
                              label: 'Date de fin (optionnel)',
                              date: endDate,
                              icon: Icons.event_available,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: endDate ?? startDate,
                                  firstDate: startDate,
                                  lastDate: DateTime(2101),
                                );
                                if (date != null) {
                                  setState(() {
                                    endDate = date;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            // Participants
                            _buildParticipantsSelector(
                              selectedParticipants: selectedParticipants,
                              members:
                                  tontineProvider.currentTontine?.members ?? [],
                              onChanged: (participants) {
                                setState(() {
                                  selectedParticipants = participants;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Footer avec boutons
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.border),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Annuler'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: _isCreatingEvent
                                  ? null
                                  : () async {
                                      if (titleController.text.isEmpty ||
                                          descriptionController.text.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Veuillez remplir tous les champs obligatoires'),
                                            backgroundColor: AppColors.warning,
                                          ),
                                        );
                                        return;
                                      }

                                      setState(() {
                                        _isCreatingEvent = true;
                                      });

                                      final eventDto = CreateEventDto(
                                        tontineId:
                                            tontineProvider.currentTontine!.id,
                                        title: titleController.text,
                                        type: selectedType,
                                        description: descriptionController.text,
                                        startDate: startDate,
                                        endDate: endDate,
                                        participants:
                                            selectedParticipants.isNotEmpty
                                                ? selectedParticipants
                                                : null,
                                      );

                                      try {
                                        await eventProvider
                                            .createEvent(eventDto);
                                        if (!context.mounted) return;
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Événement créé avec succès'),
                                            backgroundColor: AppColors.success,
                                          ),
                                        );
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('Erreur: ${e.toString()}'),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            _isCreatingEvent = false;
                                          });
                                        }
                                      }
                                    },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: _isCreatingEvent
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text('Création...'),
                                      ],
                                    )
                                  : const Text('Créer l\'événement'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _getChipColor(event.type),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getEventIcon(event.type),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Type', event.type.displayName),
                        _buildDetailRow('Description', event.description),
                        _buildDetailRow(
                          'Date de début',
                          DateFormat('dd/MM/yyyy à HH:mm')
                              .format(event.startDate),
                        ),
                        if (event.endDate != null)
                          _buildDetailRow(
                            'Date de fin',
                            DateFormat('dd/MM/yyyy à HH:mm')
                                .format(event.endDate!),
                          ),
                        _buildDetailRow(
                          'Auteur',
                          '${event.author.firstname} ${event.author.lastname}',
                        ),
                        if (event.participants != null &&
                            event.participants!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Participants (${event.participants!.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...event.participants!.map((participant) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${participant.firstname} ${participant.lastname}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ],
                    ),
                  ),
                ),
                // Footer avec boutons
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showEditEventDialog(
                                context, event, tontineProvider, eventProvider);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Modifier'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showDeleteConfirmation(
                                context, event, tontineProvider, eventProvider);
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Supprimer'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditEventDialog(BuildContext context, Event event,
      TontineProvider tontineProvider, EventProvider eventProvider) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Fonctionnalité de modification en cours de développement'),
        backgroundColor: AppColors.warning,
      ),
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
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
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
                  Navigator.pop(context);
                  await eventProvider.deleteEvent(
                      tontineProvider.currentTontine!.id, event.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Événement supprimé avec succès'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Erreur lors de la suppression: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
