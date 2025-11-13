import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class PDFService {
  static Future<File> generateReservationPDF({
    required String restaurantName,
    required DateTime reservationDate,
    required String reservationTime,
    required int numberOfGuests,
    required String status,
    String? specialRequests,
    required String reservationId, // Keep internally but don't show in PDF
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header - SIMPLIFIED without icons
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF114477), // _darkBlue
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'CONFIRMATION DE RÉSERVATION',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),

              pw.SizedBox(height: 30),

              // Reservation Details Title
              pw.Text(
                'Détails de la Réservation',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF114477),
                ),
              ),

              pw.SizedBox(height: 20),

              // Details Container - SIMPLIFIED
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromInt(0xFF4983A5)),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Restaurant', restaurantName),
                    _buildDetailRow('Date', _formatPDFDate(reservationDate)),
                    _buildDetailRow('Heure', reservationTime),
                    _buildDetailRow('Nombre de personnes', '$numberOfGuests ${numberOfGuests == 1 ? "personne" : "personnes"}'),
                    _buildDetailRow('Statut', _formatStatus(status)),
                    if (specialRequests != null && specialRequests.isNotEmpty)
                      _buildDetailRow('Demandes spéciales', specialRequests),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Confirmation Message
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFE3F2FD), // _lightBlue
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Votre réservation a été confirmée !',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF114477),
                        fontSize: 16,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Nous avons hâte de vous accueillir dans notre établissement.',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Important Information - SIMPLIFIED
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFF8E8E1), // _lightPurple
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Informations importantes:',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFFB86847), // _darkPurple
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Veuillez présenter cette confirmation à votre arrivée\n'
                          'En cas de retard, merci de prévenir le restaurant\n'
                          'Annulation possible jusqu\'à 2 heures avant la réservation\n'
                          'Tenue correcte exigée',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 25),

              // Footer
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Merci pour votre confiance !',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                        color: PdfColor.fromInt(0xFF114477),
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Généré le ${_formatPDFDateWithTime(DateTime.now())}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save PDF to temporary directory
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/reservation_${DateTime.now().millisecondsSinceEpoch}.pdf');

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Row _buildDetailRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Text(
            '$label:',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromInt(0xFF4983A5),
            ),
          ),
        ),
        pw.Expanded(
          flex: 3,
          child: pw.Text(
            value,
            style: pw.TextStyle(
              color: PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }

  static String _formatPDFDate(DateTime date) {
    final months = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
    final days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String _formatPDFDateWithTime(DateTime date) {
    final months = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
    return '${date.day} ${months[date.month - 1]} ${date.year} à ${_formatTime(date)}';
  }

  static String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${hour}h${minute}'; // FIXED: Removed the undefined 'h' variable
  }

  static String _formatStatus(String status) {
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
}