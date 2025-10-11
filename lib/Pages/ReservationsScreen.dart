import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/mock_data.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({Key? key}) : super(key: key);

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Reservation> _reservations;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _reservations = List.from(mockReservations);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Reservation> get _upcoming =>
      _reservations.where((r) => r.status == 'confirmed').toList();

  List<Reservation> get _past =>
      _reservations.where((r) => r.status == 'completed').toList();

  List<Reservation> get _cancelled =>
      _reservations.where((r) => r.status == 'cancelled').toList();

  void _handleCancel(int id) {
    setState(() {
      final index = _reservations.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reservations[index] = Reservation(
          id: _reservations[index].id,
          restaurantName: _reservations[index].restaurantName,
          restaurantImage: _reservations[index].restaurantImage,
          cuisine: _reservations[index].cuisine,
          date: _reservations[index].date,
          time: _reservations[index].time,
          guests: _reservations[index].guests,
          status: 'cancelled',
        );
      }
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Réservation annulée')));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUpcomingTab(),
                _buildPastTab(),
                _buildCancelledTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF3B82F6),
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mes réservations',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gérez vos réservations de restaurants',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF3B82F6),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: 'À venir (${_upcoming.length})'),
          Tab(text: 'Passées (${_past.length})'),
          Tab(text: 'Annulées (${_cancelled.length})'),
        ],
      ),
    );
  }

  Widget _buildUpcomingTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (_upcoming.isNotEmpty) ...[
          _buildReminderCard(),
          const SizedBox(height: 16),
          ..._upcoming.map(
            (reservation) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildReservationCard(reservation),
            ),
          ),
        ] else
          _buildEmptyState(
            icon: Icons.calendar_today,
            title: 'Aucune réservation',
            message: 'Vous n\'avez pas de réservation à venir',
          ),
      ],
    );
  }

  Widget _buildPastTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: _past.isNotEmpty
          ? _past
                .map(
                  (reservation) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildReservationCard(reservation),
                  ),
                )
                .toList()
          : [
              _buildEmptyState(
                icon: Icons.access_time,
                title: 'Aucun historique',
                message: 'Vos réservations passées apparaîtront ici',
              ),
            ],
    );
  }

  Widget _buildCancelledTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: _cancelled.isNotEmpty
          ? _cancelled
                .map(
                  (reservation) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildReservationCard(reservation),
                  ),
                )
                .toList()
          : [
              _buildEmptyState(
                icon: Icons.check_circle,
                title: 'Aucune annulation',
                message: 'Vous n\'avez pas de réservation annulée',
              ),
            ],
    );
  }

  Widget _buildReminderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEEFE), // blue-50
        border: Border.all(color: const Color(0xFF93C5FD)), // blue-200
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF3B82F6), // blue-500
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rappel automatique',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vous recevrez une notification 2h avant votre réservation',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              reservation.restaurantImage,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 96,
                  height: 96,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.restaurant,
                    color: Colors.grey[600],
                    size: 40,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reservation.restaurantName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            reservation.cuisine,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (reservation.status == 'confirmed')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7), // green-100
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.check_circle,
                              color: Color(0xFF16A34A), // green-600
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Confirmé',
                              style: TextStyle(
                                color: Color(0xFF16A34A),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (reservation.status == 'cancelled')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Annulé',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.calendar_today, reservation.date),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.access_time, reservation.time),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.people, '${reservation.guests} personnes'),
                if (reservation.status == 'confirmed') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Appeler le restaurant
                          },
                          icon: const Icon(Icons.phone, size: 16),
                          label: const Text('Appeler'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _handleCancel(reservation.id),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Annuler'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
