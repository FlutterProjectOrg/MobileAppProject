import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mobile_app_project/services/Reservation/local_reservation_service.dart';
import 'package:mobile_app_project/services/Auth/auth_service.dart';

import '../services/PDF/pdf_service.dart';

class ReservationDialog extends StatefulWidget {
  final bool open;
  final VoidCallback onClose;
  final String restaurantName;
  final int restaurantId;

  const ReservationDialog({
    super.key,
    required this.open,
    required this.onClose,
    required this.restaurantName,
    required this.restaurantId,
  });

  @override
  State<ReservationDialog> createState() => _ReservationDialogState();
}

class _ReservationDialogState extends State<ReservationDialog> {
  String step = 'form';
  DateTime? _selectedDate = DateTime.now();
  String _selectedTime = '19:00';
  int _selectedGuests = 2;
  bool _isLoading = false;
  bool _isGeneratingPDF = false;
  String? _specialRequests;

  // Color scheme
  final Color _primaryBlue = Color(0xFF4983A5);
  final Color _primaryPurple = Color(0xFFD19981);
  final Color _lightBlue = Color(0xFFE3F2FD);
  final Color _lightPurple = Color(0xFFF8E8E1);
  final Color _darkBlue = Color(0xFF114477);
  final Color _darkPurple = Color(0xFFB86847);


