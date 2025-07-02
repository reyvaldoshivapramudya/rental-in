import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentalin/app/data/models/motor_status.dart';
import '../../../data/models/motor_model.dart';
import '../../../providers/motor_provider.dart';
import 'booking_form_screen.dart';

class MotorDetailScreen extends StatelessWidget {
  final String motorId;

  const MotorDetailScreen({super.key, required this.motorId});

  @override
  Widget build(BuildContext context) {
    return Consumer<MotorProvider>(
      builder: (context, motorProvider, child) {
        final motor = motorProvider.motors.firstWhere(
          (m) => m.id == motorId,
          orElse: () => MotorModel(
            id: '',
            nama: 'Motor tidak ditemukan',
            merek: '',
            tahun: 0,
            nomorPolisi: '',
            hargaSewa: 0,
            status: MotorStatus.tidakTersedia,
            gambarUrl: '',
          ),
        );

        final statusColor = motor.status == 'Tersedia'
            ? Colors.green
            : Colors.orange;
        final isSewaEnabled = motor.status == 'Tersedia';

        return Scaffold(
          appBar: AppBar(
            title: Text(motor.nama),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                motor.gambarUrl.isNotEmpty
                    ? Image.network(
                        motor.gambarUrl,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 250,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.two_wheeler,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 250,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        height: 250,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.two_wheeler,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        motor.nama,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${motor.merek} - ${motor.nomorPolisi}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              motor.status.displayName,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: statusColor,
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tahun ${motor.tahun}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      const Text(
                        'Harga Sewa',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        motor.formattedPrice + ' / hari',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (motor.deskripsi != null &&
                          motor.deskripsi!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Deskripsi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(motor.deskripsi!),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: isSewaEnabled
                  ? () async {
                      final bookingResult = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BookingFormScreen(motor: motor),
                        ),
                      );

                      if (bookingResult == true && context.mounted) {
                        Provider.of<MotorProvider>(
                          context,
                          listen: false,
                        ).refreshMotors();
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isSewaEnabled
                    ? Colors.blueAccent
                    : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isSewaEnabled ? 'Sewa Sekarang' : 'Tidak Tersedia',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        );
      },
    );
  }
}
