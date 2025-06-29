import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/motor_model.dart';
import '../../../providers/motor_provider.dart';
import 'booking_form_screen.dart';

class MotorDetailScreen extends StatelessWidget {
  // Sekarang kita hanya butuh ID untuk mencari data terbaru
  final String motorId;

  const MotorDetailScreen({super.key, required this.motorId});

  @override
  Widget build(BuildContext context) {
    // Gunakan Consumer untuk mendapatkan data motor terbaru dari MotorProvider
    return Consumer<MotorProvider>(
      builder: (context, motorProvider, child) {
        // Cari motor berdasarkan ID
        final MotorModel? motor = motorProvider.motors.firstWhere(
          (m) => m.id == motorId,
          // Jika tidak ditemukan (misal setelah dihapus admin), sediakan fallback
          orElse: () => MotorModel(
            id: '',
            nama: 'Motor tidak ditemukan',
            merek: '',
            tahun: 0,
            nomorPolisi: '',
            hargaSewa: 0,
            status: 'Tidak Tersedia',
            gambarUrl: '',
          ),
        );

        // Jika motor null, tampilkan loading atau pesan error
        if (motor == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final statusColor = motor.status == 'Tersedia'
            ? Colors.green
            : Colors.orange;
        final bool isSewaEnabled = motor.status == 'Tersedia';

        return Scaffold(
          appBar: AppBar(
            title: Text(motor.nama),
            backgroundColor: Colors.blueAccent,
            elevation: 0,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ... (UI untuk gambar dan detail sama seperti sebelumnya) ...
                Image.network(motor.gambarUrl, height: 250, fit: BoxFit.cover),
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
                              motor.status,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: statusColor,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
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
                        'Rp ${motor.hargaSewa} / hari',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
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
                      // Tunggu hasil dari halaman booking
                      final bookingResult = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BookingFormScreen(motor: motor),
                        ),
                      );

                      // Jika hasil booking adalah 'true' (sukses), baru refresh data
                      if (bookingResult == true && context.mounted) {
                        Provider.of<MotorProvider>(
                          context,
                          listen: false,
                        ).fetchMotorsManual();
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
