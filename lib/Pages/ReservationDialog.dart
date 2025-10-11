import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ReservationDialog extends StatefulWidget {
  final bool open;
  final VoidCallback onClose;
  final String restaurantName;

  const ReservationDialog({
    super.key,
    required this.open,
    required this.onClose,
    required this.restaurantName,
  });

  @override
  State<ReservationDialog> createState() => _ReservationDialogState();
}

class _ReservationDialogState extends State<ReservationDialog> {
  String step = 'form'; // 'form' ou 'success'
  DateTime? selectedDate = DateTime.now();
  String selectedTime = '19:00';
  int selectedGuests = 2;

  final List<String> timeSlots = [
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
    '20:30',
    '21:00',
    '21:30',
  ];

  void handleSubmit() {
    setState(() {
      step = 'success';
    });
  }

  void handleClose() {
    setState(() {
      step = 'form';
    });
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.open) return const SizedBox.shrink();

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.8,
        child: step == 'form' ? buildForm(context) : buildSuccess(context),
      ),
    );
  }

  Widget buildForm(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Réserver une table',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    widget.restaurantName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: handleClose),
            ],
          ),
        ),
        const Divider(height: 1),
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Date Picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.calendar_today, size: 16),
                        SizedBox(width: 4),
                        Text('Sélectionnez une date'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: selectedDate ?? DateTime.now(),
                      selectedDayPredicate: (day) =>
                          isSameDay(day, selectedDate),
                      onDaySelected: (day, focusedDay) {
                        setState(() {
                          selectedDate = day;
                        });
                      },
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Time Picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.access_time, size: 16),
                        SizedBox(width: 4),
                        Text('Heure'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: selectedTime,
                      isExpanded: true,
                      items: timeSlots.map((slot) {
                        return DropdownMenuItem(value: slot, child: Text(slot));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedTime = val!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Guests
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.people, size: 16),
                        SizedBox(width: 4),
                        Text('Nombre de personnes'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<int>(
                      value: selectedGuests,
                      isExpanded: true,
                      items: List.generate(8, (index) => index + 1)
                          .map(
                            (num) => DropdownMenuItem(
                              value: num,
                              child: Text(
                                '$num ${num == 1 ? "personne" : "personnes"}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedGuests = val!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // AI Suggestions
                Card(
                  color: Colors.purple[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '💡 Suggestion IA',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '18h30 ou 20h30 sont les meilleurs créneaux disponibles selon l\'affluence habituelle',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: handleSubmit,
                    child: const Text('Confirmer la réservation'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSuccess(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Réservation confirmée!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Votre table pour $selectedGuests personnes est réservée le ${selectedDate?.toLocal().toString().split(' ')[0]} à $selectedTime',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: handleClose,
              child: const Text('Terminer'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Un email de confirmation vous a été envoyé',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
