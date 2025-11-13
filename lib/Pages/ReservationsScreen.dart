import 'package:flutter/material.dart';
import 'package:mobile_app_project/services/Reservation/local_reservation_service.dart';
import 'package:mobile_app_project/services/Auth/auth_service.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<Reservation> _reservations = [];
  bool _isLoading = true;
  String _filter = 'all'; // 'all', 'upcoming', 'past'

  // Color scheme - matching your other screens
  final Color _primaryBlue = Color(0xFF4983A5);
  final Color _primaryPurple = Color(0xFFD19981);
  final Color _lightBlue = Color(0xFFE3F2FD);
  final Color _lightPurple = Color(0xFFF8E8E1);
  final Color _darkBlue = Color(0xFF114477);
  final Color _darkPurple = Color(0xFFB86847);

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final currentUserId = authService.currentUserId;

      if (currentUserId == null) {
        setState(() {
          _isLoading = false;
          _reservations = [];
        });
        return;
      }

      final reservations = await LocalReservationService.instance
          .getReservationsByUserId(currentUserId);

      setState(() {
        _reservations = reservations;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading reservations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Reservation> get _filteredReservations {
    final now = DateTime.now();
    switch (_filter) {
      case 'upcoming':
        return _reservations.where((r) => _isReservationUpcoming(r)).toList();
      case 'past':
        return _reservations.where((r) => _isReservationPast(r)).toList();
      default:
        return _reservations;
    }
  }

  bool _isReservationUpcoming(Reservation reservation) {
    final now = DateTime.now();
    final reservationDateTime = _combineDateAndTime(reservation.reservationDate, reservation.reservationTime);

    // Une réservation est "à venir" si elle est dans le futur (date + heure)
    return reservationDateTime.isAfter(now);
  }

  bool _isReservationPast(Reservation reservation) {
    final now = DateTime.now();
    final reservationDateTime = _combineDateAndTime(reservation.reservationDate, reservation.reservationTime);

    // Une réservation est "passée" si elle est dans le passé (date + heure)
    return reservationDateTime.isBefore(now);
  }

  DateTime _combineDateAndTime(DateTime date, String time) {
    // Convertir l'heure string en heures et minutes
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Combiner la date avec l'heure
    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmée';
      case 'pending':
        return 'En attente';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['janv', 'févr', 'mars', 'avr', 'mai', 'juin', 'juil', 'août', 'sept', 'oct', 'nov', 'déc'];
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _cancelReservation(int reservationId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: const Text('Êtes-vous sûr de vouloir annuler cette réservation ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        _isLoading = true;
      });

      final success = await LocalReservationService.instance
          .updateReservationStatus(reservationId, 'cancelled');

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Réservation annulée'),
            backgroundColor: _primaryPurple,
            behavior: SnackBarBehavior.floating,
          ),
        );
        await _loadReservations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'annulation'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final currentUserId = authService.currentUserId;

    if (currentUserId == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Mes Réservations',
            style: TextStyle(
              color: _darkBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: _primaryBlue),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_lightBlue, _lightPurple],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.login_rounded, size: 50, color: _primaryBlue),
              ),
              SizedBox(height: 24),
              Text(
                'Connectez-vous',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _darkBlue,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Connectez-vous pour voir vos réservations',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Mes Réservations',
          style: TextStyle(
            color: _darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: _primaryBlue),
        actions: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.refresh_rounded, color: _primaryBlue, size: 20),
            ),
            onPressed: _loadReservations,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header avec compteur
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_lightBlue, _lightPurple],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: _primaryBlue,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vos réservations',
                        style: TextStyle(
                          fontSize: 16,
                          color: _darkBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${_reservations.length} réservation${_reservations.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: _darkPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Modern Filter Chips
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _lightBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _lightBlue),
              ),
              child: Row(
                children: [
                  _buildModernFilterChip('Toutes', 'all'),
                  _buildModernFilterChip('À venir', 'upcoming'),
                  _buildModernFilterChip('Passées', 'past'),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _filteredReservations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: EdgeInsets.all(16),
              physics: BouncingScrollPhysics(),
              itemCount: _filteredReservations.length,
              itemBuilder: (context, index) {
                final reservation = _filteredReservations[index];
                return _buildModernReservationCard(reservation);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _filter = value;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          margin: EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
              colors: [_primaryBlue, _primaryPurple],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : _primaryBlue,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: _primaryBlue,
            strokeWidth: 2,
          ),
          SizedBox(height: 16),
          Text(
            'Chargement de vos réservations...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    String subtitle;
    IconData icon;

    switch (_filter) {
      case 'upcoming':
        message = 'Aucune réservation à venir';
        subtitle = 'Vos prochaines réservations apparaîtront ici';
        icon = Icons.calendar_today_rounded;
        break;
      case 'past':
        message = 'Aucune réservation passée';
        subtitle = 'Vos réservations précédentes apparaîtront ici';
        icon = Icons.history_rounded;
        break;
      default:
        message = 'Aucune réservation';
        subtitle = 'Commencez par réserver une table dans un restaurant';
        icon = Icons.restaurant_rounded;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_lightBlue, _lightPurple],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 50, color: _primaryBlue),
            ),
            SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _darkBlue,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernReservationCard(Reservation reservation) {
    final isUpcoming = _isReservationUpcoming(reservation);
    final isToday = reservation.reservationDate.day == DateTime.now().day &&
        reservation.reservationDate.month == DateTime.now().month &&
        reservation.reservationDate.year == DateTime.now().year;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _lightBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: _lightBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with restaurant info
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_lightBlue, _lightPurple.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: reservation.restaurantImage != null
                        ? DecorationImage(
                      image: NetworkImage(reservation.restaurantImage!),
                      fit: BoxFit.cover,
                    )
                        : null,
                    color: reservation.restaurantImage == null ? _primaryBlue : null,
                  ),
                  child: reservation.restaurantImage == null
                      ? Icon(Icons.restaurant_rounded, color: Colors.white, size: 24)
                      : null,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.restaurantName ?? 'Restaurant',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: _darkBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        reservation.restaurantAddress ?? '',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(reservation.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(reservation.status)),
                  ),
                  child: Text(
                    _getStatusText(reservation.status),
                    style: TextStyle(
                      color: _getStatusColor(reservation.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Reservation details
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Date with special indicator if today
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.calendar_today_rounded, size: 16, color: _primaryBlue),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _formatDate(reservation.reservationDate),
                        style: TextStyle(
                          fontSize: 16,
                          color: _darkBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isToday) ...[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_primaryBlue, _primaryPurple],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Aujourd'hui",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 12),
                _buildModernDetailRow(
                  icon: Icons.access_time_rounded,
                  label: 'Heure',
                  value: reservation.time,
                ),
                SizedBox(height: 8),
                _buildModernDetailRow(
                  icon: Icons.people_rounded,
                  label: 'Personnes',
                  value: '${reservation.guests} ${reservation.guests == 1 ? "personne" : "personnes"}',
                ),
                if (reservation.specialRequests != null && reservation.specialRequests!.isNotEmpty) ...[
                  SizedBox(height: 8),
                  _buildModernDetailRow(
                    icon: Icons.note_rounded,
                    label: 'Demandes spéciales',
                    value: reservation.specialRequests!,
                    isMultiline: true,
                  ),
                ],
              ],
            ),
          ),

          // Action buttons for upcoming reservations
          if (isUpcoming && reservation.status.toLowerCase() != 'cancelled') ...[
            Divider(height: 1, color: _lightBlue),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _cancelReservation(reservation.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cancel_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Annuler'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryBlue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement modification functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Fonctionnalité de modification à venir'),
                              backgroundColor: _primaryBlue,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryBlue,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
                maxLines: isMultiline ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}