  final List<String> _timeSlots = [
    '11:30', '12:00', '12:30', '13:00', '13:30',
    '18:00', '18:30', '19:00', '19:30', '20:00', '20:30', '21:00', '21:30',
  ];

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      await LocalReservationService.instance.initialize();
      debugPrint('Reservation service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing reservation service: $e');
    }
  }


  Future<void> _downloadReservationPDF() async {
    setState(() {
      _isGeneratingPDF = true;
    });

    try {
      final reservation = await LocalReservationService.instance
          .getLatestReservationForUser(AuthService().currentUserId!);

      if (reservation != null) {
        final pdfFile = await PDFService.generateReservationPDF(
          restaurantName: widget.restaurantName,
          reservationDate: reservation.reservationDate,
          reservationTime: reservation.reservationTime,
          numberOfGuests: reservation.numberOfGuests,
          status: reservation.status,
          specialRequests: reservation.specialRequests,
          reservationId: reservation.id?.toString() ?? 'private', // ID kept private internally
        );

        // Share the PDF file with generic name
        await Printing.sharePdf(
          bytes: await pdfFile.readAsBytes(),
          filename: 'confirmation_reservation.pdf', // Generic name without ID
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: Réservation non trouvée'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('PDF generation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la génération du PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGeneratingPDF = false;
      });
    }
  }

  Future<void> _handleSubmit() async {
    final authService = AuthService();
    final currentUserId = authService.currentUserId;

    debugPrint('Current User ID: $currentUserId');
    debugPrint('Is Logged In: ${currentUserId != null}');

    if (currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: Vous devez être connecté pour réserver'),
            duration: Duration(seconds: 3),
            backgroundColor: _primaryPurple,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (_selectedDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veuillez sélectionner une date'),
            backgroundColor: _primaryPurple,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final reservation = Reservation(
        userId: currentUserId,
        restaurantId: widget.restaurantId,
        reservationDate: _selectedDate!,
        reservationTime: _selectedTime,
        numberOfGuests: _selectedGuests,
        status: 'confirmed',
        specialRequests: _specialRequests?.isEmpty ?? true ? null : _specialRequests,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      debugPrint('=== CREATING RESERVATION ===');
      debugPrint('User ID: $currentUserId');
      debugPrint('Restaurant ID: ${widget.restaurantId}');
      debugPrint('Date: ${_selectedDate!}');
      debugPrint('Time: $_selectedTime');
      debugPrint('Guests: $_selectedGuests');
      debugPrint('Status: confirmed');

      final createdReservation = await LocalReservationService.instance
          .createReservation(reservation);

      if (createdReservation != null) {
        debugPrint('✅ Reservation created successfully: ${createdReservation.id}');
        setState(() {
          step = 'success';
          _isLoading = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la création de la réservation. Vérifiez que le restaurant existe.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Reservation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleClose() {
    setState(() {
      step = 'form';
      _isLoading = false;
      _selectedDate = DateTime.now();
      _selectedTime = '19:00';
      _selectedGuests = 2;
      _specialRequests = null;
    });
    widget.onClose();
  }

  String _formatDate(DateTime date) {
    final months = ['janv', 'févr', 'mars', 'avr', 'mai', 'juin', 'juil', 'août', 'sept', 'oct', 'nov', 'déc'];
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.open) return const SizedBox.shrink();

    return Dialog(
      insetPadding: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, _lightBlue.withOpacity(0.1)],
          ),
        ),
        child: step == 'form' ? _buildModernForm(context) : _buildModernSuccess(context),
      ),
    );
  }

  Widget _buildModernForm(BuildContext context) {
    final isLoggedIn = AuthService().currentUserId != null;

    return Column(
      children: [
        // Modern Header
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_darkBlue, _darkBlue],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Réserver une table',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.restaurantName,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isLoggedIn) ...[
                      SizedBox(height: 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 12, color: Colors.orange[100]),
                            SizedBox(width: 4),
                            Text(
                              'Connexion requise',
                              style: TextStyle(
                                color: Colors.orange[100],
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: _isLoading ? null : _handleClose,
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Login Warning Card
                if (!isLoggedIn) ...[
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Connexion requise',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[800],
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Connectez-vous pour effectuer une réservation',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],

                // Date Picker Section
                _buildModernSection(
                  icon: Icons.calendar_month_rounded,
                  title: 'Date de réservation',
                  subtitle: 'Sélectionnez la date souhaitée',
                  child: Column(
                    children: [
                      if (_selectedDate != null) ...[
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_lightBlue, _lightPurple],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 16, color: _primaryBlue),
                              SizedBox(width: 8),
                              Text(
                                _formatDate(_selectedDate!),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _darkBlue,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _lightBlue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TableCalendar(
                          firstDay: DateTime.now(),
                          lastDay: DateTime.now().add(Duration(days: 365)),
                          focusedDay: _selectedDate ?? DateTime.now(),
                          selectedDayPredicate: (day) =>
                              isSameDay(day, _selectedDate),
                          onDaySelected: isLoggedIn ? (day, focusedDay) {
                            setState(() {
                              _selectedDate = day;
                            });
                          } : null,
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_primaryBlue, _primaryPurple],
                              ),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_primaryPurple, _primaryBlue],
                              ),
                              shape: BoxShape.circle,
                            ),
                            defaultTextStyle: TextStyle(
                              color: _darkBlue,
                              fontWeight: FontWeight.w500,
                            ),
                            weekendTextStyle: TextStyle(
                              color: _primaryPurple,
                              fontWeight: FontWeight.w500,
                            ),
                            disabledTextStyle: TextStyle(
                              color: Colors.grey[400],
                            ),
                            outsideTextStyle: TextStyle(
                              color: Colors.grey[400],
                            ),
                            tablePadding: EdgeInsets.all(8),
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: TextStyle(
                              color: _darkBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            leftChevronIcon: Icon(Icons.chevron_left_rounded, color: _primaryBlue),
                            rightChevronIcon: Icon(Icons.chevron_right_rounded, color: _primaryBlue),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              color: _darkBlue,
                              fontWeight: FontWeight.w600,
                            ),
                            weekendStyle: TextStyle(
                              color: _primaryPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Mois',
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Time Picker Section - CORRIGÉ
                // Time Picker Section - CORRIGÉ
                _buildModernSection(
                  icon: Icons.access_time_rounded,
                  title: 'Heure de réservation',
                  subtitle: 'Choisissez l\'heure souhaitée',
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _lightBlue),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedTime,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        prefixIcon: Icon(Icons.schedule_rounded, color: _primaryBlue),
                        // AJOUT: Afficher la valeur sélectionnée dans le hint
                        hint: Text(
                          _selectedTime,
                          style: TextStyle(
                            color: _darkBlue,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      dropdownColor: Colors.white,
                      style: TextStyle(
                        color: _darkBlue,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      icon: Icon(Icons.arrow_drop_down_rounded, color: _primaryBlue),
                      iconSize: 24,
                      items: _timeSlots.map((slot) {
                        return DropdownMenuItem(
                          value: slot,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              slot,
                              style: TextStyle(
                                fontSize: 14,
                                color: _darkBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: isLoggedIn ? (val) {
                        setState(() {
                          _selectedTime = val!;
                        });
                      } : null,
                      // AJOUT: Personnaliser l'affichage de l'élément sélectionné
                      selectedItemBuilder: (BuildContext context) {
                        return _timeSlots.map<Widget>((String item) {
                          return Text(
                            item,
                            style: TextStyle(
                              color: _darkBlue,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),

                SizedBox(height: 24),

                _buildModernSection(
                  icon: Icons.people_alt_rounded,
                  title: 'Nombre de personnes',
                  subtitle: 'Combien serez-vous ?',
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _lightBlue),
                    ),
                    child: DropdownButtonFormField<int>(
                      value: _selectedGuests,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        prefixIcon: Icon(Icons.person_rounded, color: _primaryBlue),
                        // AJOUT: Afficher la valeur sélectionnée dans le hint
                        hint: Text(
                          '$_selectedGuests ${_selectedGuests == 1 ? "personne" : "personnes"}',
                          style: TextStyle(
                            color: _darkBlue,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      dropdownColor: Colors.white,
                      style: TextStyle(
                        color: _darkBlue,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      icon: Icon(Icons.arrow_drop_down_rounded, color: _primaryBlue),
                      iconSize: 24,
                      items: List.generate(8, (index) => index + 1)
                          .map((num) => DropdownMenuItem(
                        value: num,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '$num ${num == 1 ? "personne" : "personnes"}',
                            style: TextStyle(
                              fontSize: 14,
                              color: _darkBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )).toList(),
                      onChanged: isLoggedIn ? (val) {
                        setState(() {
                          _selectedGuests = val!;
                        });
                      } : null,
                      // AJOUT: Personnaliser l'affichage de l'élément sélectionné
                      selectedItemBuilder: (BuildContext context) {
                        return List.generate(8, (index) => index + 1)
                            .map<Widget>((int item) {
                          return Text(
                            '$item ${item == 1 ? "personne" : "personnes"}',
                            style: TextStyle(
                              color: _darkBlue,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Special Requests Section
                _buildModernSection(
                  icon: Icons.note_alt_rounded,
                  title: 'Demandes spéciales',
                  subtitle: 'Optionnel - allergies, anniversaire...',
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _lightBlue),
                    ),
                    child: TextField(
                      enabled: isLoggedIn,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Ex: Allergie aux arachides, anniversaire, place calme...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                      style: TextStyle(
                        color: _darkBlue,
                        fontSize: 14,
                      ),
                      onChanged: isLoggedIn ? (value) {
                        setState(() {
                          _specialRequests = value;
                        });
                      } : null,
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // AI Suggestions
                if (isLoggedIn) ...[
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_lightPurple, _lightBlue],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _primaryPurple.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _primaryPurple,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Suggestion IA',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _darkPurple,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '💡 Les créneaux de 18h30 et 20h30 sont idéaux pour une expérience optimale selon l\'affluence habituelle.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _darkPurple,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                ],

                // Submit Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryPurple.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Création en cours...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ElevatedButton(
                    onPressed: isLoggedIn ? _handleSubmit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLoggedIn
                          ? _darkBlue
                          : Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isLoggedIn ? Icons.confirmation_number_rounded : Icons.lock_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          isLoggedIn
                              ? 'Confirmer la réservation'
                              : 'Connexion requise',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 8),
                if (isLoggedIn)
                  Text(
                    'Vous recevrez une confirmation par email',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryBlue, _primaryPurple],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _darkBlue,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildModernSuccess(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.lightGreen],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),

          SizedBox(height: 24),

          // Success Title
          Text(
            'Réservation confirmée ! 🎉',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _darkBlue,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 8),

          Text(
            'Votre table a été réservée avec succès',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 32),

          // Reservation Details Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_lightBlue, _lightPurple],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _primaryBlue.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _lightBlue.withOpacity(0.5),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildModernSuccessDetail(
                  icon: Icons.restaurant_rounded,
                  label: 'Restaurant',
                  value: widget.restaurantName,
                ),
                _buildModernSuccessDetail(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: _formatDate(_selectedDate!),
                ),
                _buildModernSuccessDetail(
                  icon: Icons.access_time_rounded,
                  label: 'Heure',
                  value: _selectedTime,
                ),
                _buildModernSuccessDetail(
                  icon: Icons.people_rounded,
                  label: 'Personnes',
                  value: '$_selectedGuests',
                ),
                if (_specialRequests?.isNotEmpty ?? false)
                  _buildModernSuccessDetail(
                    icon: Icons.note_rounded,
                    label: 'Demandes spéciales',
                    value: _specialRequests!,
                  ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Download PDF Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _primaryBlue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: _isGeneratingPDF
                ? ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Génération du PDF...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
                : ElevatedButton(
              onPressed: _downloadReservationPDF,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Télécharger PDF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _handleClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.done_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Terminer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 12),

          TextButton(
            onPressed: () {
              // Navigate to reservations screen
              _handleClose();
            },
            child: Text(
              'Voir mes réservations',
              style: TextStyle(
                color: _primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Un email de confirmation vous a été envoyé',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernSuccessDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: _primaryBlue),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: _darkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}